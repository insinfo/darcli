import 'package:new_sali_core/src/utils/cpf_utils.dart';
import 'package:new_sali_core/src/utils/cnpj_utils.dart';
import 'package:puppeteer/puppeteer.dart';

/// url do sistema
const baseUrl = 'http://localhost:8005';

/// inicializa o navegador e navega para pagina incial
Future<Page> setupBrowser() async {
  final browser = await puppeteer.launch(
      devTools: false,
      headless: false,
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

/// seleciona um opção em um select nativo by option text
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

/// [tipoPessoa] f ou j
Future<int> incluirCGM(
    Page page, String tipoPessoa, Map<String, String> data) async {
  await menuNavigate(
      page, ['Administrativa', 'CGM', 'Manutenção', 'Incluir CGM']);

  //Dados CGM
  await page.select('select[name="tipoPessoa"]', [tipoPessoa]);
  await aguarde(500);

  if (tipoPessoa == 'f') {
    await page.type('input[name="nome"]', data['nome']!);
    await page.type('input[name="cpf"]', CpfUtil().generate());
    await page.type('input[name="rg"]', '217504877');
    await page.type('input[name="orgaoEmissor"]', 'Detran');

    await aguarde(150);
    //Rio de Janeiro
    await page.select('select[name="cod_uf_orgao_emissor"]', ['20: 19']);

    await aguarde(150);
    await page.type('input[name="dt_emissao_rg"]', '14/09/2005');
    await page.type('input[name="num_cnh"]', '08376064073');
    // Categoria D
    await page.select('select[name="cod_categoria_cnh"]', ['8: 4']);
    await page.type('input[name="dt_validade_cnh"]', '14/09/2029');
    await page.type('input[name="servidor_pis_pasep"]', '774.65811.27-0');
    //Brasileira
    await page.select('select[name="cod_nacionalidade"]', ['5: 1']);
    //2o grau completo
    await page.select('select[name="cod_escolaridade"]', ['2: 7']);
    await page.type('input[name="dt_nascimento"]', '14/09/1987');
    await page.select('select[name="sexo"]', ['m']);
  } else {
    await page.type('input[name="nome"]', data['nome']!);
    await page.type('input[name="nomFantasia"]', 'Nome Fantasia teste');
    await page.type('input[name="cnpj"]', CnpjUtil.generate());
    await page.type('input[name="inscEstadual"]', 'Inscrição teste');
  }

  //Dados endereço
  await page.select('select[name="tipo_logradouro"]', ['Rua']);
  await page.type('input[name="logradouro"]', 'Anita');
  await page.type('input[name="numero"]', '0');
  await page.type('input[name="complemento"]', 'Casa de Cima');

  await page.select('select[name="pais"]', ['6: 1']);

  await aguarde(2100);
  await page.select('select[name="estado"]', ['48: 19']);

  await aguarde(2100);
  await page.select('select[name="municipio"]', ['158: 66']);
  await page.type('input[name="bairro"]', 'Costazul');
  await page.type('input[name="cep"]', '28895234');
  //Dados contato
  await page.type('input[name="fone_residencial"]', '2227772339');
  await page.type('input[name="fone_comercial"]', '2227776464');
  await page.type('input[name="ramal_comercial"]', '171');
  await page.type('input[name="fone_celular"]', '22997015305');
  await page.type('input[name="e_mail"]', 'email.teste@teste.com');
  await page.type('input[name="e_mail_adcional"]', 'email.teste@teste.com');
  // await selectOption(page, 'select[name="municipio"]', 'Angra dos Reis');
  await page.type('input[name="Observação"]', 'Observação teste');

  await aguarde(1000);

  await scrollIntoView(page, '#submit');
  await page.click('#submit'); //btnSalvarPessoa
  // await clickOnBtn(page, '#submit');

  final spanCgm = await page.waitForSelector('.lastCgmCad');
  final cgm = int.parse(await spanCgm!.evaluate('node => node.innerText'));
  print('CGM Cadastrado: $cgm');
  return cgm;
}

Future<String> incluirProcesso(Page page, Map<String, String> data) async {
  await menuNavigate(
      page, ['Administrativa', 'Protocolo', 'Processo', 'Incluir Processo']);

  // clica para abrir o modal busca de interressado
  final inputNomeInteressado =
      await page.waitForSelector('#inputNomeInteressado');
  inputNomeInteressado!.click();
  // aguarda abrir o modal
  await aguarde(300);
  await page.waitForSelector('#modalBuscaPessoa [data-status="open"]');
  // digita o nome do interessado
  await page.type(
      '[data-label="datatable_input_search"]', data['nomeInteressado']!);
  // seleciona para buscar por nome
  await page
      .select('select[data-label="datatable_select_search_field"]', ['0']);
  // clica em buscar
  await page.click('button[data-label="datatable_btn_search"]');
  await aguarde(300);
  // aguarda trazer os resultados
  await page.waitForSelector('#modalBuscaPessoa table tbody tr');
  // busca pelo nome na lista e retorna o selector
  final rowInteressadoSel = await searchElementByContent(
      page,
      '#modalBuscaPessoa table tbody',
      'tr',
      data['nomeInteressado']!,
      'data-label');
  if (rowInteressadoSel == null) {
    throw Exception('Não foi possivel localizar o interresado nos resultados');
  }
  // clica no linha do dataTable que tem o resultado
  await page.click('#modalBuscaPessoa tbody [data-label="$rowInteressadoSel"]');
  // abre o custom select Classificação
  await page.click(
      '#customSelectClassificacao [data-label="custom_select_btn_toggle"]');
  await aguarde(1000);
  // busca a opção Abono
  final classificacaoSel = await searchElementByContent(
      page,
      '[data-id="dropdown_customSelectClassificacao"] ul',
      'li',
      'Abono',
      'data-label');
  // await page.type('[data-label="custom_select_input_search"]', 'Abono');
  // clica na opção abono
  await page.click(
      '[data-id="dropdown_customSelectClassificacao"] [data-label="$classificacaoSel"]');
  await aguarde(2000);
  // seleciona a primeira opção Abono de permanência
  await page.select('select[name="selectAssunto"]', ['1: 1']);
  // aguarda carregar atributos
  await aguarde(2000);
  // preenche Objeto/Observação
  await page.type('[name="observacoes"]', 'Objeto do processo teste');
  await page.type(
      '[name="assuntoReduzido"]', 'Assunto reduzido do processo teste');
  // verifica se existe atributos
  final existAtributos = await isExist(page, '[data-id="atributos"]');
  if (existAtributos) {
    await page.type('[name="Anotações"]', 'Anotações teste');
  }
  await aguarde(2000);
  await scrollIntoView(page, 'select[name="selectOrgao"]');
  // seleciona orgão
 
  await selectOptionByAttr(
      page, 'select[name="selectOrgao"]', 'data-value', '2');
  await aguarde(2000);
  // seleciona unidade
  // 89 = Gabinete/ASCOMTI - Assess.de Comunicação e Téc.da Informação
  await selectOptionByAttr(
      page, 'select[name="selectUnidade"]', 'data-value', '89');
  await aguarde(2000);
  // seleciona departamento
  // 2 = TI - Tecnologia da Informação
  await selectOptionByAttr(
      page, 'select[name="selectDepartamento"]', 'data-value', '2');
  await aguarde(2000);
  // seleciona setor
  // 1 = TI - Tecnologia da Informação
  await selectOptionByAttr(
      page, 'select[name="selectSetor"]', 'data-value', '1');
  await aguarde(300);
  await scrollIntoView(page, '#btnSubmit');
  await page.click('#btnSubmit');
  await aguarde(600);

  final spanProcCodigoCad = await page.waitForSelector('.procCodigoCad');
  final procCodigoCad =
      await spanProcCodigoCad!.evaluate('node => node.innerText');
  print('Codigo processo cadastrado: $procCodigoCad');
  return procCodigoCad as String;
}

Future<void> buscaProcessoPorCod(Page page, String codigo) async {
  // navega para tela Consultar Processo
  await menuNavigate(
      page, ['Administrativa', 'Protocolo', 'Processo', 'Consultar Processo']);
  // digita o codigo do Processo
  await page.type(
      '[data-id="datatableListaProcesso"] [data-label="datatable_input_search"]',
      codigo);
  // clica em buscar e aguarde carregar
  await page.click(
      '[data-id="datatableListaProcesso"] button[data-label="datatable_btn_search"]');
  await aguarde(1000);
  await page.waitForSelector('[data-id="datatableListaProcesso"] tbody tr');

  final rowSel = await searchElementByContent(
      page,
      '[data-id="datatableListaProcesso"] table tbody',
      'tr',
      codigo,
      'data-label');

  if (rowSel != null) {
    print('Processo $codigo localizado');
  } else {
    throw Exception('Não foi localizado o processo $codigo');
  }
  // clica na linha do dataTable que tem o resultado
  await page
      .click('[data-id="datatableListaProcesso"] tbody [data-label="$rowSel"]');

  await aguarde(3000);
  final codParts = codigo.split('/');
  if (page.url?.contains(
          '#/restrito/visualiza-processo/${codParts.last}/${codParts.first}') ==
      false) {
    throw Exception('Pagina Visualiza Processo não carreagou');
  }
  // aguarda os andamentos carregarem
  await page
      .waitForSelector('[data-id="containerListaAndamentos"] table tbody tr');
  // rolar para baixo
  await scrollIntoView(
      page, '[data-id="containerListaAndamentos"] table tbody tr');
}

Future<void> receberProcessoPorCod(Page page, String codigo) async {
  // navega para tela Consultar Processo
  await menuNavigate(page,
      ['Administrativa', 'Protocolo', 'Processo', 'Receber Processo em Lote']);
// digita o codigo do Processo
  await page.type(
      '[data-id="datatableProcessosAReceber"] [data-label="datatable_input_search"]',
      codigo);
  // clica em buscar e aguarda carregar
  await page.click(
      '[data-id="datatableProcessosAReceber"] button[data-label="datatable_btn_search"]');
  await aguarde(3000);
  //isExist

  final resultados =
      await page.$$('[data-id="datatableProcessosAReceber"] table tbody tr');

  if (resultados.isEmpty) {
    throw Exception('Falhar ao receber o processo, processo não listado');
  }

  // await page.waitForSelector(
  //     '[data-id="datatableProcessosAReceber"] table tbody tr',
  //     timeout: Duration(milliseconds: 3000));

  final rowSel = await searchElementByContent(
      page,
      '[data-id="datatableProcessosAReceber"] table tbody',
      'tr',
      codigo,
      'data-label');

  await page.click(
      '[data-id="datatableProcessosAReceber"] tbody tr[data-label="$rowSel"] input[data-label="datatable_col_checkbox"]');

  await page.click('button[data-id="btnReceberProcesso"]');

  final msg = await getInnerText(page,
      'div[data-label="notification_component"] div[data-label="notification_item_body"]');

  if (msg?.contains('Processos recebidos') == false) {
    throw Exception('Falhar ao receber o processo');
  } else {
    print('Processos recebidos | $msg');
  }
}

Future<void> receberPrimeiroProcesso(Page page) async {
  // navega para tela Consultar Processo
  await menuNavigate(page,
      ['Administrativa', 'Protocolo', 'Processo', 'Receber Processo em Lote']);
  // digita o codigo do Processo
  await page.type(
      '[data-id="datatableProcessosAReceber"] [data-label="datatable_input_search"]',
      '');
  // clica em buscar e aguarda carregar
  await page.click(
      '[data-id="datatableProcessosAReceber"] button[data-label="datatable_btn_search"]');
  await aguarde(3000);

  final resultados =
      await page.$$('[data-id="datatableProcessosAReceber"] table tbody tr');

  if (resultados.isEmpty) {
    throw Exception(
        'Falhar ao receber o processo, processos não listados, pode não existir processos a receber!');
  }
  final processoCod = await getInnerText(page,
      '[data-id="datatableProcessosAReceber"] tbody tr[data-label="datatable_row_0"] td[data-label="datatable_col_0"]');

  // clica no checkbox do primeiro resultado
  await page.click(
      '[data-id="datatableProcessosAReceber"] tbody tr[data-label="datatable_row_0"] input[data-label="datatable_col_checkbox"]');

  print('Processo $processoCod selecionado');

  // clica em receber processo
  await page.click('button[data-id="btnReceberProcesso"]');
  // aguarda a notificação aparecer
  // pega a mensagem da notificação
  final msg = await getInnerText(page,
      'div[data-label="notification_component"] div[data-label="notification_item_body"]');

  if (msg?.contains('Processos recebidos') == false) {
    throw Exception('Falhar ao receber o processo');
  } else {
    print('Processo  $processoCod recebido | msg: $msg');
  }
}

Future<void> encaminharProcessoByCod(Page page, String codigo) async {
  // navega para tela Consultar Processo
  await menuNavigate(page, [
    'Administrativa',
    'Protocolo',
    'Processo',
    'Encaminhar Processo em Lote'
  ]);

  // digita o codigo do Processo
  await page.type(
      '[data-id="datatableProcessosAEncaminhar"] [data-label="datatable_input_search"]',
      codigo);
  // clica em buscar e aguarda carregar
  await page.click(
      '[data-id="datatableProcessosAEncaminhar"] button[data-label="datatable_btn_search"]');
  await aguarde(3000);

  final resultados =
      await page.$$('[data-id="datatableProcessosAEncaminhar"] table tbody tr');

  if (resultados.isEmpty) {
    throw Exception(
        'Falhar ao encaminhar o processo, processos não listados, pode não existir processos a receber!');
  }
  // busca na lista de resultados o id
  final rowSel = await searchElementByContent(
      page,
      '[data-id="datatableProcessosAEncaminhar"] table tbody',
      'tr',
      codigo,
      'data-label');
  // seleciona o processo na lista de resultados
  await page.click(
      '[data-id="datatableProcessosAEncaminhar"] tbody tr[data-label="$rowSel"] input[data-label="datatable_col_checkbox"]');

  // clica no botão Encaminhar para abrir o modal
  await page.click('button[data-id="btnOpenEncaminhar"]');

  // aguarda abrir o modal
  await aguarde(1000);
  await page.waitForSelector(
      '[data-id="modalEncaminharProcesso"] [data-status="open"]');

  // seleciona orgão
  await scrollIntoView(
      page, '[data-id="modalEncaminharProcesso"] select[name="Orgao"]');
  await selectOptionByAttr(
      page,
      '[data-id="modalEncaminharProcesso"] select[name="Orgao"]',
      'data-value',
      '7');
  await aguarde(2000);
  // seleciona unidade
  await selectOptionByAttr(
      page,
      '[data-id="modalEncaminharProcesso"] select[name="Unidade"]',
      'data-value',
      '1');
  await aguarde(2000);
  // seleciona departamento
  await selectOptionByAttr(
      page,
      '[data-id="modalEncaminharProcesso"] select[name="Departamento"]',
      'data-value',
      '1');
  await aguarde(2000);
  // seleciona setor
  await selectOptionByAttr(
      page,
      '[data-id="modalEncaminharProcesso"] select[name="Setor"]',
      'data-value',
      '1');
  await aguarde(300);
  await scrollIntoView(page, 'button[data-id="btnEncaminharProcesso"]');
  await page.click('button[data-id="btnEncaminharProcesso"]');
  await aguarde(1000);

  // pega a mensagem da notificação
  final msg = await getInnerText(page,
      'div[data-label="notification_component"] div[data-label="notification_item_body"]');

  if (msg?.contains('Processos encaminhado') == false) {
    throw Exception('Falhar ao encaminhar o processo');
  } else {
    print('Processo encaminhado | msg: $msg');
  }
}

void main() async {
  final page = await setupBrowser();
  await autenticar(page, 'isaque.santana', 'Ins257257');
  // await incluirCGM(page, 'f', {'nome': 'Nome Pessoa Fisica Teste'});
  // await incluirCGM(page, 'j', {'nome': 'Nome Pessoa Juridica Teste'});
  final codeP = await incluirProcesso(
      page, {'nomeInteressado': 'Isaque Neves Sant\'ana'});
  await buscaProcessoPorCod(page, codeP);
  await receberProcessoPorCod(page, codeP);
  //await receberPrimeiroProcesso(page);
  await encaminharProcessoByCod(page, codeP);
  await Future.delayed(Duration(seconds: 60));
  await page.browser.close();
}
