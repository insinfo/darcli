class StatusMessage {
  static const String ACESSO_NAO_AUTORIZADO = 'Acesso Não Autorizado!';
  static const String SUCCESS = 'Sucesso ao executar operação';
  static const String ERROR_GENERIC = 'Erro ao executar esta operação';
  static const String ERROR_GENERIC_FRONTEND = 'Erro ao executar esta operação, clique em detalhes para saber mais.';
  static const String ERROR_WHILE_WRITING_DATA = 'ERRO AO GRAVAR DADOS';
  static const String ERROR_CONFIRMING_REGISTRATION =
      'Erro ao confirmar o cadastro!';
  static const String ERROR_WHEN_UPDATE_DATA = 'ERRO AO ATUALIZAR DADOS';
  static const String ERROR_DELETING_DATA = 'ERRO AO DELETAR DADOS';

  static const String USER_NOT_ACTIVATED =
      'Usuário não ativado, acesse seu email para ativar o cadastro!';

  static const String USER_NOT_FOUND = 'Usuário não encontrado!';

  static const String NOT_AUTHORIZED =
      'Acesso não autorizado, verifique nome de usuário e senha!';

  static const String NOT_AUTHORIZED_TO_DELETE =
      'Seu perfil não está autorizado a excluir itens!';

  static const String DELETE_CONFIRMATION_MESSAGE =
      'Tem certeza de que deseja remover este item?';

  static const String UPDATE_CONFIRMATION_MESSAGE =
      'Tem certeza de que alterar este item?';

  /// Não foi executar tarefa, sua sessão pode ter expirado, tente sair e entrar novamente
  static const String POSSIVEL_TOKEN_EXPIRED =
      '''Não foi executar tarefa, sua sessão pode ter expirado, tente sair e entrar novamente.''';

  static get seccessMap => {'message': StatusMessage.SUCCESS};
}
