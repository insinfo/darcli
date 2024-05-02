/// esta classe representa uma rota da API Rest ou seja um endpoint para ser usando com qualquer framework seja Angel ou Shelf
class MyRoute {
  final String method;
  final String path;
  final Function handler;
  const MyRoute(this.method, this.path, this.handler);

  static RegExp _regex = RegExp(r'\/:(\w+)');

  static const String get = 'get';
  static const String post = 'post';
  static const String delete = 'delete';
  static const String put = 'put';
  static const String patch = 'patch';

  /// para converter rotas estilo Angel para estilo Shelf
  /// '/protocolo/processos/public/site/:anoExercicio/:codProcesso' to '/protocolo/processos/public/site/<anoExercicio>/<codProcesso>'
  String pathAsShelf() {
    if (path.contains(':')) {
      final newpath = path.replaceAllMapped(_regex, (match) {
        return '/<${match.group(1)}>';
      });

      return newpath;
    }
    return path;
  }

  /// converter para upper case
  String methodUpper() {
    return method.toUpperCase();
  }
}
