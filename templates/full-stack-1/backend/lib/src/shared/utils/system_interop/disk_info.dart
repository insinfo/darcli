class DiskInfo {
  int total;
  int available;
  int totalfree;

  DiskInfo(this.total, this.available, this.totalfree);
  factory DiskInfo.invalid() {
    return DiskInfo(-1, -1, -1);
  }

  int used() => total - totalfree;
  // int usedWithoutReserved() => (blocks - blocksFree) * fragmentSize;

  /// Used percent (%) subtracted reserved in bytes
  double usedPercent() => (used() / total) * 100;

  static const double GB = (1024 * 1024) * 1024;

  @override
  String toString() {
    // print('Avail ${(info.free() / GB).round()}G');
    // // print('freeWithReserved ${(info.freeWithReserved() / GB).round()}G');
    // print('total ${(info.total() / GB).round()}G');
    // print('used ${(info.usedWithoutReserved() / GB).toStringAsFixed(1)}G');
    // // print('usedWithReserved ${(info.usedWithReserved() / GB).toStringAsFixed(1)}G');
    // print('percent ${(info.percent()).round()}%');

    return '''DiskInfo(total:${(total / GB).round()}G,available:${(available / GB).round()}G, totalfree:${(totalfree / GB).round()}G, used:${(used() / GB).toStringAsFixed(1)}G))
    DiskInfo(total:${total}b,available:${available}b, totalfree:${totalfree}b, used:${used()}b, usedPercent:${usedPercent().round()}%))
    ''';
  }
}
