import 'dart:io';

import 'package:guardify/src/cli/matrix_runner.dart';

/// Entrypoint trampoline for `dart run guardify:matrix` CLI command.
Future<void> main(List<String> args) async {
  exitCode = await runMatrixCli(args);
}
