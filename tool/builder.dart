
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/code_generator.dart';

Builder darcliBuilder([_]) => PartBuilder([
      DataGenerator(),
    ], '.g.dart');
