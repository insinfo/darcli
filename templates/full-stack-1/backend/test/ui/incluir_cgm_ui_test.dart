import 'package:new_sali_core/new_sali_core.dart';

import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';
import 'setup_ui.dart';

/// testes de ui
void main() {
  late Page page;

  setUp(() async {
    page = await setupBrowser(headless: false);
    await autenticar(page, 'isaque.santana', 'Ins257257');
  });

  tearDown(() async {
    await aguarde(120000);
    await page.browser.close();
  });

  test('ui test incluir cgm pessoa fisica completo', () async {
    await menuNavigate(
        page, ['Administrativa', 'CGM', 'Manutenção', 'Incluir CGM']);

    final tipoPessoa = 'f';
    final nome = 'Nome Pessoa Fisica Teste';

    //Dados CGM
    await page.select('select[name="tipoPessoa"]', [tipoPessoa]);
    await aguarde(500);
    await page.type('input[name="nome"]', nome);
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
    //Dados endereço
    await page.select('select[name="tipo_logradouro"]', ['Rua']);
    await page.type('input[name="logradouro"]', 'Anita');
    await page.type('input[name="numero"]', '0');
    await page.type('input[name="complemento"]', 'Casa de Cima');

    //page.select('select[name="pais"]', ['6: 1']);  await aguarde(2100);
    await selectOptionByTextAndWait(page, 'select[name="pais"]', 'Brasil',
        '$baseUrlWithPath/administracao/ufs?limit=195&offset=0&orderDir=desc&codPais=');

    // await page.select('select[name="estado"]', ['48: 19']);
    // await aguarde(2100);

    await selectOptionByTextAndWait(
        page,
        'select[name="estado"]',
        'Rio de Janeiro',
        '$baseUrlWithPath/administracao/municipios?limit=853&offset=0&orderDir=desc&codUf=');

    // await page.select('select[name="municipio"]', ['158: 66']);
    await selectOptionByText2(
        page, 'select[name="municipio"]', 'city');

    await page.type('input[name="bairro"]', 'Costazul');
    await page.type('input[name="cep"]', '28895234');
    //Dados contato
    await page.type('input[name="fone_residencial"]', '2227772339');
    await page.type('input[name="fone_comercial"]', '2227776464');
    await page.type('input[name="ramal_comercial"]', '171');
    await page.type('input[name="fone_celular"]', '22997015305');
    await page.type('input[name="e_mail"]', 'email.teste@teste.com');
    await page.type('input[name="e_mail_adcional"]', 'email.teste@teste.com');
    await page.type('input[name="Observação"]', 'Observação teste');
    await aguarde(500);
    await scrollIntoView(page, '#btnSalvarPessoa');
    await aguarde(500);
    await page.click('#btnSalvarPessoa');
    final spanCgm = await page.waitForSelector('.lastCgmCad');
    final cgm = int.tryParse(await spanCgm!.evaluate('node => node.innerText'));
    print('ui test incluir cgm pessoa fisica: $cgm');
    expect(cgm != null, true);
  });

  test('ui test incluir cgm pessoa fisica minimo', () async {
    await menuNavigate(
        page, ['Administrativa', 'CGM', 'Manutenção', 'Incluir CGM']);

    final tipoPessoa = 'f';
    final nome = 'Nome Pessoa Fisica minimo Teste';

    //Dados CGM
    await page.select('select[name="tipoPessoa"]', [tipoPessoa]);
    await aguarde(500);
    await page.type('input[name="nome"]', nome);
    await page.type('input[name="cpf"]', CpfUtil().generate());
    await page.type('input[name="rg"]', '217504877');
    await page.type('input[name="orgaoEmissor"]', 'Detran');
    await aguarde(150);
    await selectOptionByText2(
        page, 'select[name="cod_uf_orgao_emissor"]', 'Rio de Janeiro');
    await selectOptionByText2(
        page, 'select[name="cod_nacionalidade"]', 'Brasileira');
    await selectOptionByText2(
        page, 'select[name="cod_escolaridade"]', '2o grau completo');
    //await page.type('input[name="dt_nascimento"]', '14/09/1987');
    await page.select('select[name="sexo"]', ['m']);
    //Dados endereço
    await page.select('select[name="tipo_logradouro"]', ['Rua']);
    await page.type('input[name="logradouro"]', 'Anita');
    await page.type('input[name="numero"]', '0');
    // await page.type('input[name="complemento"]', 'Casa de Cima');

    await selectOptionByTextAndWait(page, 'select[name="pais"]', 'Brasil',
        '$baseUrlWithPath/administracao/ufs?limit=195&offset=0&orderDir=desc&codPais=');

    await selectOptionByTextAndWait(
        page,
        'select[name="estado"]',
        'Rio de Janeiro',
        '$baseUrlWithPath/administracao/municipios?limit=853&offset=0&orderDir=desc&codUf=');

    await selectOptionByText2(
        page, 'select[name="municipio"]', 'city');

    await page.type('input[name="bairro"]', 'Costazul');
    await page.type('input[name="cep"]', '28895234');

    await aguarde(500);
    await scrollIntoView(page, '#btnSalvarPessoa');
    await aguarde(500);
    await page.click('#btnSalvarPessoa');
    final spanCgm = await page.waitForSelector('.lastCgmCad');
    final cgm = int.tryParse(await spanCgm!.evaluate('node => node.innerText'));
    print('ui test incluir cgm pessoa fisica minimo: $cgm');
    expect(cgm != null, true);
  });

  test('ui test incluir cgm pessoa juridica minimo', () async {
    await menuNavigate(
        page, ['Administrativa', 'CGM', 'Manutenção', 'Incluir CGM']);

    final tipoPessoa = 'j';
    final nome = 'Nome Pessoa Juridica minimo Teste';

    //Dados CGM
    await page.select('select[name="tipoPessoa"]', [tipoPessoa]);
    await aguarde(500);
    await page.type('input[name="nome"]', nome);
    await page.type('input[name="cnpj"]', CnpjUtil.generate());

    //Dados endereço
    await page.select('select[name="tipo_logradouro"]', ['Rua']);
    await page.type('input[name="logradouro"]', 'Anita');
    await page.type('input[name="numero"]', '0');
   
    await selectOptionByTextAndWait(page, 'select[name="pais"]', 'Brasil',
        '$baseUrlWithPath/administracao/ufs?limit=195&offset=0&orderDir=desc&codPais=');

    await selectOptionByTextAndWait(
        page,
        'select[name="estado"]',
        'Rio de Janeiro',
        '$baseUrlWithPath/administracao/municipios?limit=853&offset=0&orderDir=desc&codUf=');

    await selectOptionByText2(
        page, 'select[name="municipio"]', 'city');

    await page.type('input[name="bairro"]', 'Costazul');
    await page.type('input[name="cep"]', '28895234');

    await aguarde(500);
    await scrollIntoView(page, '#btnSalvarPessoa');
    await aguarde(500);
    await page.click('#btnSalvarPessoa');
    final spanCgm = await page.waitForSelector('.lastCgmCad');
    final cgm = int.tryParse(await spanCgm!.evaluate('node => node.innerText'));
    print('ui test incluir cgm pessoa juridica minimo: $cgm');
    expect(cgm != null, true);
  });
}
