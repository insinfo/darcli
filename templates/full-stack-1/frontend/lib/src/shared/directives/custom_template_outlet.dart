import 'package:ngdart/src/core/linker.dart';
import 'package:ngdart/src/meta.dart';

@Directive(
  selector: '[customTemplateOutlet]',
)
class CustomTemplateOutlet implements DoCheck {
  final ViewContainerRef _viewContainerRef;

  Map<String, Object?>? _context;
  EmbeddedViewRef? _insertedViewRef;

  CustomTemplateOutlet(this._viewContainerRef);

  /// The [TemplateRef] used to create the embedded view.
  ///
  /// Any previously embedded view is removed when [templateRef] changes. If
  /// [templateRef] is null, no embedded view is inserted.
  @Input()
  set ngTemplateOutlet(TemplateRef? templateRef) {
    final insertedViewRef = _insertedViewRef;
    if (insertedViewRef != null) {
      _viewContainerRef.remove(_viewContainerRef.indexOf(insertedViewRef));
    }
    if (templateRef != null) {
      _insertedViewRef = _viewContainerRef.createEmbeddedView(templateRef);
    } else {
      _insertedViewRef = null;
    }
  }

  /// An optional map of local variables to define in the embedded view.
  ///
  /// Theses variables can be assigned to template input variables declared
  /// using 'let-' bindings. The variable '$implicit' can be used to set the
  /// default value of any 'let-' binding without an explicit assignment.
  @Input()
  set ngTemplateOutletContext(Map<String, Object?> context) {
    _context = context;
  }

  /// Provides a value to be assigned in scope to the provided template.
  ///
  /// Functionally a short-hand for passing a map of `${'\$implicit': value}`;
  ///
  /// See [ngTemplateOutletContext] for details.
  @Input()
  set ngTemplateOutletValue(Object? value) {
    _context = {'\$implicit': value};
  }

  @override
  void ngDoCheck() {
    final insertedViewRef = _insertedViewRef;
    if (insertedViewRef == null) return;
    // Local variables are deliberately set every change detection cycle to
    // simplify the design. It's unlikely this is worse than conditionally
    // setting them based on whether they actually changed, since their values
    // are change detected again wherever they're bound.
    _context?.forEach(insertedViewRef.setLocal);
  }
}
