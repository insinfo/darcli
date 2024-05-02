class StatusBarService {
  bool isVisible = false;
  bool isExpanded = false;

  void show() {
    isVisible = true;
  }

  void hide() {
    isVisible = false;
  }

  void toggle() {
    if (isVisible == true) {
      hide();
    } else {
      show();
    }
  }

  void toogleExpand() {
    isExpanded = !isExpanded;
  }

  // bool get isVisible => _isVisible;
}
