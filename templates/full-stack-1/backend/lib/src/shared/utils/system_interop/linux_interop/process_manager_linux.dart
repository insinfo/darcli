import 'dart:io' as dartio;
import 'linux_constants.dart';
import 'linux_interop.dart';
import '../process_info.dart';

//https://github.com/dotnet/runtime/blob/49d7bc83d986c32e8678001c841b1b836bc3e428/src/libraries/System.Diagnostics.Process/src/System/Diagnostics/ProcessManager.Linux.cs#L29
//https://github.com/dotnet/runtime/blob/f66c1c15409ff505ba55f8fdf86bc5c041bf47a3/src/libraries/System.Diagnostics.Process/src/System/Diagnostics/Process.Linux.cs#L264
class ProcessManagerLinux {
  Future<ProcessInfo?> getProcessInfo(
      {int? processIdFilter, String? processNameFilter}) async {
    if (processNameFilter != null) {
      throw Exception('Not used on Linux');
    }

    if (processIdFilter == null) {
      throw Exception('processIdFilter is used on Linux');
    }
    final procFsStat = await LinuxInterop.tryReadStatFile(processIdFilter);
    final procFsStatus = await LinuxInterop.tryReadStatusFile(processIdFilter);

    final handleCount = await getOpenFileDescriptorsCount(processIdFilter);

    if (procFsStatus != null && procFsStat != null) {
      //   // procFsStat.comm
      final processName = LinuxInterop.getUntruncatedProcessName(procFsStat);

      final pi = ProcessInfo(
        processId: procFsStatus.pid,
        processName: processName,
        basePriority: procFsStat.nice,
        sessionId: procFsStat.session,
        poolPagedBytes: procFsStatus.vmSwap,
        virtualBytes: procFsStatus.vmSize,
        virtualBytesPeak: procFsStatus.vmPeak,
        workingSetPeak: procFsStatus.vmHWM,
        workingSet: procFsStatus.vmRSS,
        pageFileBytes: procFsStatus.vmSwap,
        privateBytes: procFsStatus.vmData,
        numberOfThreads: procFsStatus.threads,
        poolNonPagedBytes: -1,
        pageFileBytesPeak: -1,
        handleCount: handleCount,
      );
      return pi;
    }

    return null;
  }

  /// Gets the time the associated process was started.
  /// get the number of seconds elapsed since the Unix epoch (1970-01-01T00:00:00Z) when a process has started
  /// get startTimeTicks from /proc/<pid>/stat
  /// Return -1 on error
  Future<double> startTimeCore(int pid) async {
    final _stat = await LinuxInterop.tryReadStatFile(pid);
    if (_stat == null) {
      return -1;
    }

    // O tempo de início está em jiffies, converta para segundos.
    // This value is located in /proc/[PID]/stat. The time difference (in jiffies)
    // between system boot and when the process started. (The 22nd value in the file if you split on whitespace).
    final startTime = _stat.starttime;   

    // gettimeofday()  timeval sec
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
    final now = currentTime;
    final hertz = LinuxInterop.sysconf(LinuxConst.SC_CLK_TCK);
    final uptime = await getBootTime();
    final bootTime = currentTime - uptime;

    //Process_Time = (current_time - boot_time) - (process_start_time)/HZ.
    final processTime = (now - bootTime) - (startTime / hertz);
    return processTime;
  }

  Future<double> totalProcessorTimeAsTotalSeconds(int processId) async {
    final _stat = await LinuxInterop.tryReadStatFile(processId);
    if (_stat != null) {
      final ticks = _stat.utime + _stat.stime;
      return ticks / 100;
    }
    return -1;
  }

  /// Gets the amount of time the associated process has spent utilizing the CPU.
  /// with greater precision
  /// Return -1 on error
  Future<double> totalProcessorTimeAsTotalMilliseconds(int processId) async {
    final _stat = await LinuxInterop.tryReadStatFile(processId);
    if (_stat != null) {
      final ticks = _stat.utime + _stat.stime;
      return ticks * 10;
    }
    return -1;
  }

  /// get Size from /proc/3204/smaps
  /// process_virtual_memory_bytes | VirtualMemorySize64
  /// Return -1 on error
  Future<int> getProcessVirtualMemoryBytesFromSmaps(int pid) async {
    final _smapsFileLines = await LinuxInterop.getSmapsAsLines(pid);
    if (_smapsFileLines.isEmpty) {
      // throw FileSystemException(
      //     'Process not found', 'File not found: ${smapsFile.path} | $pid');
      return -1;
    }
    //procstat_getvmmap
    //https://forums.freebsd.org/threads/how-to-get-virtual-memory-size-of-current-process-in-c-c.87022/

    int virtualMemoryBytes = 0;

    for (var line in _smapsFileLines) {
      if (line.startsWith('Size:')) {
        final parts = line.split(':');
        if (parts.length == 2) {
          final sizeInKilobytes = int.tryParse(parts[1].removeLast(2).trim());
          if (sizeInKilobytes != null) {
            virtualMemoryBytes += sizeInKilobytes * 1024; // Convert to bytes
          }
        }
      }
    }
    return virtualMemoryBytes;
  }

  /// get Rss from smap file '/proc/$pid/smaps'
  Future<int> getProcessWorkingSetBytesFromSmaps(int pid) async {
    final _smapsFileLines = await LinuxInterop.getSmapsAsLines(pid);
    if (_smapsFileLines.isEmpty) {
      // throw FileSystemException(
      //     'Process not found', 'File not found: ${smapsFile.path} | $pid');
      return -1;
    }

    int workingSetBytes = 0;
    for (final line in _smapsFileLines) {
      if (line.startsWith('Rss:')) {
        final parts = line.split(':');
        if (parts.length == 2) {
          final sizeInKilobytes = int.tryParse(parts[1].removeLast(2).trim());
          if (sizeInKilobytes != null) {
            workingSetBytes += sizeInKilobytes * 1024; // Convert to bytes
          }
        }
      }
    }

    return workingSetBytes;
  }

  /// by sampling
  Future<double> getProcessCpuUsageBySample(int pid,
      {int millisecondsInterval = 500}) async {
    double result = 0;
    try {
      final sample1 = CpuSample(
          await totalProcessorTimeAsTotalMilliseconds(pid), DateTime.now());
      await Future.delayed(Duration(milliseconds: millisecondsInterval));
      final sample2 = CpuSample(
          await totalProcessorTimeAsTotalMilliseconds(pid), DateTime.now());

      double usage = (sample1.totalProcessorTime - sample2.totalProcessorTime) /
          sample1.time.difference(sample2.time).inMilliseconds /
          processorCount;

      result = usage * 100;
    } catch (ex) {
      print('getProcessCpuUsageBySample $ex');
    }
    return result;
  }

  /// get uptime in seconds from /proc/uptime
  ///  system BootTime
  Future<double> getBootTime() async {
    //This file contains two numbers: the uptime of the system (seconds),
    //and the amount of time spent in idle process (seconds). Take the first.
    final uptimeContents = await LinuxInterop.getUptimeFileAsString();
    if (uptimeContents == null) {
      return -1;
    }
    final parts = uptimeContents.split(' ');
    final uptime = parts.first;
    return double.parse(uptime);
  }

  Future<DateTime> getBootDateTime() async {
    final uptime = await getBootTime();
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
    final bootTime = currentTime - uptime;
    return DateTime.fromMillisecondsSinceEpoch((bootTime * 1000).toInt());
  }

  /// get VmSize in bytes
  /// Return -1 on error
  Future<int> getVirtualMemorySize(int pid) async {
    final status = await LinuxInterop.tryReadStatusFile(pid);
    if (status == null) {
      return -1;
    }
    return status.vmSize;
  }

  /// get VmRSS in bytes
  /// process working set bytes
  /// WorkingSet64
  /// Return -1 on error
  Future<int> getWorkingSet(int pid) async {
    final status = await LinuxInterop.tryReadStatusFile(pid);
    if (status == null) {
      return -1;
    }
    return status.vmRSS;
  }

  /// get process num threads from /proc/$pid/task dir count
  /// Return -1 on error
  Future<int> getTotalThreadsByTaskFile(int pid) async {
    try {
      final taskDir =
          dartio.Directory(LinuxInterop.getTaskDirectoryPathForProcess(pid));
      //'/proc/$pid/task');

      final threadCount =
          taskDir.list().where((entry) => entry is dartio.Directory).length;
      // int threadCount = 0;
      // await for (var entry in entries) {
      //   if (entry is dartio.Directory) {
      //     threadCount++;
      //   }
      // }
      return threadCount;
    } catch (e) {
      return -1;
    }
  }

  /// using /proc/$pid/statusfile
  /// Return -1 on error
  /// Return 0 if "Threads" information is not found.
  Future<int> getTotalThreadsByStatus(int pid) async {
    final status = await LinuxInterop.tryReadStatusFile(pid);
    if (status == null) {
      return -1;
    }
    return status.threads;
  }

  /// like "ls /proc/2766/fd/ | wc -l"
  /// Return -1 on error
  Future<int> getOpenFileDescriptorsCount(int pid) async {
    try {
      final fdDirectory = dartio.Directory(
          LinuxInterop.getFileDescriptorDirectoryPathForProcess(pid));
      return await fdDirectory
          .list(recursive: false, followLinks: false)
          .length;
    } catch (e) {
      return -1;
    }
  }

  /// PrivateBytes = (long)procFsStatus.VmData,
  Future<int> getProcessPrivateMemoryBytes(int pid) async {
    final status = await LinuxInterop.tryReadStatusFile(pid);
    if (status != null) {
      var count = status.vmData + status.vmStk;

      return count * 1024;
    }
    return -1;
  }

  /// from /proc/<pid>/stat
  /// Return -1 on error
  Future<double> getProcessCpuUsage(int pid) async {
    final statContents = await LinuxInterop.tryReadStatFile(pid);
    if (statContents == null) {
      return -1;
    }

    try {
      // Extract the required values for calculation
      final utime = statContents.utime;
      final stime = statContents.stime;
      final startTime = statContents.starttime;
      final uptime = await getBootTime();

      // Calculate the total time the process has been running
      final totalTime = utime + stime;

      // Calculate the elapsed time since the process started
      final elapsedTime =
          uptime - (startTime / LinuxInterop.sysconf(LinuxConst.SC_CLK_TCK));

      // Calculate the CPU usage as a percentage
      final cpuUsage = (totalTime /
              LinuxInterop.sysconf(LinuxConst.SC_CLK_TCK) /
              elapsedTime) *
          100.0;

      return cpuUsage / processorCount;
    } catch (ex) {
      print('getProcessCpuUsage $ex');
    }
    return -1;
  }

  /// get number of processors of platform
  int get processorCount {
    return dartio.Platform.numberOfProcessors;
  }
}
