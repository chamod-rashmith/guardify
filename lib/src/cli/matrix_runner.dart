import 'dart:io';
import 'package:args/args.dart';

import 'code_scanner.dart';
import 'matrix_formatter.dart';

/// Primary CLI execution function for the Access Control Matrix (ACM) tool.
///
/// Returns standard POSIX exit codes (0 for success, 64 for usage error, 70 for software crash).
Future<int> runMatrixCli(
  List<String> args, {
  StringSink? stdoutOverride,
  StringSink? stderrOverride,
  CodeScanner scanner = const CodeScanner(),
  MatrixFormatter formatter = const MatrixFormatter(),
}) async {
  final out = stdoutOverride ?? stdout;
  final err = stderrOverride ?? stderr;

  final parser = ArgParser()
    ..addOption(
      'path',
      abbr: 'p',
      defaultsTo: 'lib',
      help: 'Directory or file path to scan for role-gated widgets and components.',
    )
    ..addOption(
      'output',
      abbr: 'o',
      help: 'Destination file path to save the generated report (e.g. SECURITY_MATRIX.md or matrix.json).',
    )
    ..addOption(
      'format',
      abbr: 'f',
      defaultsTo: 'console',
      allowed: ['console', 'markdown', 'md', 'json'],
      help: 'Output report format.',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Displays command usage instructions.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Prints diagnostic scan logs.',
    );

  final ArgResults results;
  try {
    results = parser.parse(args);
  } on FormatException catch (e) {
    err.writeln('Error: ${e.message}');
    err.writeln();
    err.writeln('Usage: dart run guardify:matrix [options]');
    err.writeln(parser.usage);
    return 64; // ExitCode.usage.code
  }

  if (results['help'] as bool) {
    out.writeln('🛡️ Guardify Access Control Matrix (ACM) Tool');
    out.writeln('Scans your Flutter codebase and generates an audit matrix of role & permission gated widgets.');
    out.writeln();
    out.writeln('Usage: dart run guardify:matrix [options]');
    out.writeln(parser.usage);
    return 0;
  }

  final targetPath = results['path'] as String;
  final outputPath = results['output'] as String?;
  final format = results['format'] as String;
  final isVerbose = results['verbose'] as bool;

  if (isVerbose) {
    err.writeln('🔍 Scanning directory: $targetPath...');
  }

  try {
    final report = await scanner.scanPath(targetPath);

    if (isVerbose) {
      err.writeln('✅ Scan complete: found ${report.components.length} components across ${report.allRoles.length} roles.');
    }

    final outputContent = switch (format) {
      'markdown' || 'md' => formatter.formatMarkdown(report),
      'json' => formatter.formatJson(report),
      _ => formatter.formatConsole(report),
    };

    if (outputPath != null && outputPath.isNotEmpty) {
      final outputFile = File(outputPath);
      await outputFile.parent.create(recursive: true);
      await outputFile.writeAsString(outputContent);
      out.writeln('📄 Access Control Matrix successfully saved to: $outputPath');
    } else {
      out.write(outputContent);
    }

    return 0;
  } catch (e, st) {
    err.writeln('Internal error while scanning codebase: $e');
    if (isVerbose) {
      err.writeln(st);
    }
    return 70; // ExitCode.software.code
  }
}
