// extension SetExtensions<T> on Set<T> {
//   /// Replaces all instances of the item `oldItem` with the new item `newItem`.
//   void replaceAll(T oldItem, T newItem) {
//     removeWhere((item) => item == oldItem);
//     addAll([newItem]);
//   }
// }

// Iterable/Interator Extensions

extension SetExtension<E> on Set<E> {
  // Replace an item in the Set with a new one
  void replace(E oldItem, E newItem) {
    if (this.contains(oldItem)) {
      this.remove(oldItem);
      this.add(newItem);
    }
  }


   void removeAndAdd(E toRemove, E newItem) {
    if (this.contains(toRemove)) {
      this.remove(toRemove);      
    }
    this.add(newItem);
  }
}