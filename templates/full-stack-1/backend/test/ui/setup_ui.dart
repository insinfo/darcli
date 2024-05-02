import 'dart:async';
import 'package:puppeteer/puppeteer.dart';
import 'package:path/path.dart' as path;

/// url do sistema
const baseUrl = 'http://localhost:8005';
const baseUrlWithPath = 'http://localhost:3350/api/v1';

/// inicializa o navegador e navega para pagina incial
Future<Page> setupBrowser({bool headless = false}) async {
  final browser = await puppeteer.launch(
      devTools: false,
      headless: headless,
      defaultViewport: DeviceViewport(width: 1920, height: 1003), //, //null
      args: [
        // '--start-maximized' // you can also use '--start-fullscreen'
        '--window-size=1920,1080'
      ]);
  // Open a new tab
  final page = await browser.newPage();

  // Go to a page and wait to be fully loaded
  await page.goto('$baseUrl/#/login', wait: Until.load);
  await Future.delayed(Duration(milliseconds: 200));
  await page.waitForSelector('#username');
  print('inputUser carregado!');
  //await myPage.screenshot();
  //await myPage.pdf();
  //final val = await myPage.evaluate<String>('() => document.title');
  //print('main $val');
  // Gracefully close the browser's process
  return page;
}

/// autenticar no sistema
Future<bool> autenticar(Page page, String username, String password) async {
  await page.type('#username', username);
  await page.type('#password', password);
  await page.click('#submit');
  await Future.delayed(Duration(milliseconds: 400));
  //aguarda carregar o side menu principal
  await page.waitForSelector(
      'ul[data-label="main_menu"] li[data-label="Administrativa"');
  print('menu carregado!');
  //await page.waitForNavigation();

  if (page.url?.contains('#/restrito') == true) {
    print('logado com sucesso!');
    return true;
  } else {
    print('erro ao logar!');
    return false;
  }
}

/// click em um item de menu
Future<void> openMenuItem(Page page, String label,
    [bool aguardeOpen = true]) async {
  await Future.delayed(Duration(milliseconds: 20));
  final menuItem = await page.waitForSelector('ul li[data-label="$label"]');
  await Future.delayed(Duration(milliseconds: 20));
  await menuItem!.click();
  if (aguardeOpen) {
    await page.waitForSelector('ul li[data-label="$label"].nav-item-open');
  }
  print('openMenuItem $label');
  await Future.delayed(Duration(milliseconds: 250));
}

/// navega para um item de menu
///
/// Exemplo:
///
/// ```dart
///  await menuNavigate(page, ['Administrativa', 'CGM', 'Manutenção','Incluir CGM']);
/// ```
Future<void> menuNavigate(Page page, List<String> labels) async {
  await Future.delayed(Duration(milliseconds: 150));
  for (var i = 0; i < labels.length; i++) {
    await openMenuItem(page, labels[i], i < labels.length - 1);
  }
  await Future.delayed(Duration(milliseconds: 150));
}

/// seleciona um opção em um select nativo by option text via evaluate javascript
Future<void> selectOptionByText(Page page, String selector, String value,
    {int delay = 1500}) async {
  await page.evaluate('''(css, text) => {
  let sel = document.querySelector(css)
  for(let option of [...document.querySelectorAll(css + ' option')]){
    if(text === option.text){
     // sel.value = option.value
     option.selected = true;
     sel.dispatchEvent(new Event('change'));
     return;
    }
  }
}''', args: [selector, value]);
  await Future.delayed(Duration(milliseconds: delay));
}

/// seleciona um opção em um select nativo by option attribute value
Future<void> selectOptionByAttr(
    Page page, String selector, String attribute, String value,
    {int postDelay = 250}) async {
  await page.evaluate('''(css, attribute, text) => {
  let sel = document.querySelector(css)
  for(let option of [...document.querySelectorAll(css + ' option')]){
    const attrVal = option.getAttribute(attribute);   
    if(attrVal == text){      
      option.selected = true;
      sel.dispatchEvent(new Event('change'));
      return;
    }
  }
}''', args: [selector, attribute, value]);
  await Future.delayed(Duration(milliseconds: postDelay));
}

/// clica em um elemento usando cliques DOM nativos
/// [delay] um atrazo apos clicar
Future<void> clickOnBtn(Page page, String selector, {int delay = 2000}) async {
  await page.evaluate('''(css, text) => {
  let sel = document.querySelector(css);
  console.log(sel);
  sel.click();
}''', args: [selector]);
  await Future.delayed(Duration(milliseconds: delay));
}

/// wait For [rootSelector] selector and search element by textContent [searchText] and 'Return' attribute value
Future<String?> searchElementByContent(Page page, String rootSelector,
    String elementSelector, String searchText, String getAttribute,
    {int? postDelay}) async {
  await Future.delayed(Duration(milliseconds: 200));
  await page.waitForSelector(rootSelector);
  await Future.delayed(Duration(milliseconds: 120));
  final res = await page
      .evaluate('''(rootSelector, elementSelector, text,attribute) => {
  let sel = document.querySelector(rootSelector).querySelectorAll(elementSelector); 
  for (const ele of sel) {
    if (ele.textContent.includes(text)) {     
      const attr = ele.getAttribute(attribute);     
      return attr;
    }
  }
  return null;  
}''', args: [rootSelector, elementSelector, searchText, getAttribute]);

  if (postDelay != null) {
    await Future.delayed(Duration(milliseconds: postDelay));
  }

  return res;
}

/// usa a API DOM scrollIntoViewIfNeeded para rolar para deixar um elemento visivel
Future<void> scrollIntoView(Page page, String selector,
    {int delay = 250}) async {
  await page.evaluate('''(css, text) => {
  let sel = document.querySelector(css);
  sel.scrollIntoViewIfNeeded();
  //console.log(sel); 
}''', args: [selector]);
  await Future.delayed(Duration(milliseconds: delay));
}

/// sleep
Future<void> aguarde([int milliseconds = 300]) async {
  await Future.delayed(Duration(milliseconds: milliseconds));
}

/// verifica se um elemento existe na pagina
Future<bool> isExist(Page page, String selector) async {
  //final existAtr = await page.$('[data-id="atributos"]');
  final existAtr = await page.evaluate('''(selector) => {
  let el = document.querySelector(selector)
  return el ? true : false
}''', args: [selector]);
  return existAtr;
}

Future<String?> getInnerText(Page page, String selector) async {
  final element = await page.waitForSelector(selector);
  final res = await element!.evaluate('node => node.innerText') as String?;
  return res;
}

/// selecione uma opção pelo [value] de um select pelo [selector] nativo e aguarda carregar dados da [url] rede antes de retornar
Future<dynamic> selectOptionAndWait(
    Page page, String selector, String value, String url) async {
  final completer = Completer();
  //http://localhost:3350/api/v1/administracao/ufs?limit=195&offset=0&orderDir=desc&codPais=3
  page.select(selector, [value]);
  print('selectOptionAndWait $url');
  // final res = await page.waitForFunction(
  //     '''() => document.querySelectorAll('select[name="estado"] option').length > 3''');
  // final res = await page.waitForXPath("//select[contains(@id, 'estado')]/option[contains(text(),'Rio de Janeiro')]");
  page.waitForResponse(url).then((res) async {
    print('selectOptionAndWait carregou o combo $selector $res');
    await aguarde(1000);
    completer.complete();
  });
  //final res = await page.waitForSelector('select[name="estado"] option:nth-child(3)');

  return completer.future;
}

extension PuppeteerPageExtension on Page {
  Future<Response> waitForResponseCustom(String inputUrl,
      {bool Function(String responseUrl)? comparFunc, Duration? timeout}) {
    const globalDefaultTimeout = Duration(seconds: 30);
    timeout ??= defaultTimeout ?? globalDefaultTimeout;

    return frameManager.networkManager.onResponse
        .where((response) {
          final respUrl = path.url.normalize(response.url);
          if (comparFunc == null) {
            final pUrl = path.url.normalize(inputUrl);
            return respUrl == pUrl;
          } else {
            return comparFunc(respUrl);
          }
        })
        .first
        .timeout(timeout);
  }
}

/// selecione uma opção pelo [text] de um select pelo [selector] nativo e aguarda carregar dados da [url] rede antes de retornar
Future<dynamic> selectOptionByTextAndWait(
    Page page, String selector, String text, String url) async {
  final completer = Completer();

  final optionValue = await page.$$eval('$selector option',
      '''options => options.find(o => o.innerText.includes("$text"))?.value''');

  page.select(selector, [optionValue]);
  //print('selectOptionByTextAndWait $url');
  page
      .waitForResponseCustom(url,
          comparFunc: ((responseUrl) => responseUrl.contains(url)))
      .then((res) async {
    //print('selectOptionByTextAndWait carregou o combo $selector $res');
    await aguarde(1000);
    completer.complete();
  });
  return completer.future;
}

Future<dynamic> selectOptionByText2(
    Page page, String selector, String text) async {
  final completer = Completer();

  final optionValue = await page.$$eval('$selector option',
      '''options => options.find(o => o.innerText.includes("$text"))?.value''');

  await page.select(selector, [optionValue]);
  await aguarde(1000);
  completer.complete();

  return completer.future;
}
