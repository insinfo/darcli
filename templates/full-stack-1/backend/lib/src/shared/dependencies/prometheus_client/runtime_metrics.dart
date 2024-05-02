/// A library exposing metrics of the Dart runtime.
library prometheus_client.runtime_metrics;

import 'dart:io';
import 'package:new_sali_backend/src/shared/utils/system_interop/process_manager.dart';
import 'prometheus_client.dart';


/// Collector for runtime metrics. Exposes the `dart_info`,
/// `process_start_time_seconds`, and `process_resident_memory_bytes` metric.
class RuntimeCollector extends Collector {
  // This is not the actual startup time of the process, but the time the first
  // collector was created. Dart's lazy initialization of globals doesn't allow
  // for a better timing...
  static final _startupTime =
      DateTime.now().millisecondsSinceEpoch / Duration.millisecondsPerSecond;

  @override
  Future<Iterable<MetricFamilySamples>> collect() async {
    //https://github.com/dotnet/runtime/blob/c345959e132409b19c692807e313f739bce850ad/src/libraries/System.Diagnostics.Process/src/System/Diagnostics/Process.Linux.cs#L130

    //https://prometheus.io/docs/instrumenting/writing_clientlibs/#standard-and-runtime-collectors

    //baseado no C#
    //https://github.com/prometheus-net/prometheus-net/blob/ea794f6186753782dbfd8a32ed2220f0699ee864/Prometheus/DotNetStats.cs#L63

    final processManager = ProcessManager();
    final processInfo = await processManager.getProcessInfo();
    final rootDiskInfo = await processManager.getDiskUsage(); //'/bd_sali'

    final _cpuTotal = MetricFamilySamples('process_cpu_seconds_total',
        MetricType.gauge, 'Total user and system CPU time spent in seconds.', [
      Sample('process_cpu_seconds_total', const [], const [],
          await processManager.totalProcessorTimeAsTotalSeconds())
    ]);

    final _numThreads = MetricFamilySamples(
        'process_num_threads', MetricType.gauge, 'Total number of threads', [
      Sample('process_num_threads', const [], const [],
          (processInfo?.numberOfThreads ?? -1).toDouble())
    ]);

    final _openHandles = MetricFamilySamples(
        'process_open_handles', MetricType.gauge, 'Number of open handles', [
      Sample('process_open_handles', const [], const [],
          (processInfo?.handleCount ?? -1).toDouble())
    ]);
    //A memória virtual usa hardware e software para permitir que um computador compense a escassez de memória física,
    //transferindo temporariamente dados da memória de acesso aleatório (RAM) para o armazenamento em disco
    final _virtualMemoryBytes = MetricFamilySamples(
        'process_virtual_memory_bytes',
        MetricType.gauge,
        'Process virtual memory size in bytes', [
      Sample('process_virtual_memory_bytes', const [], const [],
          (processInfo?.virtualBytes ?? -1).toDouble())
    ]);

    final _workingSetBytes = MetricFamilySamples('process_working_set_bytes',
        MetricType.gauge, 'Process working set in bytes', [
      Sample('process_working_set_bytes', const [], const [],
          (processInfo?.workingSet ?? -1).toDouble())
    ]);

    final rootFilesystemAvailBytes = MetricFamilySamples(
        'root_filesystem_avail_bytes',
        MetricType.gauge,
        'root filesystem available in bytes', [
      Sample('root_filesystem_avail_bytes', const [], const [],
          rootDiskInfo.available.toDouble())
    ]);

    final rootFilesystemSizeBytes = MetricFamilySamples(
        'root_filesystem_size_bytes',
        MetricType.gauge,
        'root filesystem size in bytes', [
      Sample('root_filesystem_size_bytes', const [], const [],
          rootDiskInfo.total.toDouble())
    ]);

    // final secondaryFilesystemAvailBytes = MetricFamilySamples(
    //     'secondary_filesystem_avail_bytes',
    //     MetricType.gauge,
    //     'secondary filesystem available in bytes', [
    //   Sample('secondary_filesystem_avail_bytes', const [], const [],
    //       _secondaryDiskInfo.available.toDouble())
    // ]);

    // final secondaryFilesystemSizeBytes = MetricFamilySamples(
    //     'secondary_filesystem_size_bytes',
    //     MetricType.gauge,
    //     'secondary filesystem size in bytes', [
    //   Sample('secondary_filesystem_size_bytes', const [], const [],
    //       _secondaryDiskInfo.total.toDouble())
    // ]);

    /// 100 - (100 * ((node_filesystem_avail_bytes{mountpoint="/",fstype!="rootfs"} )  / (node_filesystem_size_bytes{mountpoint="/",fstype!="rootfs"}) ))

    return [
      // MetricFamilySamples('dart_info', MetricType.gauge,
      //     'Information about the Dart environment.', [
      //   Sample('dart_info', const ['version'], [Platform.version], 1)
      // ]),
      _numThreads,
      _cpuTotal,
      _openHandles,
      _virtualMemoryBytes,
      _workingSetBytes,
      rootFilesystemAvailBytes,
      rootFilesystemSizeBytes,
      //  secondaryFilesystemAvailBytes,
      //  secondaryFilesystemSizeBytes,
      MetricFamilySamples('process_resident_memory_bytes', MetricType.gauge,
          'Resident memory size in bytes.', [
        Sample(
            'process_resident_memory_bytes',
            const [],
            const [],
            //O tamanho da memória do conjunto residente atual para o processo.
            //Observe que o significado deste campo depende da plataforma.
            //Por exemplo, parte da memória considerada aqui pode
            //ser compartilhada com outros processos ou, se a mesma
            //página for mapeada no espaço de endereço de um processo,
            // ela poderá ser contada duas vezes.
            ProcessInfo.currentRss.toDouble())
      ]),
      MetricFamilySamples('process_start_time_seconds', MetricType.gauge,
          'Start time of the process since unix epoch in seconds.', [
        Sample('process_start_time_seconds', const [], const [],
            _startupTime.toDouble())
      ]),
    ];
  }

  @override
  Iterable<String> collectNames() {
    return [
      //'dart_info',
      'process_resident_memory_bytes',
      'process_start_time_seconds',
      'process_cpu_seconds_total',
      'process_num_threads',
      'process_open_handles',
      'process_virtual_memory_bytes',
      'process_working_set_bytes',
      'root_filesystem_avail_bytes',
      'root_filesystem_size_bytes',
      // 'secondary_filesystem_avail_bytes',
      // 'secondary_filesystem_size_bytes',
    ];
  }
}

/// Register default metrics for the Dart runtime. If no [registry] is provided,
/// the [CollectorRegistry.defaultRegistry] is used.
void register([CollectorRegistry? registry]) {
  registry ??= CollectorRegistry.defaultRegistry;

  registry.register(RuntimeCollector());
}
