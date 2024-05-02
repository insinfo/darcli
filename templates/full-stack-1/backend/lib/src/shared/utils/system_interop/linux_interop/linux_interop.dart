// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

import '../string_parser.dart';
import '../time_span.dart';

final _libc = ffi.DynamicLibrary.open('/lib/x86_64-linux-gnu/libc.so.6');



//https://github.com/prom-client-net/prom-client/blob/main/src/Prometheus.Client/Collectors/ProcessStats/ProcessCollector.cs
//https://github.com/dotnet/runtime/blob/fe043b489f69a888ad2efd97fbc177c1f25e541d/src/libraries/System.Diagnostics.Process/ref/System.Diagnostics.Process.cs#L118

/// all in kilobytes
class ParsedStatus {
  int pid = 0;

  /// VmHWM: Peak resident set size ("high water mark").
  int vmHWM = 0;

  /// VmRSS Working Set |  Resident set size.
  int vmRSS = 0;

  /// Private Bytes | VmData, VmStk, VmExe: Size of data, stack, and text segments.
  int vmData = 0;

  /// Page File Bytes | PoolPagedBytes
  int vmSwap = 0;

  ///  VmSize: Virtual memory size.
  int vmSize = 0;

  /// VmPeak: Peak virtual memory size.
  int vmPeak = 0;
  int vmStk = 0;
  int threads = 0;
  //VmLck: Locked memory size (see mlock(3)).

  @override
  String toString() {
    return '''ParsedStatus{pid=$pid,vmHWM=$vmHWM},vmRSS=$vmRSS,vmData=$vmData,vmSwap=$vmSwap,vmSize=$vmSize,vmPeak=$vmPeak,vmStk=$vmStk}''';
  }
}

// ProcessId = pid,
// ProcessName = processName ?? Process.GetUntruncatedProcessName(ref procFsStat) ?? string.Empty,
// BasePriority = (int)procFsStat.nice,
// SessionId = procFsStat.session,
// PoolPagedBytes = (long)procFsStatus.VmSwap,
// VirtualBytes = (long)procFsStatus.VmSize,
// VirtualBytesPeak = (long)procFsStatus.VmPeak,
// WorkingSetPeak = (long)procFsStatus.VmHWM,
// WorkingSet = (long)procFsStatus.VmRSS,
// PageFileBytes = (long)procFsStatus.VmSwap,
// PrivateBytes = (long)procFsStatus.VmData,
class ParsedStat {
  /// ProcessId
  int pid = 0;
  String comm = '';
  String state = '';
  int ppid = 0;
  int session = 0;
  int utime = 0;
  int stime = 0;

  /// BasePriority
  int nice = 0;
  int starttime = 0;
  int vsize = 0;
  int rss = 0;
  BigInt rsslim = BigInt.zero;

  @override
  String toString() {
    return '''ParsedStat{pid=$pid,comm=$comm,state=$state,ppid=$ppid,session=$session,utime=$utime,stime=$stime}''';
  }
}

extension RemoveLastStringExtension on String {
  String removeLast(int size) {
    return substring(0, length - size);
  }
}

class CpuSample {
  final double totalProcessorTime;
  final DateTime time;
  CpuSample(this.totalProcessorTime, this.time);
}

class LinuxInterop {
  static const String rootPath = "/proc/";
  static const String statusFileName = "/status";

  static const String procfsRootPath = "/proc";
  static const String exeFileName = "/exe";
  static const String cmdLineFileName = "/cmdline";
  static const String statFileName = "/stat";
  static const String fileDescriptorDirectoryName = "/fd/";
  static const String taskDirectoryName = "/task/";

// Um único tique representa cem nanossegundos ou um décimo milionésimo de segundo.
//Existem 10.000 ticks em um milissegundo (veja TicksPerMillisecond) e 10 milhões de ticks em um segundo.
// O valor desta propriedade representa o número de intervalos de 100 nanossegundos
//decorridos desde 12h00min00 da meia-noite de 1º de janeiro de 0001 no
//calendário gregoriano, que representa MinValue.
//Não inclui o número de ticks atribuíveis aos segundos bissextos.

  static const int ticksPerMicrosecond = 10;

  /// Represents the number of ticks in 1 millisecond. This field is constant.
  /// The value of this constant is 10 thousand; that is, 10,000.
  static const int ticksPerMillisecond = ticksPerMicrosecond * 1000;
  static const int ticksPerSecond = ticksPerMillisecond * 1000; // 10,000,000
  static const int ticksPerMinute = ticksPerSecond * 60; // 600,000,000
  static const int ticksPerHour = ticksPerMinute * 60; // 36,000,000,000
  static const int ticksPerDay = ticksPerHour * 24; // 864,000,000,000

  /// get top int max value 9223372036854775807
  static const int intMaxValue = 9223372036854775807; //0x7fffffffffffffff;

  /// get top int min value -9223372036854775808
  static const int intMinValue = -9223372036854775808; //0x8000000000000000;

  //https://github.com/prom-client-net/prom-client/blob/main/src/Prometheus.Client/Collectors/DotNetStats/GCCollectionCountCollector.cs
  //https://github.com/dart-lang/sdk/blob/main/pkg/vm_service/example/vm_service_tester.dart
  //https://github.com/dart-lang/sdk/issues/53831#issuecomment-1778718498

  /// Gets the amount of time the associated process has spent running code
  /// inside the application portion of the process (not the operating system core).
  /// return -1 on error
  static Future<int> userProcessorTime(int processId) async {
    final stat = await tryReadStatFile(processId);
    if (stat != null) {
      return stat.utime;
    }
    return -1;
  }

  /// Gets the time the associated process was started.
  /// Return -1 on error
  static Future<int> privilegedProcessorTime(int processId) async {
    final stat = await tryReadStatFile(processId);
    if (stat != null) {
      return stat.stime;
    }
    return -1;
  }

  /// This file contains two numbers: the uptime of the system (seconds),
  /// and the amount of time spent in idle process (seconds). Take the first.
  static Future<String?> getUptimeFileAsString() async {
    try {
      final uptimeFile = File('/proc/uptime');
      return await uptimeFile.readAsString();
    } catch (e) {
      return null;
    }
  }

  /// Rss in bytes

  static Future<int> getRssFromSmapsRollup(int pid) async {
    final smapsRollupFile = File('/proc/$pid/smaps_rollup');
    if (!(await smapsRollupFile.exists())) {
      //print('The /proc/$pid/smaps_rollup file does not exist.');
      throw FileSystemException(
          'Process not found', 'File not found: ${smapsRollupFile.path}');
    }
    final lines = await smapsRollupFile.readAsLines();
    int privateMemorySize = 0;
    for (final line in lines) {
      if (line.contains('Rss:')) {
        final parts = line.split(':');
        if (parts.length == 2) {
          final val = parts[1].removeLast(2).trim();
          final rss = int.tryParse(val);
          if (rss != null) {
            privateMemorySize += rss * 1024;
          }
        }
      }
    }

    return privateMemorySize;
  }

  /// read /proc/$pid/smaps
  static Future<List<String>> getSmapsAsLines(int pid) async {
    try {
      final smapsFile = File('/proc/$pid/smaps');
      return await smapsFile.readAsLines();
    } catch (e) {
      return [];
    }
  }

  ///  awk '/^Pss:/ {pss+=$2} END {print pss}' < /proc/2766/smaps
  static Future<int> getPrivateMemorySize(int pid) async {
    final smapsFile = File('/proc/$pid/smaps');
    if (!smapsFile.existsSync()) {
      throw FileSystemException(
          'Process not found', 'File not found: ${smapsFile.path}');
    }

    final lines = await smapsFile.readAsLines();
    int privateMemorySize = 0;
    //int idx =0;
    for (var line in lines) {
      if (line.startsWith('Rss:')) {
        final parts = line.split(':');
        if (parts.length == 2) {
          final val = parts[1].removeLast(2).trim();
          final rss = int.tryParse(val);
          if (rss != null) {
            privateMemorySize += rss;
            //idx ++;
          }
        }
      }
    }

    return privateMemorySize;
  }

  /// get total linux CPU usage
  /// Return -1 on error
  static Future<double> totalCpuUsage({int millisecondsInterval = 500}) async {
    final file = File('/proc/stat');
    if (!(await file.exists())) {
      return -1;
    }

    try {
      final reader = await file.readAsString();
      final lines = await LineSplitter().convert(reader);

      if (lines.isNotEmpty) {
        final firstLine = lines.first;
        final toks = firstLine.split(' ');

        final idle1 = int.parse(toks[5]);
        final cpu1 = int.parse(toks[2]) +
            int.parse(toks[3]) +
            int.parse(toks[4]) +
            int.parse(toks[6]) +
            int.parse(toks[7]) +
            int.parse(toks[8]);

        await Future.delayed(Duration(milliseconds: millisecondsInterval));

        final newReader = await file.readAsString();
        final newLines = await LineSplitter().convert(newReader);

        if (newLines.isNotEmpty) {
          final newFirstLine = newLines.first;
          final newToks = newFirstLine.split(' ');

          final idle2 = int.parse(newToks[5]);
          final cpu2 = int.parse(newToks[2]) +
              int.parse(newToks[3]) +
              int.parse(newToks[4]) +
              int.parse(newToks[6]) +
              int.parse(newToks[7]) +
              int.parse(newToks[8]);

          final cpuUsage = (cpu2 - cpu1) / (cpu2 + idle2 - (cpu1 + idle1));
          return cpuUsage * 100;
        }
      }
    } catch (ex) {
      print('totalCpuUsage $ex');
    }
    return -1;
  }

  /// POSIX allows an application to test at compile or run time
  /// whether certain options are supported, or what the value is of
  /// certain configurable constants or limits.
  /// from libc
  /// The amount of time, measured in units of USER_HZ (1/100ths of a second on most
  /// architectures, use sysconf(_SC_CLK_TCK) to obtain the right value), that the system spent
  /// in user mode, user mode with low priority (nice), system mode, and the idle task,
  /// respectively. The last value should be USER_HZ times the second entry in the uptime
  /// pseudo-file.
  /// [parameter] LinuxConst
  static int sysconf(int parameter) {
    // /lib/x86_64-linux-gnu/libc.so.6
    if (!Platform.isLinux) {
      //throw Exception('Platform is not Linux');
      return -1;
    }

    //posix_sysconf
    // typedef posix_sysconf_func = ffi.Void Function();
    // typedef PosixSysconf = int Function();
    //Function: long int sysconf (int parameter)

    return _posix_sysconf(parameter);
  }

  static final int Function(int) _posix_sysconf = _libc
      .lookup<ffi.NativeFunction<ffi.Int64 Function(ffi.Int32)>>('sysconf')
      .asFunction();

  static Future<List<StatVirtualFileSystem>> getAllDiskMountsInfo(
      {bool all = false}) async {
    final FS_SPEC = 0;
    final FS_FILE = 1;

    final result = <StatVirtualFileSystem>[];
    final lines = await File('/proc/mounts').readAsLines();
    for (final line in lines) {
      final fields =
          line.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();

      if (!all && StatVirtualFileSystem.isVirtual(fields[FS_SPEC])) {
        continue;
      }

      final stat = statvfs(fields[FS_FILE]);
      final fsid = stat.filesystemId;
      if (result.where((item) => item.filesystemId == fsid).isNotEmpty) {
        continue;
      }

      stat.filesystem = fields[FS_SPEC];
      stat.mount = fields[FS_FILE];
      result.add(stat);
    }

    return result;
  }

  //int statvfs(const char *_restrict_ pathname, struct statvfs *_restrict_ fsinfo);
  static final int Function(ffi.Pointer<ffi.Uint8>, ffi.Pointer<_StatvfsStruct>)
      _posix_statvfs = _libc
          .lookup<
              ffi.NativeFunction<
                  ffi.Int32 Function(ffi.Pointer<ffi.Uint8>,
                      ffi.Pointer<_StatvfsStruct>)>>('statvfs')
          .asFunction();

  ///statvfs, fstatvfs - get filesystem statistics
  ///https://stackoverflow.com/questions/60666200/how-can-get-disk-usage-in-linux-using-c-program
  ///https://github.com/docker/for-mac/issues/2136
  static StatVirtualFileSystem statvfs(String path) {
    if (!Platform.isLinux) {
      //throw Exception('Platform is not Linux');
      return StatVirtualFileSystem.zero();
    }
    Pointer<_StatvfsStruct>? statvfsStructPointer;
    Pointer<Uint8>? pathPointer;
    try {
      statvfsStructPointer = calloc<_StatvfsStruct>();
      pathPointer = _toNativeUtf8(path, allocator: calloc);
      // ignore: unused_local_variable
      final ret = _posix_statvfs(pathPointer, statvfsStructPointer);
      //print('statvfsFunc ret $ret');
      final diskInfo = StatVirtualFileSystem(
        blockSize: statvfsStructPointer.ref.f_blocks,
        fragmentSize: statvfsStructPointer.ref.f_frsize,
        blocks: statvfsStructPointer.ref.f_blocks,
        blocksFree: statvfsStructPointer.ref.f_bfree,
        blocksAvailable: statvfsStructPointer.ref.f_bavail,
        files: statvfsStructPointer.ref.f_files,
        filesFree: statvfsStructPointer.ref.f_ffree,
        freeInodesAvailable: statvfsStructPointer.ref.f_favail,
        filesystemId: statvfsStructPointer.ref.f_fsid,
        flags: statvfsStructPointer.ref.f_flag,
        maximumNameLength: statvfsStructPointer.ref.f_namemax,
      );
      return diskInfo;
    } finally {
      if (statvfsStructPointer != null) {
        calloc.free(statvfsStructPointer);
      }
      if (pathPointer != null) {
        calloc.free(pathPointer);
      }
    }
  }

  static Pointer<ffi.Uint8> _toNativeUtf8(String val,
      {Allocator allocator = malloc}) {
    final units = utf8.encode(val);
    final Pointer<ffi.Uint8> result = allocator<ffi.Uint8>(units.length + 1);
    final nativeString = result.asTypedList(units.length + 1);
    nativeString.setAll(0, units);
    nativeString[units.length] = 0;
    return result.cast();
  }

  /// Gets the amount of time the associated process has spent utilizing the CPU.
  /// with less precision
  static Future<TimeSpan?> totalProcessorTime(int pid) async {
    final stat = await tryReadStatFile(pid);
    if (stat == null) {
      return null;
    }
    final ticks = stat.utime + stat.stime;
    final value = ticks / (ticksPerSecond.toDouble());

    final scale = ticksPerSecond;
    final doubleTicks = value * scale;
    final result = TimeSpan.timeSpanFromDoubleTicks(doubleTicks);
    //print( 'totalProcessorTime pid: $pid | utime: ${stat.utime} | stime: ${stat.stime} | ticks: ${ticks} | $result');
    return result;
  }

  /// Gets the amount of time the associated process has spent utilizing the CPU.
  /// with greater precision
  /// Return -1 on error

  static String getStatusFilePathForProcess(int pid) {
    return rootPath + pid.toString() + statusFileName;
  }

  static void uint8ListCopyTo(Uint8List source, Uint8List destination,
      [int destinationOffset = 0]) {
    if (destination.length - destinationOffset < source.length) {
      throw ArgumentError("Destination list is too small.");
    }

    for (int i = 0; i < source.length; i++) {
      destination[i + destinationOffset] = source[i];
    }
  }

  static void intListCopyTo(List<int> source, List<int> destination,
      [int destinationOffset = 0]) {
    if (destination.length - destinationOffset < source.length) {
      throw ArgumentError("Destination list is too small.");
    }

    for (int i = 0; i < source.length; i++) {
      destination[i + destinationOffset] = source[i];
    }
  }

  /// Gets the name that was used to start the process, or null if it could not be retrieved
  /// [stat] The stat for the target process
  static String getUntruncatedProcessName(ParsedStat stat) {
    String cmdLineFilePath = getCmdLinePathForProcess(stat.pid);

    try {
      final fs = File(cmdLineFilePath).openSync(mode: FileMode.read);
      var buffer = List.filled(512, 0);
      int bytesRead = 0;
      while (true) {
        // Resize buffer if it was too small.
        if (bytesRead == buffer.length) {
          int newLength = buffer.length * 2;
          var tmp = List.filled(newLength, 0);
          intListCopyTo(buffer, tmp);
          buffer = tmp;
        }
        assert(bytesRead < buffer.length);
        int n = fs.readIntoSync(buffer, bytesRead);
        bytesRead += n;

        // cmdline contains the argv array separated by '\0' bytes.
        // stat.comm contains a possibly truncated version of the process name.
        // When the program is a native executable, the process name will be in argv[0].
        // When the program is a script, argv[0] contains the interpreter, and argv[1] contains the script name.
        var argRemainder = buffer.sublist(0, bytesRead);

        int argEnd = argRemainder.indexOf(0);
        if (argEnd != -1) {
          // Check if argv[0] has the process name.
          String? name = getUntruncatedNameFromArg(
              argRemainder.sublist(0, argEnd), stat.comm);

          if (name != null) {
            fs.closeSync();
            return name;
          }
          // Check if argv[1] has the process name.
          argRemainder = argRemainder.sublist(argEnd + 1);
          argEnd = argRemainder.indexOf(0);
          if (argEnd != -1) {
            name = getUntruncatedNameFromArg(
                argRemainder.sublist(0, argEnd), stat.comm);
            fs.closeSync();
            return name ?? stat.comm;
          }
        }
        if (n == 0) {
          fs.closeSync();
          return stat.comm;
        }
      }
    } catch (e) {
      return stat.comm;
    }
  }

  static String? getUntruncatedNameFromArg(List<int> arg, String prefix) {
    // Strip directory names from arg.
    int nameStart = arg.lastIndexOf(47) + 1;
    String argString = utf8.decode(arg.sublist(nameStart));
    if (prefix.startsWith(argString, 0)) {
      return argString;
    } else {
      return null;
    }
  }

  static Future<ParsedStatus?> tryReadStatusFile(int pid) async {
    final filePath = getStatusFilePathForProcess(pid);

    final fileContents = await tryReadFile(filePath);

    if (fileContents == null) {
      // Handle error
      return null;
    }

    final results = ParsedStatus();
    final lines = LineSplitter.split(fileContents);
    for (String line in lines) {
      final parts = line.split(':');
      if (parts.length != 2) {
        continue;
      }

      final name = parts[0].trim();
      final value = parts[1].trim();
      int? valueParsed;
      switch (name) {
        case "Pid":
          results.pid = int.parse(value);
          break;
        case "VmHWM":
          //value.replaceAll(" kB", "")
          results.vmHWM = int.parse(value.removeLast(3));
          break;
        case "VmRSS":
          results.vmRSS = int.parse(value.removeLast(3));
          break;
        case "VmData":
          valueParsed = int.tryParse(value.removeLast(3)) ?? -1;
          if (valueParsed != -1) {
            results.vmData += valueParsed;
            //results.vmData = valueParsed;
          }
          break;
        case "VmSwap":
          valueParsed = int.tryParse(value.removeLast(3)) ?? -1;
          //if (valueParsed != -1) {
          results.vmSwap = valueParsed;
          // }
          break;
        case "VmSize":
          valueParsed = int.tryParse(value.removeLast(3)) ?? -1;
          //if (valueParsed != -1) {
          results.vmSize = valueParsed;
          //}
          break;
        case "VmPeak":
          valueParsed = int.tryParse(value.removeLast(3)) ?? -1;
          //if (valueParsed != -1) {
          results.vmPeak = valueParsed;
          // }
          break;
        case "VmStk":
          valueParsed = int.tryParse(value.removeLast(3)) ?? -1;
          if (valueParsed != -1) {
            results.vmData += valueParsed;
          }
          results.vmStk = valueParsed;
          break;
        case "Threads":
          valueParsed = int.tryParse(value) ?? -1;
          results.threads = valueParsed;
          break;
      }
    }

    // Convert sizes from kilobytes to bytes
    results.vmData *= 1024;
    results.vmPeak *= 1024;
    results.vmSize *= 1024;
    results.vmSwap *= 1024;
    results.vmRSS *= 1024;
    results.vmHWM *= 1024;

    return results;
  }

  static Future<String?> tryReadFile(String filePath) async {
    try {
      final file = File(filePath);
      return file.readAsString();
    } catch (e) {
      // Handle file read error
      //throw Exception('Status file read error');
      return null;
    }
  }

  /// GetCmdLinePathForProcess
  /// https://github.com/dotnet/runtime/blob/f66c1c15409ff505ba55f8fdf86bc5c041bf47a3/src/libraries/Common/src/Interop/Linux/procfs/Interop.ProcFsStat.cs#L77
  static String getExeFilePathForProcess(int pid) =>
      "$procfsRootPath/$pid$exeFileName";

  static String getCmdLinePathForProcess(int pid) =>
      "$procfsRootPath/$pid$cmdLineFileName";

  static String getStatFilePathForProcess(int pid) =>
      "$procfsRootPath/$pid$statFileName";

  /// get /proc/$pid/task
  static String getTaskDirectoryPathForProcess(int pid) =>
      "$procfsRootPath/$pid$taskDirectoryName";

  static String getFileDescriptorDirectoryPathForProcess(int pid) =>
      "$procfsRootPath/$pid$fileDescriptorDirectoryName";

  static String getStatFilePathForThread(int pid, int tid) =>
      "$procfsRootPath/$pid$taskDirectoryName/$tid$statFileName";

  static Future<ParsedStat?> tryReadStatFile(int pid) async {
    final result = await tryParseStatFile(getStatFilePathForProcess(pid));
    assert(result != null || result?.pid == pid,
        "Expected process ID from stat file to match supplied pid");
    return result;
  }

  static Future<ParsedStat?> tryReadStatFileForThread(int pid, int tid) async {
    var result = await tryParseStatFile(getStatFilePathForThread(pid, tid));
    assert(result != null || result?.pid == tid,
        "Expected thread ID from stat file to match supplied tid");
    return result;
  }

  static Future<ParsedStat?> tryParseStatFile(String statFilePath) async {
    final statFileContents = await tryReadFile(statFilePath);
    if (statFileContents == null) {
      // Between the time that we get an ID and the time that we try to read the associated stat
      // file(s), the process could be gone.
      return null;
    }

    final results = ParsedStat();
    final parser = StringParser(statFileContents, ' ');

    results.pid = parser.parseNextInt32();
    results.comm = parser.moveAndExtractNextInOuterParens();
    results.state = parser.parseNextChar();
    results.ppid = parser.parseNextInt32();
    parser.moveNextOrFail(); // pgrp
    results.session = parser.parseNextInt32();
    parser.moveNextOrFail(); // tty_nr
    parser.moveNextOrFail(); // tpgid
    parser.moveNextOrFail(); // flags
    parser.moveNextOrFail(); // majflt
    parser.moveNextOrFail(); // cmagflt
    parser.moveNextOrFail(); // minflt
    parser.moveNextOrFail(); // cminflt
    results.utime = parser.parseNextUInt64();
    results.stime = parser.parseNextUInt64();
    parser.moveNextOrFail(); // cutime
    parser.moveNextOrFail(); // cstime
    parser.moveNextOrFail(); // priority
    results.nice = parser.parseNextInt64();
    parser.moveNextOrFail(); // num_threads
    parser.moveNextOrFail(); // itrealvalue
    results.starttime = parser.parseNextUInt64();
    results.vsize = parser.parseNextUInt64();
    results.rss = parser.parseNextInt64();
    results.rsslim = parser.parseNextBigInt();

    // The following lines are commented out as there's no need to parse through
    // the rest of the entry (we've gotten all of the data we need).  Should any
    // of these fields be needed in the future, uncomment all of the lines up
    // through and including the one that's needed.  For now, these are being left
    // commented to document what's available in the remainder of the entry.

    //parser.MoveNextOrFail(); // startcode
    //parser.MoveNextOrFail(); // endcode
    //parser.MoveNextOrFail(); // startstack
    //parser.MoveNextOrFail(); // kstkesp
    //parser.MoveNextOrFail(); // kstkeip
    //parser.MoveNextOrFail(); // signal
    //parser.MoveNextOrFail(); // blocked
    //parser.MoveNextOrFail(); // sigignore
    //parser.MoveNextOrFail(); // sigcatch
    //parser.MoveNextOrFail(); // wchan
    //parser.MoveNextOrFail(); // nswap
    //parser.MoveNextOrFail(); // cnswap
    //parser.MoveNextOrFail(); // exit_signal
    //parser.MoveNextOrFail(); // processor
    //parser.MoveNextOrFail(); // rt_priority
    //parser.MoveNextOrFail(); // policy
    //parser.MoveNextOrFail(); // delayacct_blkio_ticks
    //parser.MoveNextOrFail(); // guest_time
    //parser.MoveNextOrFail(); // cguest_time
    return results;
  }
}

//https://github.com/lattera/glibc/blob/895ef79e04a953cac1493863bcae29ad85657ee1/posix/sys/types.h#L226
//https://github.com/lattera/glibc/blob/895ef79e04a953cac1493863bcae29ad85657ee1/sysdeps/unix/sysv/linux/x86/bits/typesizes.h#L58
//typedef __fsblkcnt64_t fsblkcnt_t; /* Type to count file system blocks.  */
//#define __FSBLKCNT_T_TYPE	__SYSCALL_ULONG_TYPE
// typedef ulong_t		fsblkcnt_t;	/* count of file system blocks */  <typedef:fsblkcnt_t>
// typedef u64 = int;
// typedef fsblkcnt_t = u64;
// typedef  fsfilcnt_t = u64;
// fsblkcnt_t long unsigned int
//https://github.com/samba-team/samba/blob/master/source3/smbd/statvfs.c
//  statbuf->OptimalTransferSize = statvfs_buf.f_bsize;
// 	statbuf->BlockSize = statvfs_buf.f_frsize;
// 	statbuf->TotalBlocks = statvfs_buf.f_blocks;
// 	statbuf->BlocksAvail = statvfs_buf.f_bfree;
// 	statbuf->UserBlocksAvail = statvfs_buf.f_bavail;
// 	statbuf->TotalFileNodes = statvfs_buf.f_files;
// 	statbuf->FreeFileNodes = statvfs_buf.f_ffree;
// 	statbuf->FsIdentifier = statvfs_buf.f_fsid;
//https://github.com/lattera/glibc/blob/master/bits/statvfs.h
// struct statvfs64
//   {
//     unsigned long int f_bsize;
//     unsigned long int f_frsize;
//     __fsblkcnt64_t f_blocks;
//     __fsblkcnt64_t f_bfree;
//     __fsblkcnt64_t f_bavail;
//     __fsfilcnt64_t f_files;
//     __fsfilcnt64_t f_ffree;
//     __fsfilcnt64_t f_favail;
//     __fsid_t f_fsid;
//     unsigned long int f_flag;
//     unsigned long int f_namemax;
//     unsigned int f_spare[6];
//   };
final class _StatvfsStruct extends ffi.Struct {
  /// unsigned long int file system block size
  @UnsignedLong()
  external int f_bsize;

  /// unsigned long int fragment size
  @UnsignedLong()
  external int f_frsize;

  /// ulong_t | size of fs in f_frsize units
  @UnsignedLong()
  external int f_blocks;

  /// ulong_t | free blocks
  @UnsignedLong()
  external int f_bfree;

  /// ulong_t | free blocks for unprivileged users
  @UnsignedLong()
  external int f_bavail;

  /// ulong_t | inodes
  @UnsignedLong()
  external int f_files;

  /// ulong_t | free inodes
  @UnsignedLong()
  external int f_ffree;

  /// ulong_t | free inodes for unprivileged users
  @UnsignedLong()
  external int f_favail;

  /// unsigned long | file system ID
  @UnsignedLong()
  external int f_fsid;

  /// unsigned long int | mount flags
  @UnsignedLong()
  external int f_flag;

  /// unsigned long int | maximum filename length
  @UnsignedLong()
  external int f_namemax;

  //unsigned int f_spare[6];
  @Array(6)
  external Array<Uint32> f_spare;
}

class StatVirtualFileSystem {
  /// file system block size
  /// f_bsize get the file system block size
  /// Optimal transfer block size
  int blockSize;

  /// fragment size
  /// f_frsize | Get the fundamental file system block size
  /// fragmentSize isn't guaranteed to be supported use:
  /// var blocksize = info.fragmentSize != 0 ? info.fragmentSize  : info.blockSize;
  int fragmentSize;

  /// f_blocks | size of fs in f_frsize units
  /// Total data blocks in filesystem
  int blocks;

  /// Free blocks in filesystem
  /// f_bfree | free blocks
  int blocksFree;

  /// free blocks for unprivileged users
  /// Free blocks available to unprivileged user
  /// f_bavail | blocks_available
  int blocksAvailable;

  /// f_files | inodes
  /// Total file nodes in filesystem
  int files;

  /// Free file nodes in filesystem
  /// f_ffree  | free inodes
  int filesFree;

  /// f_favail | free inodes for unprivileged users
  int freeInodesAvailable;

  /// Filesystem ID
  /// f_fsid | file system ID
  int filesystemId;

  /// mount flags
  /// f_flag | Get the mount flags
  int flags;

  /// maximum filename length
  /// f_namemax | Maximum length of filenames
  int maximumNameLength;

  /// Mounted on
  String mount;

  /// Filesystem
  String filesystem;

  StatVirtualFileSystem({
    required this.blockSize,
    required this.fragmentSize,
    required this.blocks,
    required this.blocksFree,
    required this.blocksAvailable,
    required this.files,
    required this.filesFree,
    required this.freeInodesAvailable,
    required this.filesystemId,
    required this.flags,
    required this.maximumNameLength,
    this.mount = '',
    this.filesystem = '',
  });

  factory StatVirtualFileSystem.zero() {
    return StatVirtualFileSystem(
      blockSize: 0,
      fragmentSize: 0,
      blocks: 0,
      blocksFree: 0,
      blocksAvailable: 0,
      files: 0,
      filesFree: 0,
      freeInodesAvailable: 0,
      filesystemId: 0,
      flags: 0,
      maximumNameLength: 0,
      mount: '',
      filesystem: '',
    );
  }

  /// available size of disk in bytes
  int free() => (blocksAvailable * fragmentSize);

  int freeWithReserved() => (blocksFree * fragmentSize);

  /// total size of disk in bytes
  int total() => (blocks * fragmentSize);

  /// Used add reserved in bytes
  int usedWithReserved() => total() - free();

  /// Used subtracted reserved for root
  /// espaço usado sem contar o espaço reservado 
  /// final used = (info.blocks - info.blocksFree) * info.fragmentSize;
  int usedWithoutReserved() => (blocks - blocksFree) * fragmentSize;

  /// Used percent (%) subtracted reserved in bytes
  double percent() => (usedWithoutReserved() / total()) * 100;

  /// reserved size for root
  /// final reservedSize = total - (free + used);
  int reservedSize() => total() - (free() + usedWithoutReserved());

  /// total size of disk in bytes
  int diskSize() => blocks * fragmentSize;

  ///  fragmentSize isn't guaranteed to be supported.
  // int get guaranteedBlockSize => fragmentSize != 0 ? fragmentSize : blockSize;

  static bool isVirtual(String fs) {
    if (fs == "devtmpfs" || fs == "portal" || fs == "tmpfs") {
      return true;
    } else {
      return fs.startsWith("/dev/loop") || fs.startsWith("systemd-");
    }
  }

  /// pega um número inteiro não assinado de 64 bits ( u64) representando o
  /// tamanho do arquivo em bytes e retorna uma string formatada que
  /// representa o tamanho no formato de prefixo binário da
  /// Comissão Eletrotécnica Internacional (IEC).
  /// O formato de prefixo binário IEC é frequentemente usado
  /// para representar tamanhos de arquivos de uma forma
  /// legível por humanos, usando unidades como
  /// KiB (kibibytes), MiB (mebibytes), GiB (gibibytes)
  static String iec(int n) {
    final units = ['', 'k', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y'];

    final i = (log(n.toDouble()) / log(1024.0)).floor().toInt();
    final p = pow(1024.0, i.toDouble());
    final s = n / p.toDouble();

    return '${s.toStringAsFixed(0)}${units[i]}B';
  }

  /// valid VG/LV characters are: a-z A-Z 0-9 + _ . -
  /// we use this fact and replace -- with #
  /// split on - and then switch # back to -
  static String shortenLv(String path) {
    const String MARK = '#';
    if (path.startsWith('/dev/mapper/')) {
      final pathComponents = path.split('/');
      if (pathComponents.length > 3) {
        final lv = pathComponents[3].replaceAll("--", MARK);
        final lvVg = lv.split("-").map((x) => x.replaceAll(MARK, "-")).toList();
        return "/dev/${lvVg[0]}/${lvVg[1]}";
      }
    }
    return path;
  }

  // Extract the top bit of x as an int value.
  // int _extractTopBit(int x) {
  //   int bitWidth = 8 * Int64List.bytesPerElement;
  //   return x & (1 << (bitWidth - 1));
  // }

  // int _extractTopBit2(int x) {
  //   final int mask = (1 << (8 * 8 - 1));
  //   return x & mask;
  // }
}
