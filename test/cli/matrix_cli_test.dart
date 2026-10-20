import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:guardify/src/cli/code_scanner.dart';
import 'package:guardify/src/cli/matrix_formatter.dart';
import 'package:guardify/src/cli/matrix_model.dart';
import 'package:guardify/src/cli/matrix_runner.dart';

void main() {
  group('Access Control Matrix (ACM) CLI Tests', () {
    test('GatedComponent evaluateRole evaluates granted, disabled, and denied states', () {
      const comp = GatedComponent(
        name: 'TestButton',
        filePath: 'lib/button.dart',
        lineNumber: 10,
        allowedRoles: ['admin', 'manager'],
        fallbackType: 'disabled',
      );

      expect(comp.evaluateRole('admin'), equals(AccessStatus.granted));
      expect(comp.evaluateRole('manager'), equals(AccessStatus.granted));
      expect(comp.evaluateRole('guest'), equals(AccessStatus.disabled));

      const hideComp = GatedComponent(
        name: 'SecretCard',
        filePath: 'lib/card.dart',
        lineNumber: 20,
        allowedRoles: ['admin'],
        fallbackType: 'hide',
      );
      expect(hideComp.evaluateRole('guest'), equals(AccessStatus.denied));
    });

    test('MatrixFormatter produces valid Markdown, JSON, and Console outputs', () {
      final report = AccessMatrixReport(
        components: [
          const GatedComponent(
            name: 'AdminPanel',
            filePath: 'lib/panel.dart',
            lineNumber: 15,
            allowedRoles: ['admin'],
            allowedPermissions: ['admin:access'],
            fallbackType: 'scaffold',
          ),
        ],
        allRoles: {'admin', 'user'},
        allPermissions: {'admin:access'},
      );

      const formatter = MatrixFormatter();

      final md = formatter.formatMarkdown(report);
      expect(md, contains('# 🛡️ Access Control Matrix (ACM) Report'));
      expect(md, contains('AdminPanel'));
      expect(md, contains('✅ Allowed'));
      expect(md, contains('❌ Denied'));

      final jsonStr = formatter.formatJson(report);
      expect(jsonStr, contains('"AdminPanel"'));
      expect(jsonStr, contains('"admin": "granted"'));

      final console = formatter.formatConsole(report, useAnsi: false);
      expect(console, contains('GUARDIFY ACCESS CONTROL MATRIX'));
      expect(console, contains('AdminPanel'));
    });

    test('CodeScanner detects components in example directory', () async {
      const scanner = CodeScanner();
      final report = await scanner.scanPath('example');

      expect(report.components.isNotEmpty, isTrue);
      expect(report.allRoles, containsAll(['admin', 'manager', 'finance', 'superadmin']));

      final deleteBtn = report.components.firstWhere((c) => c.name == 'DeleteUserButton');
      expect(deleteBtn.allowedRoles, containsAll(['admin', 'superadmin']));
      expect(deleteBtn.fallbackType, equals('hide'));
    });

    test('runMatrixCli returns 0 for --help', () async {
      final out = StringBuffer();
      final err = StringBuffer();

      final exit = await runMatrixCli(['--help'], stdoutOverride: out, stderrOverride: err);

      expect(exit, equals(0));
      expect(out.toString(), contains('Guardify Access Control Matrix'));
    });

    test('runMatrixCli returns 64 for invalid arguments', () async {
      final out = StringBuffer();
      final err = StringBuffer();

      final exit = await runMatrixCli(['--invalid-flag-xyz'], stdoutOverride: out, stderrOverride: err);

      expect(exit, equals(64));
      expect(err.toString(), contains('Error:'));
    });

    test('runMatrixCli saves output file when --output is provided', () async {
      final tempDir = await Directory.systemTemp.createTemp('guardify_test_');
      final targetOutput = '${tempDir.path}/test_matrix.md';

      final out = StringBuffer();
      final err = StringBuffer();

      final exit = await runMatrixCli(
        ['--path=example', '--format=markdown', '--output=$targetOutput'],
        stdoutOverride: out,
        stderrOverride: err,
      );

      expect(exit, equals(0));
      final file = File(targetOutput);
      expect(await file.exists(), isTrue);

      final content = await file.readAsString();
      expect(content, contains('# 🛡️ Access Control Matrix (ACM) Report'));

      await tempDir.delete(recursive: true);
    });
  });
}
