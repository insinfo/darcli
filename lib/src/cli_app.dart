import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:math';

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../darcli.dart';
import 'common.dart';

import 'version.dart';

const String appName = 'darcli';

final _appPubInfo = Uri.https('pub.dev', '/packages/$appName.json');

class CliApp {
  final List<Generator> generators;
  final CliLogger logger;

  GeneratorTarget? target;

  io.Directory? _cwd;
  bool _firstScreen = true;

  CliApp(this.generators, this.logger, [this.target]) {
    generators.sort();
  }

  io.Directory get cwd => _cwd ?? io.Directory.current;

  /// An override for the directory to generate into; public for testing.
  set cwd(io.Directory value) {
    _cwd = value;
  }

  Future process(List<String> args) async {
    final argParser = _createArgParser();

    ArgResults options;

    try {
      options = argParser.parse(args);
    } catch (e, st) {
      // FormatException: Could not find an option named "foo".
      if (e is FormatException) {
        _out('Error: ${e.message}');
        return Future.error(ArgError(e.message));
      } else {
        return Future.error(e, st);
      }
    }

    // This hidden option is used so that our build bots don't emit data.

    if (options['version']) {
      _out('$appName version: $packageVersion');
      return http.get(_appPubInfo).then((response) {
        final List versions = jsonDecode(response.body)['versions'];
        if (packageVersion != versions.last) {
          _out('Version ${versions.last} is available! Run `pub global activate'
              ' $appName` to get the latest.');
        }
      }).catchError((e) => null);
    }

    if (options['help'] || args.isEmpty) {
      _screenView(options['help'] ? 'help' : 'main');
      _usage(argParser);
      return;
    }

    // The `--machine` option emits the list of available generators to stdout
    // as JSON. This is useful for tools that don't want to have to parse the
    // output of `--help`. It's an undocumented command line flag, and may go
    // away or change.
    if (options['machine']) {
      _screenView('machine');
      logger.stdout(_createMachineInfo(generators));
      return;
    }

    if (options.rest.isEmpty) {
      logger.stderr('No generator specified.\n');
      _usage(argParser);
      return Future.error(ArgError('no generator specified'));
    }

    if (options.rest.length >= 2) {
      logger.stderr('Error: too many arguments given.\n');
      _usage(argParser);
      return Future.error(ArgError('invalid generator'));
    }

    final generatorName = options.rest.first;
    final generator = _getGenerator(generatorName);

    final dir = cwd;

    if (!options['override'] && !await _isDirEmpty(dir)) {
      logger.stderr(
        'The current directory is not empty. Please create a new project '
        'directory, or use --override to force generation into the current '
        'directory.',
      );
      return Future.error(ArgError('project directory not empty'));
    }

    // Normalize the project name.
    var projectName = path.basename(dir.path);
    projectName = normalizeProjectName(projectName);

    target ??= _DirectoryGeneratorTarget(logger, dir);

    _out('Creating $generatorName application `$projectName`:');

    _screenView('create');

    String author = options['author'];

    if (!options.wasParsed('author')) {
      try {
        final result = io.Process.runSync('git', ['config', 'user.name']);
        if (result.exitCode == 0) author = result.stdout.trim();
      } catch (exception) {
        // NOOP
      }
    }

    var email = 'email@example.com';

    try {
      final result = io.Process.runSync('git', ['config', 'user.email']);
      if (result.exitCode == 0) email = result.stdout.trim();
    } catch (exception) {
      // NOOP
    }

    final vars = {'author': author, 'email': email};

    final f = generator.generate(projectName, target!, additionalVars: vars);
    return f.then((_) {
      _out('${generator.numFiles()} files written.');

      var message = generator.getInstallInstructions();
      if (message.isNotEmpty) {
        message = message.trim();
        message = message.split('\n').map((line) => '--> $line').join('\n');
        _out('\n$message');
      }
    }).then((_) {});
  }

  ArgParser _createArgParser() => ArgParser()
    ..addFlag(
      'analytics',
      help: 'Opt out of anonymous usage and crash reporting.',
    )
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Help!')
    ..addFlag(
      'version',
      negatable: false,
      help: 'Display the version for $appName.',
    )
    ..addOption(
      'author',
      defaultsTo: '<your name>',
      help: 'The author name to use for file headers.',
    )
    // Really, really generate into the current directory.
    ..addFlag('override', negatable: false, hide: true)
    // Output the list of available projects as JSON to stdout.
    ..addFlag('machine', negatable: false, hide: true)
    // Mock out analytics - for use on our testing bots.
    ..addFlag('mock-analytics', negatable: false, hide: true);

  String _createMachineInfo(List<Generator> generators) {
    final itor = generators.map((Generator generator) {
      final m = {
        'name': generator.id,
        'label': generator.label,
        'description': generator.description,
        'categories': generator.categories
      };

      if (generator.entrypoint != null) {
        m['entrypoint'] = generator.entrypoint!.path;
      }

      return m;
    });
    return json.encode(itor.toList());
  }

  void _usage(ArgParser argParser) {
    _out(
      'darcli will generate the given application type into the current '
      'directory.',
    );
    _out('');
    _out('usage: $appName <generator-name>');
    _out(argParser.usage);
    _out('');
    _out('Available generators:');
    final len = generators.fold(0, (int length, g) => max(length, g.id.length));
    generators
        .map((g) => '  ${g.id.padRight(len)} - ${g.description}')
        .forEach(logger.stdout);
  }

  Generator _getGenerator(String id) =>
      generators.firstWhere((g) => g.id == id);

  void _out(String str) => logger.stdout(str);

  void _screenView(String view) {
    // ignore: unused_local_variable
    Map<String, String> params;
    if (_firstScreen) {
      params = {'sc': 'start'};
      _firstScreen = false;
    }
  }

  /// Returns true if the given directory does not contain non-symlinked,
  /// non-hidden subdirectories.
  static Future<bool> _isDirEmpty(io.Directory dir) async {
    bool isHiddenDir(dir) => path.basename(dir.path).startsWith('.');

    return dir
        .list(followLinks: false)
        .where((entity) => entity is io.Directory)
        .where((entity) => !isHiddenDir(entity))
        .isEmpty;
  }
}

class ArgError implements Exception {
  final String message;
  ArgError(this.message);

  @override
  String toString() => message;
}

class CliLogger {
  void stdout(String message) => print(message);
  void stderr(String message) => print(message);
}

class _DirectoryGeneratorTarget extends GeneratorTarget {
  final CliLogger logger;
  final io.Directory dir;

  _DirectoryGeneratorTarget(this.logger, this.dir) {
    dir.createSync();
  }

  @override
  Future createFile(String filePath, List<int> contents) {
    final file = io.File(path.join(dir.path, filePath));

    logger.stdout('  ${file.path}');

    return file
        .create(recursive: true)
        .then((_) => file.writeAsBytes(contents));
  }
}
