/// esta classe representa uma rota da API Rest ou seja um endpoint
class RouteItem {
  final String method;
  final String path;
  final Function handler;
  const RouteItem(this.method, this.path, this.handler);

  static RegExp _regex = RegExp(r'\/:(\w+)');

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
