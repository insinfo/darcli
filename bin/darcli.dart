
import 'dart:io' as io;

import 'package:darcli/darcli.dart';
import 'package:darcli/src/cli_app.dart';

void main(List<String> args) {
  final app = CliApp(generators, CliLogger());

  // io.stderr.write("Warning: 'darcli' has been discontinued."
  //     " Please use 'dart create'.\n\n");

  try {
    app.process(args).catchError((Object e, StackTrace st) {
      if (e is ArgError) {
        // These errors are expected.
        io.exit(1);
      } else {
        print('Unexpected error: $e\n$st');

        io.exit(1);
      }
    }).whenComplete(() {
      // Always exit quickly after performing work. If the user has opted into
      // analytics, the analytics I/O can cause the CLI to wait to terminate.
      // This is annoying to the user, as the tool has already completed its
      // work from their perspective.
      io.exit(0);
    });
  } catch (e, st) {
    print('Unexpected error: $e\n$st');
  }
}
