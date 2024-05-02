# alterações no bamco

renomeado na tabela candidatos

id para idCandidato
dataCadastro para dataCadastroCandidato
dataAlteracao para dataAlteracaoCandidato

renomeado na tabela empregadores

dataCadastro para dataCadastroEmpregador

campos timestamptz para timestamp

renomeado campo tipoDeficiencia na tabela tipos_deficiencias para nome
  
  # Rodar o projeto backend
  CREATE EXTENSION unaccent;

  
  ```console
  dart --observe .\bin\main.dart
  ```

  ### Exemplo de classe em Dart
  ```dart
  class ClassExample{
  }
  ```
  
  Configurações iniciais
  ======================
  Abilitar exetenção unaccent no postgresql ```create extension unaccent```
  A classe HotReloader carrega o configureServer (bootstrap.dart);
  
  
  ## Classes
  bootstrap.dart -> (configureServer) é uma classe que encapsula o processo de inicialização do banco de dados.
  configureServer faz:
     ->  1 - db_Connetc (db_connect.dart) -> Faz a conexão com o banco de dados carregando as informações da conexão de contidas em psqlConnInfo;
     ->  2 - db_config -> Contém as informações da conexão "psqlConnInfo";
     ->  3 - "var server" starta o servidor com o endereço configurado ('127.0.0.1', 3000).
  
  Angel --> Uma estrutura de back-end para produção no Dart.
  HotReloader -- > Uma classe de utilitário que observa o sistema de arquivos em busca de alterações e inicia novas instâncias de um servidor Angel.
  
  
  # GitLab
  git add .
  git commit -m "mensagem de commit"
  git push
  
  
  HELP
  ====
  .env -> configurações do ambiente, como o nome do banco de dados, usuário, senha, etc. 
  .gitignore -> arquivos que não devem ser copiados para o repositório.
  
  
  HELP COMANDOS
  =============
  Controller -> candidato.controller.dart
  Repository -> candidato.repository.dart
  
  Excluir com transação -> forma_encaminhamento_controller.dart
  Excluir com transação -> forma_encaminhamento_repository.dart
  
  
  Do Front-end para o Back-end
  ============================
  routes.dart -> Recebe do Front-end o método HTTP será executado, exemplo delete que chama o excluir no controller, exemplo forma_encaminhamento_controller
  
  Cabeçalho headers
  =================
  Para evitar repetir o código: "headers['Content-Type'] = 'application/json;charset=utf-8'"
  Foi criada a extensão request_context_extension.dart que encapsula o cabeçalho dentro do contexto da requisição em uma classe chamada ResponseJson.
  Basta usar a classe chamando o método responseJson(Object value)
  
  
  GLOSSÁRIO
  =========
  Data Binding -> Atualização de dados do front-end para o back-end.
  Controller -> Classe que faz a lógica do Back-end.
  Repository -> Classe que faz a lógica de acesso ao banco de dados.
  Service -> Classe que faz a lógica de acesso ao banco de dados.
  Model -> Classe que representa um registro no banco de dados.
  