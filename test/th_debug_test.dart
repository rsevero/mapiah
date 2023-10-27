import 'package:petitparser/petitparser.dart';
import 'package:petitparser/debug.dart';
import 'package:test/test.dart';

import 'package:mapiah/src/th_file_aux/th_grammar.dart';

void main() {
  final grammar = THGrammar();
  final parser = grammar.buildFrom(grammar.start());
  trace(parser)
      // .parse('-scale [-164.0 -2396.0 m]');
      .parse('-scale [-164.0 -2396.0 3308.0 -2396.0 0.0 0.0 88.1888 0.0 m]');
}
