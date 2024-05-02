import 'dart:io' as dartio;
import 'package:new_sali_backend/src/shared/utils/system_interop/linux_interop/linux_interop.dart';
import 'package:new_sali_backend/src/shared/utils/system_interop/windows_interop/windows_interop.dart';
import 'disk_info.dart';
import 'linux_interop/process_manager_linux.dart';
import 'process_info.dart';
import 'windows_interop/process_manager_win32.dart';

class ProcessManager {
  Future<ProcessInfo?> getProcessInfo({int? pid}) async {
    if (dartio.Platform.isWindows) {
      final procMan = ProcessManagerWin32();
      return procMan.getProcessInfo(processIdFilter: pid ?? dartio.pid);
    } else if (dartio.Platform.isLinux) {
      final procMan = ProcessManagerLinux();
      return procMan.getProcessInfo(processIdFilter: pid ?? dartio.pid);
    } else {
      throw UnimplementedError();
    }
  }

  Future<double> totalProcessorTimeAsTotalSeconds({int? pid}) async {
    if (dartio.Platform.isWindows) {
      final procMan = ProcessManagerWin32();
      return procMan.totalProcessorTimeAsTotalSeconds(pid ?? dartio.pid);
    } else if (dartio.Platform.isLinux) {
      final procMan = ProcessManagerLinux();
      return procMan.totalProcessorTimeAsTotalSeconds(pid ?? dartio.pid);
    } else {
      throw UnimplementedError();
    }
  }

  /// [pathOrUnit] on linux = '/' on windows  = 'C:\\'
  Future<DiskInfo> getDiskUsage({String? pathOrUnit}) async {
    if (dartio.Platform.isWindows) {
      final info = WindowsInterop.statvfs(pathOrUnit ?? 'C:\\');
      //print('getDiskUsage ${info}');
      return info;
    } else if (dartio.Platform.isLinux) {
      final info = LinuxInterop.statvfs(pathOrUnit ?? '/');

      //https://stackoverflow.com/questions/4965355/converting-statvfs-to-percentage-free-correctly
      //https://github.com/giampaolo/psutil/blob/f4734c80203023458cb05b1499db611ed4916af2/psutil/_psposix.py#L119
      //double GB = (1024 * 1024) * 1024;
      //print('reservedSize ${(info.reservedSize() / GB).round()}G');
      //print('Avail ${(info.free() / GB).round()}G');
      // print('freeWithReserved ${(info.freeWithReserved() / GB).round()}G');
      //print('total ${(info.total() / GB).round()}G');
      //print('used ${(info.usedWithoutReserved() / GB).toStringAsFixed(1)}G');
      // print('usedWithReserved ${(info.usedWithReserved() / GB).toStringAsFixed(1)}G');
      // print('percent ${(info.percent()).round()}%');
      final result =
          DiskInfo(info.total(), info.free(), info.freeWithReserved());
      //print('getDiskUsage ${result}');
      return result;
    } else {
      throw UnimplementedError();
    }
  }

  /// process start time seconds
  Future<double> startTime({int? pid}) async {
    if (dartio.Platform.isWindows) {
      final procMan = ProcessManagerWin32();
      return procMan.startTimeCore(pid ?? dartio.pid);
    } else if (dartio.Platform.isLinux) {
      final procMan = ProcessManagerLinux();
      return await procMan.startTimeCore(pid ?? dartio.pid);
    } else {
      throw UnimplementedError();
    }
  }
}
