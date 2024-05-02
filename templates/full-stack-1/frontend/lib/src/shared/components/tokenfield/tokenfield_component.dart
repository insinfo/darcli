// my_custom_component.dart
import 'dart:async';
import 'package:new_sali_frontend/new_sali_frontend.dart';
import 'dart:html';

class TokenfieldItem {
  bool selected;
  String value;
  TokenfieldItem({this.selected = false, required this.value});
}

///
/// Example:
/// <tokenfield-component [(ngModel)]="filtros.processos" [filterInput]="true" [patternAllowed]="patternAllowed" placeholder="Digite o número do processo e pressione enter."></tokenfield-component>
@Component(
  selector: 'tokenfield-component',
  templateUrl: 'tokenfield_component.html',
  styleUrls: ['tokenfield_component.css'],
  directives: [
    coreDirectives,
  ],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, TokenfieldComponent),
  ],
)
class TokenfieldComponent
    implements
        ControlValueAccessor<List<String>>,
        AfterViewInit,
        AfterContentInit,
        OnInit {
  // @Input('displaytext') displaytext: string;

  @Input('placeholder')
  String placeholder = '';

  //@Input('tokens')
  List<TokenfieldItem> items = [];

  List<String> get tokens => items.map((e) => e.value).toList();

  set tokens(List<String> vals) {
    items.addAll(vals.map((v) => TokenfieldItem(value: v)));
  }

  @ViewChild('tokensUl')
  Element? tokensUl;

  @ViewChild('inputToken')
  InputElement? inputToken;

  @ViewChild('container')
  Element? container;

  //String? value;
  // ...could define a setter that call `_changeController.add(value)`

  final _changeController = StreamController<List<String>>();

  @Output()
  Stream<List<String>> get onChange => _changeController.stream;

  @override
  void writeValue(List<String>? newVal) {
    tokens = newVal ?? [];
    //print('TokenfieldComponent@writeValue newVal $newVal');
  }

  @override
  void registerOnChange(callback) {
    onChange.listen((value) {
      callback(value);
    });
  }

  // optionally you can implement the rest interface methods
  @override
  void registerOnTouched(TouchFunction callback) {}

  @override
  void onDisabledChanged(bool state) {}

  void addToken() {
    if (inputToken?.value != null && inputToken?.value?.trim() != '') {
      final text = inputToken!.value!;
      processInput(text);
      inputToken!.value = '';
    }
  }

  void inputKeypressHandle(KeyboardEvent e) {
    if (filterInput == true) {
      if (!RegExp(patternAllowed).hasMatch(e.key.toString())) {
        e.preventDefault();
      }
    }
  }

  void selectAll() {
    items.forEach((el) {
      el.selected = true;
    });
  }

  void unSelectAll() {
    items.forEach((el) {
      el.selected = false;
    });
  }

  var lastKeyCode = 0;
  void inputKeydownHandle(KeyboardEvent e) {
    // print('inputKeydownHandle ${e.keyCode}');
    if (e.ctrlKey) {
      // Ctrl + a // 'A' 97 or 'a'
      if (e.keyCode == 65) {
        //print('Ctrl + a pressed');
        selectAll();
      }
      if (e.keyCode == 67) {
        //print('Ctrl + c pressed');
        copiar();
        inputToken?.focus();
      }
      if (e.keyCode == 86) {
        // print('Ctrl + V pressed');
      }
    }
    if (e.keyCode == 46) {
      //print('Delete pressed $lastKeyCode');
      if (lastKeyCode == 65) {
        items.removeWhere((element) => element.selected);
      }
    }
    lastKeyCode = e.keyCode;
  }

  void inputKeyupHandle(KeyboardEvent e) {
    if (e.keyCode == KeyCode.ENTER || e.keyCode == 110 || e.keyCode == 188) {
      addToken();
      //(keyup.enter)="addToken()"
    }
  }

  void onPasteHandle(ClipboardEvent event) {
    event.preventDefault();
    final text = event.clipboardData?.getData('text');
    processInput(text ?? '');
  }

  void removeToken(TokenfieldItem item) {
    items.remove(item);
    // update model
    _changeController.add(tokens);
  }

  @override
  void ngOnInit() {}

  @override
  void ngAfterContentInit() {}
  @override
  void ngAfterViewInit() {}

  void containerClickHandle() {
    inputToken?.focus();
    unSelectAll();
  }

  /// Allowed Keydown characters
  @Input('patternAllowed')
  String patternAllowed = r'[0-9\/]+';

  /// padrão detectavel e extraivel de cada token ao clicar no botão colar ou enter
  /// Example:
  @Input('patternToken')
  String patternToken = r'(\d+)\/(\d+)';

  //filter input on keypress
  @Input('filterInput')
  bool filterInput = false;

  void copiar() {
    FrontUtils.copyToClipboard(tokens.join(','));
  }

  void colar() async {
    final text = await FrontUtils.getClipboardText();
    processInput(text);
  }

  void clear() {
    items.clear();
    _changeController.add(tokens);
  }

  void processInput(String text) {
    final rgex = RegExp(patternToken); //r'\d+\/\d+');

    if (text.contains(',')) {
      final parts = text.split(',');
      for (final part in parts) {
        if (rgex.hasMatch(part)) {
          //tokens.add(part);
          items.add(TokenfieldItem(value: part));
          // update model
          _changeController.add(tokens);
        }
      }
    } else if (text.contains('/')) {
      if (rgex.hasMatch(text)) {
        //tokens.add(text);
        items.add(TokenfieldItem(value: text));
        // update model
        _changeController.add(tokens);
      }
    }
  }
}
