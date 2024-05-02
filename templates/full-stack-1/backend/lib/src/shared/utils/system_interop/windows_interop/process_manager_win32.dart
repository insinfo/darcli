import 'dart:ffi';
import '../ffi/allocation.dart';
import '../ffi/utf16_ffi.dart';
import '../process_info.dart';
import 'windows_interop.dart';

extension DateTimeExtensionToUnixTimeSeconds on DateTime {
  int toUnixTimeSeconds() {
    // Convert DateTime to Unix time in seconds
    final unixTimeSeconds = this.millisecondsSinceEpoch ~/ 1000;
    return unixTimeSeconds;
  }
}

class ProcessManagerWin32 {
  static const int defaultCachedBufferSize = 1024 * 1024;

  int mostRecentSize = defaultCachedBufferSize;

  int _getEstimatedBufferSize(int actualSize) => actualSize + 1024 * 10;

  ProcessInfo? getProcessInfo(
      {int? processIdFilter, String? processNameFilter}) {
    final procs = getProcessInfos(
        processIdFilter: processIdFilter, processNameFilter: processNameFilter);
    if (procs.isNotEmpty) {
      return procs.first;
    }
    return null;
  }

  Iterable<ProcessInfo> getProcessInfos(
      {int? processIdFilter, String? processNameFilter}) {
    Pointer<UnsignedLong> actualSize = malloc.allocate(sizeOf<UnsignedLong>());
    int bufferSize = mostRecentSize;
    int status = WindowsInterop.STATUS_INFO_LENGTH_MISMATCH;
    Pointer<SYSTEM_PROCESS_INFORMATION> bufferPtr = nullptr;
    // ignore: unused_local_variable
    var count = 0;
    while (true) {
      if (bufferPtr != nullptr) {
        WindowsInterop.VirtualFree(bufferPtr, 0x0, WindowsInterop.MEM_RELEASE);
      }

      bufferPtr = WindowsInterop.VirtualAlloc(
              nullptr,
              bufferSize,
              WindowsInterop.MEM_RESERVE | WindowsInterop.MEM_COMMIT,
              WindowsInterop.PAGE_READWRITE)
          .cast();

      // try to get the information details
      status = WindowsInterop.NtQuerySystemInformation(
          SYSTEM_INFORMATION_CLASS.SystemProcessInformation,
          bufferPtr.cast(),
          bufferSize,
          actualSize);

      // if success, break the loop and proceed to printing details
      // if different error than information length mismatch, exit prorgram with error message
      // if (status == WindowsInterop.STATUS_SUCCESS) {
      //   break;
      // }
      // else if (status != STATUS_INFO_LENGTH_MISMATCH) {
      //   WindowsInterop.VirtualFree(p, 0x0, WindowsInterop.MEM_RELEASE);
      //   p = nullptr;
      //   print("Error fetching details $dwStatus");
      //   return;
      // }

      if (status != WindowsInterop.STATUS_INFO_LENGTH_MISMATCH) {
        // see definition of NT_SUCCESS(Status) in SDK
        if (status < 0) {
          throw Exception('InvalidOperationException status: $status');
        }
        mostRecentSize = _getEstimatedBufferSize(actualSize.value);
        break;
      }

      // use the dwRet value and add extra 8kb buffer size
      // this will become handy when new processes are created while processing this loop
      //bufferSize = actualSize.value + (2 << 12);
      // allocating a few more kilo bytes just in case there are some new process
      // kicked in since new call to NtQuerySystemInformation
      bufferSize = _getEstimatedBufferSize(actualSize.value);

      // if (count == 1) {
      //   break;
      // }
      count++;
    }
    malloc.free(actualSize);

    final results = _getProcessInfos(bufferPtr.address,
        processIdFilter: processIdFilter, processNameFilter: processNameFilter);

    // do {
    //   final pid = bufferPtr.ref.UniqueProcessId;
    //   if (pid == 26928) {
    //     print(
    //         "pid: $pid | handles: ${bufferPtr.ref.HandleCount} | VSize: ${WindowsInterop.strFormatByteSizeW(bufferPtr.ref.VirtualSize)}");
    //     break;
    //   }
    //   bufferPtr = Pointer.fromAddress(
    //       bufferPtr.address + bufferPtr.ref.NextEntryOffset);
    // } while (bufferPtr.ref.NextEntryOffset != 0);

    // Free the process buffer
    WindowsInterop.VirtualFree(bufferPtr, 0x0, WindowsInterop.MEM_RELEASE);
    bufferPtr = nullptr;

    return results;
  }

  Iterable<ProcessInfo> _getProcessInfos(int pointerAddress,
      {int? processIdFilter, String? processNameFilter}) {
    final processInfos = Map<int, ProcessInfo>();
    var processInformationOffset = pointerAddress;
    Pointer<SYSTEM_PROCESS_INFORMATION> pi = nullptr;
    while (true) {
      pi = Pointer.fromAddress(processInformationOffset);

      final processId = pi.ref.UniqueProcessId;
      //print('while processId $processId');
      if (processIdFilter == null || processIdFilter == processId) {
        String? processName = null;

        var processNameSpan = pi.ref.ImageName.Buffer != nullptr
            ? _getProcessShortName(pi.ref.ImageName.Buffer
                .toDartString(length: pi.ref.ImageName.Length ~/ 2))
            : (processName = processId == systemProcessID
                ? "System"
                : processId == idleProcessID
                    ? "Idle"
                    : processId.toString());

        if (isNullOrEmpty(processNameFilter) ||
            processNameSpan.toLowerCase() == processNameFilter!.toLowerCase()) {
          processName ??= processNameSpan;

          // get information for a process
          final processInfo = ProcessInfo(
              numberOfThreads: pi.ref.NumberOfThreads,
              processName: processName,
              processId: processId,
              sessionId: pi.ref.SessionId,
              poolPagedBytes: pi.ref.QuotaPagedPoolUsage,
              poolNonPagedBytes: pi.ref.QuotaNonPagedPoolUsage,
              virtualBytes: pi.ref.VirtualSize,
              virtualBytesPeak: pi.ref.PeakVirtualSize,
              workingSetPeak: pi.ref.PeakWorkingSetSize,
              workingSet: pi.ref.WorkingSetSize,
              pageFileBytesPeak: pi.ref.PeakPagefileUsage,
              pageFileBytes: pi.ref.PagefileUsage,
              privateBytes: pi.ref.PrivatePageCount,
              basePriority: pi.ref.BasePriority,
              handleCount: pi.ref.HandleCount);
          processInfos[processInfo.processId] = processInfo;

          // get the threads for current process
          int threadInformationOffset =
              processInformationOffset + sizeOf<SYSTEM_PROCESS_INFORMATION>();

          for (int i = 0; i < pi.ref.NumberOfThreads; i++) {
            Pointer<SYSTEM_THREAD_INFORMATION> ti =
                Pointer.fromAddress(threadInformationOffset);

            final threadInfo = ThreadInfo(
              processId: ti.ref.ClientId.UniqueProcess,
              threadId: ti.ref.ClientId.UniqueThread,
              basePriority: ti.ref.BasePriority,
              currentPriority: ti.ref.Priority,
              startAddress: ti.ref.StartAddress,
              threadState: ThreadState.fromInt(ti.ref.ThreadState),
              threadWaitReason: getThreadWaitReason(ti.ref.WaitReason),
            );

            processInfo.threadInfoList.add(threadInfo);

            threadInformationOffset += sizeOf<SYSTEM_THREAD_INFORMATION>();
          }
        }
      }

      if (processIdFilter == processId) {
        //print('processIdFilter == processId');
        break;
      }

      if (pi.ref.NextEntryOffset == 0) {
        break;
      }
      processInformationOffset += pi.ref.NextEntryOffset;
    }

    /// free memory
    if (pi != nullptr) {
      WindowsInterop.VirtualFree(pi, 0x0, WindowsInterop.MEM_RELEASE);
      pi = nullptr;
    }

    return processInfos.values;
  }

  bool isNullOrEmpty(String? str) {
    return str == null || str.isEmpty;
  }

  // This function generates the short form of process name.
  //
  // This is from GetProcessShortName in NT code base.
  // Check base\screg\winreg\perfdlls\process\perfsprc.c for details.
  String _getProcessShortName(String nameP) {
    var name = nameP;
    // Trim off everything up to and including the last slash, if there is one.
    // If there isn't, LastIndexOf will return -1 and this will end up as a nop.
    // name = name.slice(name.lastIndexOf('\\') + 1);

    // If the name ends with the ".exe" extension, then drop it, otherwise include
    // it in the name.
    if (name.toLowerCase().endsWith('.exe')) {
      name = name.substring(0, name.length - 4);
    }

    return name;
  }

  ThreadWaitReason getThreadWaitReason(int value) {
    switch (value) {
      case 0:
      case 7:
        return ThreadWaitReason.Executive;
      case 1:
      case 8:
        return ThreadWaitReason.FreePage;
      case 2:
      case 9:
        return ThreadWaitReason.PageIn;
      case 3:
      case 10:
        return ThreadWaitReason.SystemAllocation;
      case 4:
      case 11:
        return ThreadWaitReason.ExecutionDelay;
      case 5:
      case 12:
        return ThreadWaitReason.Suspended;
      case 6:
      case 13:
        return ThreadWaitReason.UserRequest;
      case 14:
        return ThreadWaitReason.EventPairHigh;
      case 15:
        return ThreadWaitReason.EventPairLow;
      case 16:
        return ThreadWaitReason.LpcReceive;
      case 17:
        return ThreadWaitReason.LpcReply;
      case 18:
        return ThreadWaitReason.VirtualMemory;
      case 19:
        return ThreadWaitReason.PageOut;
      default:
        return ThreadWaitReason.Unknown;
    }
  }

  int get systemProcessID {
    const int systemProcessIDOnXP = 4;
    return systemProcessIDOnXP;
  }

  static const int idleProcessID = 0;

  double totalProcessorTimeAsTotalSeconds(int pid) {
    var hProcess = WindowsInterop.OpenProcess(
        WindowsInterop.PROCESS_QUERY_INFORMATION |
            WindowsInterop.PROCESS_VM_READ,
        WindowsInterop.FALSE,
        pid);

    if (hProcess == WindowsInterop.FALSE) {
      //print('failed to Get a handle to the process $hProcess');
      return -1;
    }

    //hProcess ??= GetCurrentProcess();

    final pCreationTime = calloc<FILETIME>();
    final pExitTime = calloc<FILETIME>();
    final pKernelTime = calloc<FILETIME>();
    final pUserTime = calloc<FILETIME>();
    // final pCreationTimeAsSystemTime = calloc<SYSTEMTIME>();
    //  final pExitTimeAsSystemTime = calloc<SYSTEMTIME>();
    final pKernelTimeAsSystemTime = calloc<SYSTEMTIME>();
    final pUserTimeAsSystemTime = calloc<SYSTEMTIME>();
    int result;

    try {
      // Retrieve timing information for the current process
      result = WindowsInterop.GetProcessTimes(
          hProcess, pCreationTime, pExitTime, pKernelTime, pUserTime);

      if (result == WindowsInterop.FALSE) {
        //throw Exception('Windows Exception');
        return -1;
      }

      // Convert process creation time to SYSTEMTIME format
      // result = interop.FileTimeToSystemTime(
      //     pCreationTime, pCreationTimeAsSystemTime);
      // if (result == FALSE) {
      //   return -1;
      // }

      result = WindowsInterop.FileTimeToSystemTime(
          pKernelTime, pKernelTimeAsSystemTime);
      if (result == WindowsInterop.FALSE) {
        return -1;
      }
      result =
          WindowsInterop.FileTimeToSystemTime(pUserTime, pUserTimeAsSystemTime);
      if (result == WindowsInterop.FALSE) {
        return -1;
      }

      // final processExited =
      //     pExitTime.ref.dwLowDateTime != 0 && pExitTime.ref.dwHighDateTime != 0;

      // if (processExited) {
      //   // Convert process exit time to SYSTEMTIME format
      //   result = interop.FileTimeToSystemTime(pExitTime, pExitTimeAsSystemTime);
      //   if (result == FALSE) {
      //
      //   }
      // }

      // final creationTime =
      //     interop.systemTimeToDateTime(pCreationTimeAsSystemTime.ref);

      // DateTime? exitTime;
      // if (processExited) {
      //   exitTime = interop.systemTimeToDateTime(pExitTimeAsSystemTime.ref);
      // }

      //  print('Process creation time: $creationTime');
      // print(processExited
      //     ? 'Process exit time: $exitTime'
      //     : 'Process has not exited!');
      final kerneTimeSeconds =
          WindowsInterop.fileTimeToSeconds(pKernelTime.ref);
      final userTimeSeconds = WindowsInterop.fileTimeToSeconds(pUserTime.ref);
      final totalProcessorSeconds = kerneTimeSeconds + userTimeSeconds;

      return totalProcessorSeconds;

      //print('Process kernel time: ${kerneTimeSeconds} seconds');
      // print('Process user time: ${userTimeSeconds} seconds');
    } finally {
      calloc.free(pCreationTime);
      calloc.free(pExitTime);
      calloc.free(pKernelTime);
      calloc.free(pUserTime);

      calloc.free(pKernelTimeAsSystemTime);
      calloc.free(pUserTimeAsSystemTime);

      WindowsInterop.CloseHandle(hProcess);
      // calloc.free(pCreationTimeAsSystemTime);
      // calloc.free(pExitTimeAsSystemTime);
    }
  }

  double startTimeCore(int pid) {
    final hProcess = WindowsInterop.OpenProcess(
        WindowsInterop.PROCESS_QUERY_INFORMATION |
            WindowsInterop.PROCESS_VM_READ,
        WindowsInterop.FALSE,
        pid);
    if (hProcess == WindowsInterop.FALSE) {
      return -1;
    }
    final pCreationTime = calloc<Uint64>();
    final pExitTime = calloc<Uint64>();
    final pKernelTime = calloc<Uint64>();
    final pUserTime = calloc<Uint64>();
    try {
      final status = WindowsInterop.GetProcessTimes2(
          hProcess, pCreationTime, pExitTime, pKernelTime, pUserTime);
      if (status == WindowsInterop.FALSE) {
        return -1;
      }
      // Convert FILETIME to seconds since Unix epoch (January 1, 1970)
      //final secondsSinceEpoch = (pCreationTime.value - 116444736000000000) / 10000000;
      return _convertWindowsTimeToUnixTime(pCreationTime.value);
    } finally {
      calloc.free(pCreationTime);
      calloc.free(pExitTime);
      calloc.free(pKernelTime);
      calloc.free(pUserTime);
      WindowsInterop.CloseHandle(hProcess);
    }
  }

  double _convertWindowsTimeToUnixTime(int input) {
    const TICKS_PER_SECOND = 10000000;
    const EPOCH_DIFFERENCE = 11644473600;
    double temp =
        input / TICKS_PER_SECOND; //convert from 100ns intervals to seconds;
    temp = temp - EPOCH_DIFFERENCE; //subtract number of seconds between epochs
    return temp;
  }

  /// Gets the time the associated process was started.
  DateTime? startTime(int pid) {
    final hProcess = WindowsInterop.OpenProcess(
        WindowsInterop.PROCESS_QUERY_INFORMATION |
            WindowsInterop.PROCESS_VM_READ,
        WindowsInterop.FALSE,
        pid);

    if (hProcess == WindowsInterop.FALSE) {
      //print('failed to Get a handle to the process $hProcess');
      return null;
    }

    final pCreationTime = calloc<FILETIME>();
    final pExitTime = calloc<FILETIME>();
    final pKernelTime = calloc<FILETIME>();
    final pUserTime = calloc<FILETIME>();
    final pCreationTimeAsSystemTime = calloc<SYSTEMTIME>();

    int result;

    try {
      // Retrieve timing information for the current process
      result = WindowsInterop.GetProcessTimes(
          hProcess, pCreationTime, pExitTime, pKernelTime, pUserTime);

      if (result == WindowsInterop.FALSE) {
        //throw Exception('Windows Exception');
        return null;
      }

      //Convert process creation time to SYSTEMTIME format
      result = WindowsInterop.FileTimeToSystemTime(
          pCreationTime, pCreationTimeAsSystemTime);
      if (result == WindowsInterop.FALSE) {
        return null;
      }
      return WindowsInterop.systemTimeToDateTime(pCreationTimeAsSystemTime.ref);
    } finally {
      calloc.free(pCreationTime);
      calloc.free(pExitTime);
      calloc.free(pKernelTime);
      calloc.free(pUserTime);
      calloc.free(pCreationTimeAsSystemTime);
      WindowsInterop.CloseHandle(hProcess);
    }
  }
}
