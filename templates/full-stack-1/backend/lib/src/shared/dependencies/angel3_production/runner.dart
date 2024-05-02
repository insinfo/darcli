import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:intl/intl.dart';
import 'package:angel3_container/angel3_container.dart';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_framework/http.dart';
import 'package:angel3_framework/http2.dart';
import 'package:args/args.dart';
import 'package:io/ansi.dart';
import 'package:io/io.dart';
import 'package:logging/logging.dart';
import 'package:belatuk_pub_sub/isolate.dart' as pub_sub;
import 'package:belatuk_pub_sub/belatuk_pub_sub.dart' as pub_sub;
import 'package:new_sali_backend/src/shared/dependencies/stream_isolate/stream_isolate.dart';
import 'package:new_sali_backend/src/shared/dependencies/prometheus_client/prometheus_client.dart';
import 'package:new_sali_backend/src/shared/dependencies/prometheus_client/format.dart' as format;
import 'package:new_sali_backend/src/shared/dependencies/prometheus_client/runtime_metrics.dart'
    as runtime_metrics;
import 'instance_info.dart';
import 'options.dart';
import 'runner_args.dart';

/// A command-line utility for easier running of multiple instances of an Angel application.
///
/// Makes it easy to do things like configure SSL, log messages, and send messages between
/// all running instances.
class Runner {
  final String name;
  final AngelConfigurer configureServer;
  final Reflector reflector;

  Runner(this.name, this.configureServer,
      {this.reflector = const EmptyReflector()});

  static const String asciiArt2 =
      '''

    ___    _   ________________   _____
   /   |  / | / / ____/ ____/ /  |__  /
  / /| | /  |/ / / __/ __/ / /    /_ < 
 / ___ |/ /|  / /_/ / /___/ /______/ / 
/_/  |_/_/ |_/\\____/_____/_____/____/ 
                                                                                                                       
''';

  static const String asciiArt =
      '''

     _    _   _  ____ _____ _     _____ 
    / \\  | \\ | |/ ___| ____| |   |___ / 
   / _ \\ |  \\| | |  _|  _| | |     |_ \\ 
  / ___ \\| |\\  | |_| | |___| |___ ___) |
 /_/   \\_\\_| \\_|\\____|_____|_____|____/                                                                                 
''';

  static const String asciiArtOld =
      '''
____________   ________________________ 
___    |__  | / /_  ____/__  ____/__  / 
__  /| |_   |/ /_  / __ __  __/  __  /  
_  ___ |  /|  / / /_/ / _  /___  _  /___
/_/  |_/_/ |_/  ____/  /_____/  /_____/
                                        
''';

  static final DateFormat _defaultDateFormat =
      DateFormat('yyyy-MM-dd HH:mm:ss');

  /// LogRecord handler
  static void handleLogRecord(LogRecord? record, RunnerOptions options) {
    if (options.quiet || record == null) return;
    var code = chooseLogColor(record.level);

    var now = _defaultDateFormat.format(DateTime.now());

    if (record.error == null) {
      //print(code.wrap(record.message));
      print(code.wrap(
          '$now ${record.level.name} [${record.loggerName}]: ${record.message}'));
    }

    if (record.error != null) {
      var err = record.error;
      if (err is AngelHttpException && err.statusCode != 500) return;
      //print(code.wrap(record.message + '\n'));
      print(code.wrap(
          '$now ${record.level.name} [${record.loggerName}]: ${record.message} \n'));
      print(code.wrap(
          '$now ${record.level.name} [${record.loggerName}]: ${err.toString()}'));

      if (record.stackTrace != null) {
        print(code.wrap(
            '$now ${record.level.name} [${record.loggerName}]: ${record.stackTrace.toString()}'));
      }
    }
  }

  /// Chooses a color based on the logger [level].
  static AnsiCode chooseLogColor(Level level) {
    if (level == Level.SHOUT) {
      return backgroundRed;
    } else if (level == Level.SEVERE) {
      return red;
    } else if (level == Level.WARNING) {
      return yellow;
    } else if (level == Level.INFO) {
      return cyan;
    } else if (level == Level.FINER || level == Level.FINEST) {
      return lightGray;
    }
    return resetAll;
  }

  /// Spawns a new instance of the application in a separate isolate.
  ///
  /// If the command-line arguments permit, then the instance will be respawned on crashes.
  ///
  /// The returned [Future] completes when the application instance exits.
  ///
  /// If respawning is enabled, the [Future] will *never* complete.
  Future spawnIsolate(int id, RunnerOptions options, SendPort pubSubSendPort) {
    return _spawnIsolate(id, Completer(), options, pubSubSendPort);
  }

  final _streamIsolates = <Map<int, BidirectionalStreamIsolate>>[];

  /// receive msg from one isolate and send to all isolates
  void receiveAndPass(event, int idx) {
    _streamIsolates.forEach((item) {
      item.values.first.send(event);
    });
  }

  Future _spawnIsolate(
      int id, Completer c, RunnerOptions options, SendPort pubSubSendPort) {
    var onLogRecord = ReceivePort();
    var onExit = ReceivePort();
    var onError = ReceivePort();
    var runnerArgs = RunnerArgs(name, configureServer, options, reflector,
        onLogRecord.sendPort, pubSubSendPort);
    var argsWithId = RunnerArgsWithId(id, runnerArgs);

    // Isolate.spawn(isolateMain, argsWithId,
    //         onExit: onExit.sendPort,
    //         onError: onError.sendPort,
    //         errorsAreFatal: true && false)

    StreamIsolate.spawnBidirectional(isolateMainStream,
            argument: argsWithId,
            onExit: onExit.sendPort,
            onError: onError.sendPort,
            errorsAreFatal: true && false)
        .then((streamIsolate) {
      _streamIsolates.add({id: streamIsolate});
      streamIsolate.stream.listen((event) => receiveAndPass(event, id));
    })
        //.catchError(c.completeError);
        .catchError((e) {
      c.completeError(e as Object);
      return null;
    });

    onLogRecord.listen((msg) => handleLogRecord(msg as LogRecord?, options));

    onError.listen((msg) {
      if (msg is List) {
        dynamic e = msg[0];
        var st = StackTrace.fromString(msg[1].toString());
        handleLogRecord(
            LogRecord(
                Level.SEVERE, 'Fatal error', runnerArgs.loggerName, e, st),
            options);
      } else {
        handleLogRecord(
            LogRecord(Level.SEVERE, 'Fatal error', runnerArgs.loggerName, msg),
            options);
      }
    });

    onExit.listen((_) {
      if (options.respawn) {
        handleLogRecord(
            LogRecord(
                Level.WARNING,
                'Instance #$id at ${DateTime.now()} crashed. Respawning immediately...',
                runnerArgs.loggerName),
            options);
        _spawnIsolate(id, c, options, pubSubSendPort);
      } else {
        c.complete();
      }
    });

    return c.future
        .whenComplete(onExit.close)
        .whenComplete(onError.close)
        .whenComplete(onLogRecord.close);
  }

  //  isaque adicionou
  /// Boots a shared server instance. Use this if launching multiple isolates.
  static Future<HttpServer> Function(dynamic, int) startSharedHttpServer() {
    return (address, int port) async {
      final server =
          await HttpServer.bind(address ?? '127.0.0.1', port, shared: true);
      server.defaultResponseHeaders.remove('X-Frame-Options', 'SAMEORIGIN');
      return Future.value(server);
    };
  }

  static Future<HttpServer> Function(dynamic, int) startSharedSecureHttpServer(
      SecurityContext securityContext) {
    return (address, int port) async {
      final server = await HttpServer.bindSecure(
          address ?? '127.0.0.1', port, securityContext,
          shared: true);
      server.defaultResponseHeaders.remove('X-Frame-Options', 'SAMEORIGIN');
      return Future.value(server);
    };
  }

  /// Starts a number of isolates, running identical instances of an Angel application.
  Future run(List<String> args) async {
    pub_sub.Server? server;

    try {
      var argResults = RunnerOptions.argParser.parse(args);
      var options = RunnerOptions.fromArgResults(argResults);

      if (options.ssl || options.http2) {
        if (options.certificateFile == null) {
          throw ArgParserException('Missing --certificate-file option.');
        } else if (options.keyFile == null) {
          throw ArgParserException('Missing --key-file option.');
        }
      }

      print(darkGray.wrap(
          '$asciiArt\n\nA batteries-included, full-featured, full-stack framework in Dart.\n\nhttps://angel3-framework.web.app\n'));

      if (argResults['help'] == true) {
        stdout
          ..writeln('Options:')
          ..writeln(RunnerOptions.argParser.usage);
        return;
      }

      print('Starting `$name` application...');

      var adapter = pub_sub.IsolateAdapter();
      server = pub_sub.Server([adapter]);

      // Register clients
      for (var i = 0; i < Platform.numberOfProcessors; i++) {
        server.registerClient(pub_sub.ClientInfo('client$i'));
      }

      server.start();

      await Future.wait(List.generate(options.concurrency,
          (id) => spawnIsolate(id, options, adapter.receivePort.sendPort)));
    } on ArgParserException catch (e) {
      stderr
        ..writeln(red.wrap(e.message))
        ..writeln()
        ..writeln(red.wrap('Options:'))
        ..writeln(red.wrap(RunnerOptions.argParser.usage));
      exitCode = ExitCode.usage.code;
    } catch (e, st) {
      stderr
        ..writeln(red.wrap('fatal error: $e'))
        ..writeln(red.wrap(st.toString()));
      exitCode = 1;
    } finally {
      await server?.close();
    }
  }

  /// isaque add this to capture metrics
  static Stream isolateMainStream(
      Stream mainToIsolateStream, dynamic argsWithId) {
    final isolateToMainStream = StreamController.broadcast();
    final args = argsWithId as RunnerArgsWithId;
    isolateMain(args, isolateToMainStream, mainToIsolateStream);
    return isolateToMainStream.stream;
  }

// isaque add middleware to regiter API access from prometheus
  static void configurePrometheus(Angel app,
      StreamController isolateToMainStream, Stream mainToIsolateStream) {
    final reg = CollectorRegistry(); //CollectorRegistry.defaultRegistry;
    // // Register default runtime metrics
    // runtime_metrics.register(reg);
    // // Register http requests total metrics
    // final http_requests_total = Counter(
    //     name: 'http_requests_total', help: 'Total number of http api requests');
    // http_requests_total.register(reg);

    // Register default runtime metrics
    runtime_metrics.register(reg);
    // Register http requests total metrics
    final http_requests_received_total = Counter(
        name: 'http_requests_received_total',
        help: 'Total number of http api requests',
        labelNames: ['method', 'endpoint']);
    http_requests_received_total.register(reg);

    // listen msg from main
    mainToIsolateStream.listen((msg) {
      final items = msg as List;
      final method = items[0] as String;
      var endpoint = items[1] as String;
      // TODO verificar no futuro uma opção melhor
      if (endpoint.contains('api/v1/estatistica')) {
        endpoint = 'api/v1/estatistica';
      } else if (endpoint.contains('api/v1/administracao')) {
        endpoint = 'api/v1/administracao';
      } else if (endpoint.contains('api/v1/protocolo')) {
        endpoint = 'api/v1/protocolo';
      } else if (endpoint.contains('api/v1/cgm')) {
        endpoint = 'api/v1/cgm';
      } else if (endpoint.contains('api/v1/norma')) {
        endpoint = 'api/v1/norma';
      } else if (endpoint.contains('api/v1/auth')) {
        endpoint = 'api/v1/auth';
      }else{
        endpoint = '/';
      }
      http_requests_received_total.labels([method, endpoint]).inc();
    });

    app.all('*', (RequestContext req, ResponseContext resp) async {
      // Every time http_request is called, increase the counter by one
      if (req.path != 'metrics') {
        //send msg to main
        isolateToMainStream.add([req.method, req.path]);
      }
      return true;
    });
    
    // Register a handler to expose the metrics in the Prometheus text format
    app.get('/metrics', (RequestContext req, ResponseContext resp) async {
      final buffer = StringBuffer();
      final metrics = await reg.collectMetricFamilySamples();
      format.write004(buffer, metrics);
      resp.write(buffer.toString());
      resp.headers.addAll({'Content-Type': format.contentType});
    });
  }

  /// Run with main isolate
  static void isolateMain(RunnerArgsWithId argsWithId,
      StreamController isolateToMainStream, Stream mainToIsolateStream) {
    var args = argsWithId.args;
    hierarchicalLoggingEnabled = false;

    var zone = Zone.current.fork(specification: ZoneSpecification(
      print: (self, parent, zone, msg) {
        args.loggingSendPort.send(LogRecord(Level.INFO, msg, args.loggerName));
      },
    ));

    zone.run(() async {
      var client =
          pub_sub.IsolateClient('client${argsWithId.id}', args.pubSubSendPort);

      var app = Angel(reflector: args.reflector)
        ..container.registerSingleton<pub_sub.Client>(client)
        ..container.registerSingleton(InstanceInfo(id: argsWithId.id));

      app.shutdownHooks.add((_) => client.close());

      // isaque add middleware to regiter API access fro prometheus
      configurePrometheus(app, isolateToMainStream, mainToIsolateStream);

      await app.configure(args.configureServer);

      app.logger = Logger(args.loggerName)
        ..onRecord.listen((rec) => Runner.handleLogRecord(rec, args.options));

      AngelHttp http;
      late SecurityContext securityContext;
      Uri serverUrl;

      if (args.options.ssl || args.options.http2) {
        securityContext = SecurityContext();
        if (args.options.certificateFile != null) {
          securityContext.useCertificateChain(args.options.certificateFile!,
              password: args.options.certificatePassword);
        }

        if (args.options.keyFile != null) {
          securityContext.usePrivateKey(args.options.keyFile!,
              password: args.options.keyPassword);
        }
      }

      if (args.options.ssl) {
        //  change to startSharedSecureHttpServer
        http = AngelHttp.custom(
            app, startSharedSecureHttpServer(securityContext),
            useZone: args.options.useZone);
      } else {
        //  change to startSharedHttpServer
        http = AngelHttp.custom(app, startSharedHttpServer(),
            useZone: args.options.useZone);
      }

      Driver driver;

      if (args.options.http2) {
        securityContext.setAlpnProtocols(['h2'], true);
        var http2 = AngelHttp2.custom(app, securityContext, startSharedHttp2,
            useZone: args.options.useZone);
        http2.onHttp1.listen(http.handleRequest);
        driver = http2;
      } else {
        driver = http;
      }

      await driver.startServer(args.options.hostname, args.options.port);
      serverUrl = driver.uri;
      if (args.options.ssl || args.options.http2) {
        serverUrl = serverUrl.replace(scheme: 'https');
      }
      print('Instance #${argsWithId.id} listening at $serverUrl');
    });
  }
}
