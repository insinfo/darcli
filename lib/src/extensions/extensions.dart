extension IterableExtension<E> on Iterable<E> {
  E? firstWhereNull(bool Function(E element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
