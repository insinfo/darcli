import 'dart:ffi';
import '../disk_info.dart';
import '../ffi/allocation.dart';
import '../ffi/utf16_ffi.dart';
import '../ffi/utf8_ffi.dart';

final _kernel32 = DynamicLibrary.open('kernel32.dll');
final _ntdll = DynamicLibrary.open('ntdll.dll');
//https://github.com/dart-windows/win32/blob/aa0f23190f77fdc357a56deed386a1fad82d6ee5/lib/src/types.dart#L24
typedef KPRIORITY = LONG;
typedef USHORT = Uint16;

// typedef unsigned long ULONG;
// typedef ULONG *PULONG;
typedef ULONG = Uint32;

/// typedef unsigned short WORD;
typedef WORD = Uint16;
typedef ATOM = WORD;
typedef BOOL = Uint32;
typedef BOOLEAN = BYTE;
typedef BYTE = Uint8;
typedef CHAR = Uint8;
typedef COLORREF = DWORD;
typedef DOUBLE = Double;

/// typedef unsigned long  DWORD;
typedef DWORD = Uint32;
typedef DWORD32 = Uint32;
typedef DWORD64 = Uint64;
typedef DWORDLONG = Uint64;
typedef ULONG_PTR = IntPtr;
typedef DWORD_PTR = ULONG_PTR;
//typedef SIZE_T = ULONG_PTR;
typedef FLOAT = Float;
typedef HANDLE = IntPtr;
//typedef void *PVOID;
typedef PVOID = Pointer<Void>;
//typedef SIZE_T = Size;
typedef HCALL = DWORD;
typedef HDC = IntPtr;
typedef HINSTANCE = IntPtr;
typedef HKEY = IntPtr;
typedef HMIDIIN = IntPtr;
typedef HMODULE = IntPtr;
typedef HMONITOR = IntPtr;
typedef HRESULT = LONG;
typedef HRGN = IntPtr;
typedef HSTRING = IntPtr;
typedef HWND = IntPtr;
typedef INT = Int32;
typedef INT16 = Int16;
typedef INT32 = Int32;
typedef INT64 = Int64;
typedef INT8 = Int8;
typedef INT_PTR = IntPtr;
//typedef LANGID = WORD;
typedef LCID = DWORD;
typedef LCTYPE = DWORD;
typedef LGRPID = DWORD;
typedef LONG = Int32;
typedef LONG32 = Int32;
typedef LONG64 = Int64;
typedef LONGLONG = Int64;
typedef LONG_PTR = IntPtr;
typedef LPBYTE = Pointer<BYTE>;
typedef LPARAM = LONG_PTR;
typedef LPSTR = Pointer<Utf8>;
typedef LPWSTR = Pointer<Utf16>;
typedef PWSTR = Pointer<Utf16>;
typedef LRESULT = LONG_PTR;
typedef NTSTATUS = Int32;
//typedef PSTR = Pointer<Utf8>;
///  3221225476

class ProcTime {
  int ctime = 0, etime = 0, ktime = 0, utime = 0;
  ProcTime({this.ctime = 0, this.etime = 0, this.ktime = 0, this.utime = 0});
}

class WindowsInterop {
  /// int STATUS_INFO_LENGTH_MISMATCH = 0xC0000004;
  static const int STATUS_INFO_LENGTH_MISMATCH = 0x0C0000004;
  static const int STATUS_SUCCESS = 0x0;

  static String strFormatByteSizeW(int sizeInBytes) {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes bytes';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(2)} KB';
    } else if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  // https://stackoverflow.com/questions/36029230
  /// Converts FILETIME format to seconds.
  static double fileTimeToSeconds(FILETIME fileTime) =>
      ((fileTime.dwHighDateTime << 32) + fileTime.dwLowDateTime) / 10E6;

  /// Constructs a DateTime from SYSTEMTIME format.
  static DateTime systemTimeToDateTime(SYSTEMTIME systemTime,
      {bool convertToLocalTimeZone = true}) {
    final dateTime = DateTime.utc(
      systemTime.wYear,
      systemTime.wMonth,
      systemTime.wDay,
      systemTime.wHour,
      systemTime.wMinute,
      systemTime.wSecond,
      systemTime.wMilliseconds,
    );
    return convertToLocalTimeZone ? dateTime.toLocal() : dateTime;
  }

  /// A zero value; used to represent an empty bitmask.
  static const NULL = 0;

  /// Boolean false value returned from the Win32 API
  static const FALSE = 0;

  /// Boolean true value returned from the Win32 API
  static const TRUE = 1;
// Process constants

  static const PROCESS_SET_QUOTA = 0x0100;
  static const PROCESS_SET_INFORMATION = 0x0200;
  static const PROCESS_QUERY_INFORMATION = 0x0400;
  static const PROCESS_SUSPEND_RESUME = 0x0800;
  static const PROCESS_QUERY_LIMITED_INFORMATION = 0x1000;
  static const PROCESS_SET_LIMITED_INFORMATION = 0x2000;

  static const PROCESS_CREATE_THREAD = 0x0002;
  static const PROCESS_SET_SESSIONID = 0x0004;
  static const PROCESS_VM_OPERATION = 0x0008;
  static const PROCESS_VM_READ = 0x0010;
  static const PROCESS_VM_WRITE = 0x0020;
  static const PROCESS_DUP_HANDLE = 0x0040;
  static const PROCESS_CREATE_PROCESS = 0x0080;

  /// 8192
  static const MEM_RESERVE = 0x00002000;

  /// 32768
  static const MEM_RELEASE = 0x00008000;

  /// 4096
  static const MEM_COMMIT = 0x00001000;

  /// 4
  static const PAGE_READWRITE = 0x04;

  /// Retrieves a pseudo handle for the current process.
  ///
  /// ```c
  /// HANDLE GetCurrentProcess();
  /// ```
  /// {@category kernel32}
  static int GetCurrentProcess() => _GetCurrentProcess();

  static final _GetCurrentProcess = _kernel32
      .lookupFunction<IntPtr Function(), int Function()>('GetCurrentProcess');

  /// Retrieves timing information for the specified process.
  ///
  /// ```c
  /// BOOL GetProcessTimes(
  ///   HANDLE hProcess,
  ///   LPFILETIME lpCreationTime,
  ///   LPFILETIME lpExitTime,
  ///   LPFILETIME lpKernelTime,
  ///   LPFILETIME lpUserTime
  /// );
  /// ```
  /// {@category kernel32}
  /// https://github.com/dotnet/runtime/blob/dd89eb7b277cd80663846fb43a0b9c32a587fde9/src/libraries/Common/src/Interop/Windows/Kernel32/Interop.GetProcessTimes.cs#L13
  /// https://github.com/dotnet/runtime/blob/dd89eb7b277cd80663846fb43a0b9c32a587fde9/src/libraries/Common/src/Interop/Windows/Kernel32/Interop.GetProcessTimes_IntPtr.cs#L13
  static int GetProcessTimes(
          int hProcess,
          Pointer<FILETIME> lpCreationTime,
          Pointer<FILETIME> lpExitTime,
          Pointer<FILETIME> lpKernelTime,
          Pointer<FILETIME> lpUserTime) =>
      _GetProcessTimes(
          hProcess, lpCreationTime, lpExitTime, lpKernelTime, lpUserTime);

  static final _GetProcessTimes = _kernel32.lookupFunction<
      Int32 Function(
          IntPtr hProcess,
          Pointer<FILETIME> lpCreationTime,
          Pointer<FILETIME> lpExitTime,
          Pointer<FILETIME> lpKernelTime,
          Pointer<FILETIME> lpUserTime),
      int Function(
          int hProcess,
          Pointer<FILETIME> lpCreationTime,
          Pointer<FILETIME> lpExitTime,
          Pointer<FILETIME> lpKernelTime,
          Pointer<FILETIME> lpUserTime)>('GetProcessTimes');

  static int GetProcessTimes2(
    int hProcess,
    Pointer<Uint64> lpCreationTime,
    Pointer<Uint64> lpExitTime,
    Pointer<Uint64> lpKernelTime,
    Pointer<Uint64> lpUserTime,
  ) =>
      _GetProcessTimes2(
        hProcess,
        lpCreationTime,
        lpExitTime,
        lpKernelTime,
        lpUserTime,
      );

  static final _GetProcessTimes2 = _kernel32.lookupFunction<
      Int32 Function(
          IntPtr hProcess,
          Pointer<Uint64> lpCreationTime,
          Pointer<Uint64> lpExitTime,
          Pointer<Uint64> lpKernelTime,
          Pointer<Uint64> lpUserTime),
      int Function(
        int hProcess,
        Pointer<Uint64> lpCreationTime,
        Pointer<Uint64> lpExitTime,
        Pointer<Uint64> lpKernelTime,
        Pointer<Uint64> lpUserTime,
      )>('GetProcessTimes');

  /// [path] "C:\\"
  static DiskInfo statvfs(String path) {
    final lpDirectoryName = path.toNativeUtf16();
    final lpFreeBytesAvailableToCaller = calloc<Uint64>();
    final lpTotalNumberOfBytes = calloc<Uint64>();
    final lpTotalNumberOfFreeBytes = calloc<Uint64>();
    try {
      final ret = WindowsInterop.GetDiskFreeSpaceExW(
          lpDirectoryName,
          lpFreeBytesAvailableToCaller,
          lpTotalNumberOfBytes,
          lpTotalNumberOfFreeBytes);

      if (ret == WindowsInterop.FALSE) {
        return DiskInfo.invalid();
      }
      //DiskInfo(this.total, this.available, this.used, this.usedPercentage);
      return DiskInfo(
        lpTotalNumberOfBytes.value,
        lpFreeBytesAvailableToCaller.value,
        lpTotalNumberOfFreeBytes.value,
      );
    } finally {
      calloc.free(lpDirectoryName);
      calloc.free(lpFreeBytesAvailableToCaller);
      calloc.free(lpTotalNumberOfBytes);
      calloc.free(lpTotalNumberOfFreeBytes);
    }
  }

  /// Retrieves information about the specified disk, including the amount of
  /// free space on the disk.
  ///
  /// ```c
  /// BOOL GetDiskFreeSpaceW(
  ///   LPCWSTR lpRootPathName,
  ///   LPDWORD lpSectorsPerCluster,
  ///   LPDWORD lpBytesPerSector,
  ///   LPDWORD lpNumberOfFreeClusters,
  ///   LPDWORD lpTotalNumberOfClusters
  /// );
  /// ```
  /// {@category kernel32}
  int GetDiskFreeSpaceW(
          Pointer<Utf16> lpRootPathName,
          Pointer<Uint32> lpSectorsPerCluster,
          Pointer<Uint32> lpBytesPerSector,
          Pointer<Uint32> lpNumberOfFreeClusters,
          Pointer<Uint32> lpTotalNumberOfClusters) =>
      _GetDiskFreeSpaceW(lpRootPathName, lpSectorsPerCluster, lpBytesPerSector,
          lpNumberOfFreeClusters, lpTotalNumberOfClusters);

  final _GetDiskFreeSpaceW = _kernel32.lookupFunction<
      Int32 Function(
          Pointer<Utf16> lpRootPathName,
          //unsigned long
          Pointer<Uint32> lpSectorsPerCluster,
          Pointer<Uint32> lpBytesPerSector,
          Pointer<Uint32> lpNumberOfFreeClusters,
          Pointer<Uint32> lpTotalNumberOfClusters),
      int Function(
          Pointer<Utf16> lpRootPathName,
          Pointer<Uint32> lpSectorsPerCluster,
          Pointer<Uint32> lpBytesPerSector,
          Pointer<Uint32> lpNumberOfFreeClusters,
          Pointer<Uint32> lpTotalNumberOfClusters)>('GetDiskFreeSpaceW');

//  BOOL GetDiskFreeSpaceExW(
//   [in, optional]  LPCWSTR         lpDirectoryName,
//   [out, optional] PULARGE_INTEGER lpFreeBytesAvailableToCaller,
//   [out, optional] PULARGE_INTEGER lpTotalNumberOfBytes,
//   [out, optional] PULARGE_INTEGER lpTotalNumberOfFreeBytes
//  );
  static int GetDiskFreeSpaceExW(
    Pointer<Utf16> lpDirectoryName,
    Pointer<Uint64> lpFreeBytesAvailableToCaller,
    Pointer<Uint64> lpTotalNumberOfBytes,
    Pointer<Uint64> lpTotalNumberOfFreeBytes,
  ) =>
      _GetDiskFreeSpaceExW(lpDirectoryName, lpFreeBytesAvailableToCaller,
          lpTotalNumberOfBytes, lpTotalNumberOfFreeBytes);

  static final _GetDiskFreeSpaceExW = _kernel32.lookupFunction<
      Int32 Function(
        Pointer<Utf16> lpDirectoryName,
        Pointer<Uint64> lpFreeBytesAvailableToCaller,
        Pointer<Uint64> lpTotalNumberOfBytes,
        Pointer<Uint64> lpTotalNumberOfFreeBytes,
      ),
      int Function(
        Pointer<Utf16> lpDirectoryName,
        Pointer<Uint64> lpFreeBytesAvailableToCaller,
        Pointer<Uint64> lpTotalNumberOfBytes,
        Pointer<Uint64> lpTotalNumberOfFreeBytes,
      )>('GetDiskFreeSpaceExW');

  /// Opens an existing local process object.
  ///
  /// ```c
  /// HANDLE OpenProcess(
  ///   DWORD dwDesiredAccess,
  ///   BOOL  bInheritHandle,
  ///   DWORD dwProcessId
  /// );
  /// ```
  /// {@category kernel32}
  static int OpenProcess(
          int dwDesiredAccess, int bInheritHandle, int dwProcessId) =>
      _OpenProcess(dwDesiredAccess, bInheritHandle, dwProcessId);

  static final _OpenProcess = _kernel32.lookupFunction<
      IntPtr Function(
          Uint32 dwDesiredAccess, Int32 bInheritHandle, Uint32 dwProcessId),
      int Function(int dwDesiredAccess, int bInheritHandle,
          int dwProcessId)>('OpenProcess');

  /// Closes an open object handle.
  ///
  /// ```c
  /// BOOL CloseHandle(
  ///   HANDLE hObject
  /// );
  /// ```
  /// {@category kernel32}
  static int CloseHandle(int hObject) => _CloseHandle(hObject);

  static final _CloseHandle = _kernel32.lookupFunction<
      Int32 Function(IntPtr hObject), int Function(int hObject)>('CloseHandle');

  /// Converts a file time to system time format. System time is based on
  /// Coordinated Universal Time (UTC).
  ///
  /// ```c
  /// BOOL FileTimeToSystemTime(
  ///   const FILETIME *lpFileTime,
  ///   LPSYSTEMTIME   lpSystemTime
  /// );
  /// ```
  /// {@category kernel32}
  static int FileTimeToSystemTime(
          Pointer<FILETIME> lpFileTime, Pointer<SYSTEMTIME> lpSystemTime) =>
      _FileTimeToSystemTime(lpFileTime, lpSystemTime);

  static final _FileTimeToSystemTime = _kernel32.lookupFunction<
      Int32 Function(
          Pointer<FILETIME> lpFileTime, Pointer<SYSTEMTIME> lpSystemTime),
      int Function(Pointer<FILETIME> lpFileTime,
          Pointer<SYSTEMTIME> lpSystemTime)>('FileTimeToSystemTime');

  /// Releases, decommits, or releases and decommits a region of pages within
  /// the virtual address space of the calling process.
  ///
  /// ```c
  /// BOOL VirtualFree(
  ///   LPVOID lpAddress,
  ///   SIZE_T dwSize,
  ///   DWORD  dwFreeType
  /// );
  /// ```
  /// {@category kernel32}
  static int VirtualFree(Pointer lpAddress, int dwSize, int dwFreeType) =>
      _VirtualFree(lpAddress, dwSize, dwFreeType);

  static final _VirtualFree = _kernel32.lookupFunction<
      Int32 Function(Pointer lpAddress, IntPtr dwSize, Uint32 dwFreeType),
      int Function(
          Pointer lpAddress, int dwSize, int dwFreeType)>('VirtualFree');

  /// Reserves, commits, or changes the state of a region of pages in the
  /// virtual address space of the calling process. Memory allocated by this
  /// function is automatically initialized to zero.
  ///
  /// ```c
  /// LPVOID VirtualAlloc(
  ///   LPVOID lpAddress,
  ///   SIZE_T dwSize,
  ///   DWORD  flAllocationType,
  ///   DWORD  flProtect
  /// );
  /// ```
  /// {@category kernel32}
  static Pointer VirtualAlloc(
          Pointer lpAddress, int dwSize, int flAllocationType, int flProtect) =>
      _VirtualAlloc(lpAddress, dwSize, flAllocationType, flProtect);

  static final _VirtualAlloc = _kernel32.lookupFunction<
      Pointer Function(Pointer lpAddress, IntPtr dwSize,
          Uint32 flAllocationType, Uint32 flProtect),
      Pointer Function(Pointer lpAddress, int dwSize, int flAllocationType,
          int flProtect)>('VirtualAlloc');

  /// Retrieves the minimum and maximum working set sizes of the specified
  /// process.
  ///
  /// ```c
  /// BOOL GetProcessWorkingSetSize(
  ///   HANDLE  hProcess,
  ///   PSIZE_T lpMinimumWorkingSetSize,
  ///   PSIZE_T lpMaximumWorkingSetSize
  /// );
  /// ```
  /// {@category kernel32}
  static int GetProcessWorkingSetSize(
          int hProcess,
          Pointer<IntPtr> lpMinimumWorkingSetSize,
          Pointer<IntPtr> lpMaximumWorkingSetSize) =>
      _GetProcessWorkingSetSize(
          hProcess, lpMinimumWorkingSetSize, lpMaximumWorkingSetSize);

  static final _GetProcessWorkingSetSize = _kernel32.lookupFunction<
      Int32 Function(IntPtr hProcess, Pointer<IntPtr> lpMinimumWorkingSetSize,
          Pointer<IntPtr> lpMaximumWorkingSetSize),
      int Function(int hProcess, Pointer<IntPtr> lpMinimumWorkingSetSize,
          Pointer<IntPtr> lpMaximumWorkingSetSize)>('GetProcessWorkingSetSize');

  /// [flags] DWORD flags that control the enforcement of the minimum and maximum working set sizes.
  /// Value	Meaning
  /// QUOTA_LIMITS_HARDWS_MIN_DISABLE
  /// 0x00000002
  /// The working set may fall below the minimum working set limit if memory demands are high.
  /// QUOTA_LIMITS_HARDWS_MIN_ENABLE
  /// 0x00000001
  /// The working set will not fall below the minimum working set limit.
  /// QUOTA_LIMITS_HARDWS_MAX_DISABLE
  /// 0x00000008
  /// The working set may exceed the maximum working set limit if there is abundant memory.
  /// QUOTA_LIMITS_HARDWS_MAX_ENABLE
  /// 0x00000004
  /// The working set will not exceed the maximum working set limit.
  static int GetProcessWorkingSetSizeEx(
          int hProcess,
          Pointer<IntPtr> lpMinimumWorkingSetSize,
          Pointer<IntPtr> lpMaximumWorkingSetSize,
          Pointer<IntPtr> flags) =>
      _GetProcessWorkingSetSizeEx(
          hProcess, lpMinimumWorkingSetSize, lpMaximumWorkingSetSize, flags);

  static final _GetProcessWorkingSetSizeEx = _kernel32.lookupFunction<
      Int32 Function(IntPtr hProcess, Pointer<IntPtr> lpMinimumWorkingSetSize,
          Pointer<IntPtr> lpMaximumWorkingSetSize, Pointer<IntPtr> flags),
      int Function(
          int hProcess,
          Pointer<IntPtr> lpMinimumWorkingSetSize,
          Pointer<IntPtr> lpMaximumWorkingSetSize,
          Pointer<IntPtr> flags)>('GetProcessWorkingSetSizeEx');

  /// Recupera informações sobre o uso de memória do processo especificado.
  /// [cb] The size of the ppsmemCounters structure, in bytes.
  static int GetProcessMemoryInfo(
          int hProcess,
          Pointer<PROCESS_MEMORY_COUNTERS> ppsmemCounters,
          Pointer<IntPtr> cb) =>
      _GetProcessMemoryInfo(hProcess, ppsmemCounters, cb);

  static final _GetProcessMemoryInfo = _kernel32.lookupFunction<
      Int32 Function(IntPtr hProcess,
          Pointer<PROCESS_MEMORY_COUNTERS> ppsmemCounters, Pointer<IntPtr> cb),
      int Function(
          int hProcess,
          Pointer<PROCESS_MEMORY_COUNTERS> ppsmemCounters,
          //K32GetProcessMemoryInfo
          Pointer<IntPtr> cb)>('GetProcessMemoryInfo');

  /// __kernel_entry NTSTATUS
  /// NTAPI
  /// NtQuerySystemInformation (
  ///     IN SYSTEM_INFORMATION_CLASS SystemInformationClass,
  ///    OUT PVOID SystemInformation,
  ///     IN ULONG SystemInformationLength,
  ///    OUT PULONG ReturnLength OPTIONAL
  ///     );
  static int NtQuerySystemInformation(
          int ProcessInformationClass,
          Pointer<Void> ProcessInformation,
          int ProcessInformationLength,
          Pointer<UnsignedLong> ReturnLength) =>
      _NtQuerySystemInformation(
        ProcessInformationClass,
        ProcessInformation,
        ProcessInformationLength,
        ReturnLength,
      );

  static final _NtQuerySystemInformation = _ntdll.lookupFunction<
      Int32 Function(
        Int32 ProcessInformationClass,
        Pointer<Void> ProcessInformation,
        UnsignedLong ProcessInformationLength,
        Pointer<UnsignedLong> ReturnLength,
      ),
      int Function(
        int ProcessInformationClass,
        Pointer<Void> ProcessInformation,
        int ProcessInformationLength,
        Pointer<UnsignedLong> ReturnLength,
      )>('NtQuerySystemInformation');
}

/// Contains a 64-bit value representing the number of 100-nanosecond
/// intervals since January 1, 1601 (UTC).
///  Contém um valor de 64 bits que representa o número de intervalos de 100 nanossegundos desde 1º de janeiro de 1601
/// https://learn.microsoft.com/pt-br/windows/win32/api/minwinbase/ns-minwinbase-filetime
/// https://github.com/dart-windows/win32/blob/aa0f23190f77fdc357a56deed386a1fad82d6ee5/lib/src/structs.g.dart#L8911
///
/// {@category Struct}
final class FILETIME extends Struct {
  @Uint32()
  external int dwLowDateTime;

  @Uint32()
  external int dwHighDateTime;
}

//https://github.com/dotnet/runtime/blob/4fa760f59503b9bb24983ef4275e77ee2fd375c1/src/libraries/Common/src/Interop/Windows/NtDll/Interop.NtQueryInformationProcess.cs
//https://github.com/dotnet/runtime/blob/c9a985d75b2255035062398557ba5a281e537b64/src/libraries/System.Diagnostics.Process/src/System/Diagnostics/ProcessManager.Win32.cs#L264
//https://github.com/sam-b/windows_kernel_address_leaks/blob/master/NtQuerySysInfo_SystemProcessInformation/NtQuerySysInfo_SystemProcessInformation/NtQuerySysInfo_SystemProcessInformation.cpp
//SYSTEM_PROCESS_INFORMATION
//https://learn.microsoft.com/en-us/windows/win32/api/winternl/nf-winternl-ntquerysysteminformation
// typedef struct _SYSTEM_PROCESS_INFORMATION {
//     ULONG NextEntryOffset;
//     ULONG NumberOfThreads;
//     BYTE Reserved1[48];
//     UNICODE_STRING ImageName;
//     KPRIORITY BasePriority;
//     HANDLE UniqueProcessId;
//     PVOID Reserved2;
//     ULONG HandleCount;
//     ULONG SessionId;
//     PVOID Reserved3;
//     SIZE_T PeakVirtualSize;
//     SIZE_T VirtualSize;
//     ULONG Reserved4;
//     SIZE_T PeakWorkingSetSize;
//     SIZE_T WorkingSetSize;
//     PVOID Reserved5;
//     SIZE_T QuotaPagedPoolUsage;
//     PVOID Reserved6;
//     SIZE_T QuotaNonPagedPoolUsage;
//     SIZE_T PagefileUsage;
//     SIZE_T PeakPagefileUsage;
//     SIZE_T PrivatePageCount;
//     LARGE_INTEGER Reserved7[6];
// } SYSTEM_PROCESS_INFORMATION, *PSYSTEM_PROCESS_INFORMATION;
final class SYSTEM_PROCESS_INFORMATION extends Struct {
  /// unsigned long
  @UnsignedLong()
  external int NextEntryOffset;

  /// unsigned long
  @UnsignedLong()
  external int NumberOfThreads;

  /// unsigned char
  @Array(48)
  external Array<UnsignedChar> Reserved1;

  external UNICODE_STRING ImageName;

  @Long()
  external int BasePriority;

  @HANDLE()
  external int UniqueProcessId;

  external PVOID Reserved2;

  @UnsignedLong()
  external int HandleCount;

  @UnsignedLong()
  external int SessionId;

  external PVOID Reserved3;

  /// SIZE_T
  @Size()
  external int PeakVirtualSize;

  /// SIZE_T
  @Size()
  external int VirtualSize;

  @UnsignedLong()
  external int Reserved4;

  /// SIZE_T
  @Size()
  external int PeakWorkingSetSize;

  /// SIZE_T
  @Size()
  external int WorkingSetSize;

  external PVOID Reserved5;

  /// SIZE_T
  @Size()
  external int QuotaPagedPoolUsage;

  external PVOID Reserved6;

  @Size()
  external int QuotaNonPagedPoolUsage;
  @Size()
  external int PagefileUsage;
  @Size()
  external int PeakPagefileUsage;
  @Size()
  external int PrivatePageCount;

  @Array(6)
  external Array<LARGE_INTEGER> Reserved7;
}

//  typedef struct _SYSTEM_THREAD_INFORMATION {
//    LARGE_INTEGER KernelTime;
//    LARGE_INTEGER UserTime;
//    LARGE_INTEGER CreateTime;
//    ULONG WaitTime;
//    PVOID StartAddress;
//    CLIENT_ID ClientId;
//    LONG Priority;
//    LONG BasePriority;
//    ULONG ContextSwitches;
//    ULONG ThreadState;
//    ULONG WaitReason;
//  } SYSTEM_THREAD_INFORMATION,
//   *PSYSTEM_THREAD_INFORMATION;
// struct SYSTEM_THREAD_INFORMATION
// {
//     private fixed long Reserved1[3];
//     private readonly uint Reserved2;
//     internal void* StartAddress;
//     internal CLIENT_ID ClientId;
//     internal int Priority;
//     internal int BasePriority;
//     private readonly uint Reserved3;
//     internal uint ThreadState;
//     internal uint WaitReason;
// }
/// size 80
final class SYSTEM_THREAD_INFORMATION extends Struct {
  external LARGE_INTEGER KernelTime;
  external LARGE_INTEGER UserTime;
  external LARGE_INTEGER CreateTime;

  @UnsignedLong()
  external int WaitTime;

  external Pointer<Void> StartAddress;

  external CLIENT_ID ClientId;

  @Long()
  external int Priority;

  @Long()
  external int BasePriority;

  @UnsignedLong()
  external int ContextSwitches;

  @UnsignedLong()
  external int ThreadState;

  @UnsignedLong()
  external int WaitReason;
}

// typedef struct _CLIENT_ID {
//     HANDLE UniqueProcess;
//     HANDLE UniqueThread;
// } CLIENT_ID;
/// size 16
final class CLIENT_ID extends Struct {
  /// Pointer<Void>
  @HANDLE()
  external int UniqueProcess;

  /// Pointer<Void>
  @HANDLE()
  external int UniqueThread;
}

// typedef enum _SYSTEM_INFORMATION_CLASS {
//     SystemBasicInformation = 0,
//     SystemPerformanceInformation = 2,
//     SystemTimeOfDayInformation = 3,
//     SystemProcessInformation = 5,
//     SystemProcessorPerformanceInformation = 8,
//     SystemInterruptInformation = 23,
//     SystemExceptionInformation = 33,
//     SystemRegistryQuotaInformation = 37,
//     SystemLookasideInformation = 45,
//     SystemCodeIntegrityInformation = 103,
//     SystemPolicyInformation = 134,
// } SYSTEM_INFORMATION_CLASS;
class SYSTEM_INFORMATION_CLASS {
  static const SystemBasicInformation = 0,
      SystemPerformanceInformation = 2,
      SystemTimeOfDayInformation = 3,
      SystemProcessInformation = 5,
      SystemProcessorPerformanceInformation = 8,
      SystemInterruptInformation = 23,
      SystemExceptionInformation = 33,
      SystemRegistryQuotaInformation = 37,
      SystemLookasideInformation = 45,
      SystemCodeIntegrityInformation = 103,
      SystemPolicyInformation = 134;
}

// typedef enum _PROCESSINFOCLASS {
//     ProcessBasicInformation = 0,
//     ProcessDebugPort = 7,
//     ProcessWow64Information = 26,
//     ProcessImageFileName = 27,
//     ProcessBreakOnTermination = 29
// } PROCESSINFOCLASS;

class PROCESSINFOCLASS_enum {
  static const ProcessBasicInformation = 0,
      ProcessDebugPort = 7,
      ProcessWow64Information = 26,
      ProcessImageFileName = 27,
      ProcessBreakOnTermination = 29;
}

/// https://learn.microsoft.com/en-us/windows/win32/api/subauth/ns-subauth-unicode_string
/// typedef struct _UNICODE_STRING {
///     USHORT Length;
///     USHORT MaximumLength;
///     PWSTR  Buffer;
/// } UNICODE_STRING;
/// The UNICODE_STRING structure is used by various Local Security Authority (LSA) functions to specify a Unicode string.
final class UNICODE_STRING extends Struct {
  /// unsigned short
  @UnsignedShort()
  external int Length;

  /// unsigned short
  @UnsignedShort()
  external int MaximumLength;

  external Pointer<Utf16> Buffer;
}

///https://learn.microsoft.com/pt-br/windows/win32/api/winnt/ns-winnt-large_integer-r1
// typedef union _LARGE_INTEGER {
//   struct {
//     DWORD LowPart;
//     LONG  HighPart;
//   } DUMMYSTRUCTNAME;
//   struct {
//     DWORD LowPart;
//     LONG  HighPart;
//   } u;
//   LONGLONG QuadPart;
// } LARGE_INTEGER;
// typedef LONG = Int32; //typedef DWORD = Uint32;
// typedef __int64 LONGLONG;
final class LARGE_INTEGER extends Struct {
  @DWORD()
  external int LowPart;
  @LONG()
  external int HighPart;
}

/// The KSPRIORITY structure is used to specify priority and is used with the KSPROPERTY_CONNECTION_PRIORITY property.
final class KSPRIORITY extends Struct {
  @ULONG()
  external int PriorityClass;
  @ULONG()
  external int PrioritySubClass;
}

///https://learn.microsoft.com/en-us/windows/win32/api/psapi/ns-psapi-process_memory_counters
///Contains the memory statistics for a process.
// typedef struct _PROCESS_MEMORY_COUNTERS {
//   DWORD  cb;
//   DWORD  PageFaultCount;
//   SIZE_T PeakWorkingSetSize;
//   SIZE_T WorkingSetSize;
//   SIZE_T QuotaPeakPagedPoolUsage;
//   SIZE_T QuotaPagedPoolUsage;
//   SIZE_T QuotaPeakNonPagedPoolUsage;
//   SIZE_T QuotaNonPagedPoolUsage;
//   SIZE_T PagefileUsage;
//   SIZE_T PeakPagefileUsage;
// } PROCESS_MEMORY_COUNTERS;
//DWORD is an unsigned integer with a range of 0 to 4294967295.
// pub const MAX_PATH: usize = 260;
// pub const FALSE: BOOL = 0;
// pub const TRUE: BOOL = 1;
// pub type DWORD = c_ulong;
// pub type BOOL = c_int;
// pub type BYTE = c_uchar;
// pub type WORD = c_ushort;
final class PROCESS_MEMORY_COUNTERS extends Struct {
  /// DWORD
  @Uint32()
  external int cb;

  /// DWORD
  @Uint32()
  external int PageFaultCount;

  /// SIZE_T
  @Size()
  external int PeakWorkingSetSize;

  /// SIZE_T
  @Size()
  external int WorkingSetSize;

  /// SIZE_T
  @Size()
  external int QuotaPeakPagedPoolUsage;

  /// SIZE_T
  @Size()
  external int QuotaPagedPoolUsage;

  /// SIZE_T
  @Size()
  external int QuotaPeakNonPagedPoolUsage;

  /// SIZE_T
  @Size()
  external int QuotaNonPagedPoolUsage;

  /// SIZE_T
  @Size()
  external int PagefileUsage;

  /// SIZE_T
  @Size()
  external int PeakPagefileUsage;
}

/// Specifies a date and time, using individual members for the month, day,
/// year, weekday, hour, minute, second, and millisecond. The time is either
/// in coordinated universal time (UTC) or local time, depending on the
/// function that is being called.
///
/// {@category Struct}
final class SYSTEMTIME extends Struct {
  @Uint16()
  external int wYear;

  @Uint16()
  external int wMonth;

  @Uint16()
  external int wDayOfWeek;

  @Uint16()
  external int wDay;

  @Uint16()
  external int wHour;

  @Uint16()
  external int wMinute;

  @Uint16()
  external int wSecond;

  @Uint16()
  external int wMilliseconds;
}

// As defined in winerror.h and https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes
class WinErrors {
  static const int ERROR_SUCCESS = 0x0;
  static const int ERROR_INVALID_FUNCTION = 0x1;
  static const int ERROR_FILE_NOT_FOUND = 0x2;
  static const int ERROR_PATH_NOT_FOUND = 0x3;
  static const int ERROR_ACCESS_DENIED = 0x5;
  static const int ERROR_INVALID_HANDLE = 0x6;
  static const int ERROR_NOT_ENOUGH_MEMORY = 0x8;
  static const int ERROR_INVALID_DATA = 0xD;
  static const int ERROR_INVALID_DRIVE = 0xF;
  static const int ERROR_NO_MORE_FILES = 0x12;
  static const int ERROR_NOT_READY = 0x15;
  static const int ERROR_BAD_COMMAND = 0x16;
  static const int ERROR_BAD_LENGTH = 0x18;
  static const int ERROR_SHARING_VIOLATION = 0x20;
  static const int ERROR_LOCK_VIOLATION = 0x21;
  static const int ERROR_HANDLE_EOF = 0x26;
  static const int ERROR_NOT_SUPPORTED = 0x32;
  static const int ERROR_BAD_NETPATH = 0x35;
  static const int ERROR_NETWORK_ACCESS_DENIED = 0x41;
  static const int ERROR_BAD_NET_NAME = 0x43;
  static const int ERROR_FILE_EXISTS = 0x50;
  static const int ERROR_INVALID_PARAMETER = 0x57;
  static const int ERROR_BROKEN_PIPE = 0x6D;
  static const int ERROR_DISK_FULL = 0x70;
  static const int ERROR_SEM_TIMEOUT = 0x79;
  static const int ERROR_CALL_NOT_IMPLEMENTED = 0x78;
  static const int ERROR_INSUFFICIENT_BUFFER = 0x7A;
  static const int ERROR_INVALID_NAME = 0x7B;
  static const int ERROR_MOD_NOT_FOUND = 0x7E;
  static const int ERROR_NEGATIVE_SEEK = 0x83;
  static const int ERROR_DIR_NOT_EMPTY = 0x91;
  static const int ERROR_BAD_PATHNAME = 0xA1;
  static const int ERROR_LOCK_FAILED = 0xA7;
  static const int ERROR_BUSY = 0xAA;
  static const int ERROR_ALREADY_EXISTS = 0xB7;
  static const int ERROR_BAD_EXE_FORMAT = 0xC1;
  static const int ERROR_ENVVAR_NOT_FOUND = 0xCB;
  static const int ERROR_FILENAME_EXCED_RANGE = 0xCE;
  static const int ERROR_EXE_MACHINE_TYPE_MISMATCH = 0xD8;
  static const int ERROR_FILE_TOO_LARGE = 0xDF;
  static const int ERROR_PIPE_BUSY = 0xE7;
  static const int ERROR_NO_DATA = 0xE8;
  static const int ERROR_PIPE_NOT_CONNECTED = 0xE9;
  static const int ERROR_MORE_DATA = 0xEA;
  static const int ERROR_NO_MORE_ITEMS = 0x103;
  static const int ERROR_DIRECTORY = 0x10B;
  static const int ERROR_NOT_OWNER = 0x120;
  static const int ERROR_TOO_MANY_POSTS = 0x12A;
  static const int ERROR_PARTIAL_COPY = 0x12B;
  static const int ERROR_ARITHMETIC_OVERFLOW = 0x216;
  static const int ERROR_PIPE_CONNECTED = 0x217;
  static const int ERROR_PIPE_LISTENING = 0x218;
  static const int ERROR_MUTANT_LIMIT_EXCEEDED = 0x24B;
  static const int ERROR_OPERATION_ABORTED = 0x3E3;
  static const int ERROR_IO_INCOMPLETE = 0x3E4;
  static const int ERROR_IO_PENDING = 0x3E5;
  static const int ERROR_NO_TOKEN = 0x3f0;
  static const int ERROR_SERVICE_DOES_NOT_EXIST = 0x424;
  static const int ERROR_EXCEPTION_IN_SERVICE = 0x428;
  static const int ERROR_PROCESS_ABORTED = 0x42B;
  static const int ERROR_NO_UNICODE_TRANSLATION = 0x459;
  static const int ERROR_DLL_INIT_FAILED = 0x45A;
  static const int ERROR_COUNTER_TIMEOUT = 0x461;
  static const int ERROR_NO_ASSOCIATION = 0x483;
  static const int ERROR_DDE_FAIL = 0x484;
  static const int ERROR_DLL_NOT_FOUND = 0x485;
  static const int ERROR_NOT_FOUND = 0x490;
  static const int ERROR_CANCELLED = 0x4C7;
  static const int ERROR_NETWORK_UNREACHABLE = 0x4CF;
  static const int ERROR_NON_ACCOUNT_SID = 0x4E9;
  static const int ERROR_NOT_ALL_ASSIGNED = 0x514;
  static const int ERROR_UNKNOWN_REVISION = 0x519;
  static const int ERROR_INVALID_OWNER = 0x51B;
  static const int ERROR_INVALID_PRIMARY_GROUP = 0x51C;
  static const int ERROR_NO_SUCH_PRIVILEGE = 0x521;
  static const int ERROR_PRIVILEGE_NOT_HELD = 0x522;
  static const int ERROR_INVALID_ACL = 0x538;
  static const int ERROR_INVALID_SECURITY_DESCR = 0x53A;
  static const int ERROR_INVALID_SID = 0x539;
  static const int ERROR_BAD_IMPERSONATION_LEVEL = 0x542;
  static const int ERROR_CANT_OPEN_ANONYMOUS = 0x543;
  static const int ERROR_NO_SECURITY_ON_OBJECT = 0x546;
  static const int ERROR_CANNOT_IMPERSONATE = 0x558;
  static const int ERROR_CLASS_ALREADY_EXISTS = 0x582;
  static const int ERROR_NO_SYSTEM_RESOURCES = 0x5AA;
  static const int ERROR_TIMEOUT = 0x5B4;
  static const int ERROR_EVENTLOG_FILE_CHANGED = 0x5DF;
  static const int ERROR_TRUSTED_RELATIONSHIP_FAILURE = 0x6FD;
  static const int ERROR_RESOURCE_TYPE_NOT_FOUND = 0x715;
  static const int ERROR_RESOURCE_LANG_NOT_FOUND = 0x717;
  static const int RPC_S_CALL_CANCELED = 0x71A;
  static const int ERROR_NOT_A_REPARSE_POINT = 0x1126;
  static const int ERROR_EVT_QUERY_RESULT_STALE = 0x3AA3;
  static const int ERROR_EVT_QUERY_RESULT_INVALID_POSITION = 0x3AA4;
  static const int ERROR_EVT_INVALID_EVENT_DATA = 0x3A9D;
  static const int ERROR_EVT_PUBLISHER_METADATA_NOT_FOUND = 0x3A9A;
  static const int ERROR_EVT_CHANNEL_NOT_FOUND = 0x3A9F;
  static const int ERROR_EVT_MESSAGE_NOT_FOUND = 0x3AB3;
  static const int ERROR_EVT_MESSAGE_ID_NOT_FOUND = 0x3AB4;
  static const int ERROR_EVT_PUBLISHER_DISABLED = 0x3ABD;
}
