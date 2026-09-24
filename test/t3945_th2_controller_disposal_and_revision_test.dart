// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/widgets/th2_file_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

import 'th2_file_tabs_page_test_aux.dart';
import 'th_test_aux.dart';

const String _th2Contents =
    'encoding utf-8\n'
    'scrap s1 -projection plan\n'
    '  point 1 1 station -id p1 -name 1\n'
    '  point 3 3 station -id p2 -name 2\n'
    '  line wall -id l1\n'
    '    10 20\n'
    '    30 40\n'
    '  endline\n'
    'endscrap\n'
    'scrap s2 -projection plan\n'
    '  point 5 5 station -id p3 -name 3\n'
    'endscrap\n';

/// A temporary project whose `cave.th` inputs `passage.th2`.
class _TempProject {
  final Directory directory;

  const _TempProject(this.directory);

  String get configPath => p.join(directory.path, 'thconfig');

  String get th2Path => p.join(directory.path, 'passage.th2');

  static _TempProject create() {
    final Directory directory = Directory.systemTemp.createTempSync(
      'mapiah_t3945_',
    );

    File(p.join(directory.path, 'thconfig'))
        .writeAsStringSync('encoding UTF-8\nsource cave.th\n');
    File(p.join(directory.path, 'cave.th')).writeAsStringSync(
      'survey cave\n  input passage.th2\nendsurvey\n',
    );
    File(p.join(directory.path, 'passage.th2')).writeAsStringSync(_th2Contents);

    return _TempProject(directory);
  }
}

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator mpLocator = MPLocator();
  final List<Directory> tempDirectories = <Directory>[];

  _TempProject newProject() {
    final _TempProject project = _TempProject.create();

    tempDirectories.add(project.directory);

    return project;
  }

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    await mpLocator.mpSettingsController.initialized;
    mpLocator.thProjectController.closeProject();
    mpLocator.mpGeneralController.reset();
  });

  tearDown(() {
    mpLocator.thProjectController.closeProject();
    mpLocator.mpGeneralController.reset();

    for (final Directory directory in tempDirectories) {
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    }

    tempDirectories.clear();
  });

  Future<TH2FileEditController> loadTablessController(String path) async {
    final TH2FileEditController controller = mpLocator.mpGeneralController
        .getTH2FileEditController(filename: path);

    await controller.load();

    return controller;
  }

  Future<TH2FileEditController> loadStandalone(String contents) async {
    final TH2FileEditController controller = mpLocator.mpGeneralController
        .getTH2FileEditController(
          filename: '/tmp/mapiah-t3945-standalone.th2',
          fileBytes: Uint8List.fromList(utf8.encode(contents)),
        );

    await controller.load();

    return controller;
  }

  int id(TH2FileEditController controller, String thID) =>
      controller.th2File.mpIDByTHID(thID)!;

  group('tab-less project controllers', () {
    test('are disposed when the project closes', () async {
      final _TempProject project = newProject();

      await mpLocator.thProjectController.openProject(project.configPath);

      final TH2FileEditController controller = await loadTablessController(
        project.th2Path,
      );

      mpLocator.thProjectController.closeProject();

      expect(controller.isDisposed, isTrue);
      expect(
        mpLocator.mpGeneralController.getTH2FileEditControllerIfExists(
          project.th2Path,
        ),
        isNull,
      );
    });

    test('are disposed on project reload and recreated on access', () async {
      final _TempProject project = newProject();

      await mpLocator.thProjectController.openProject(project.configPath);

      final TH2FileEditController controller = await loadTablessController(
        project.th2Path,
      );

      await mpLocator.thProjectController.reloadProject();

      expect(controller.isDisposed, isTrue);

      final TH2FileEditController recreated = await loadTablessController(
        project.th2Path,
      );

      expect(recreated, isNot(same(controller)));
      expect(recreated.isDisposed, isFalse);
      expect(recreated.isFileLoaded, isTrue);
    });

    test('are disposed when another project replaces the current one', () async {
      final _TempProject first = newProject();
      final _TempProject second = newProject();

      await mpLocator.thProjectController.openProject(first.configPath);

      final TH2FileEditController controller = await loadTablessController(
        first.th2Path,
      );

      await mpLocator.thProjectController.openProject(second.configPath);

      expect(controller.isDisposed, isTrue);
    });

    test('dirty ones are disposed and the next access reads the disk', () async {
      final _TempProject project = newProject();

      await mpLocator.thProjectController.openProject(project.configPath);

      final TH2FileEditController controller = await loadTablessController(
        project.th2Path,
      );

      controller.elementEditController.bringForward(
        elementMPIDs: <int>[id(controller, 'p1')],
      );
      expect(controller.enableSaveButton, isTrue);

      mpLocator.thProjectController.closeProject();

      expect(controller.isDisposed, isTrue);

      final TH2FileEditController reloaded = await loadTablessController(
        project.th2Path,
      );
      final THScrap scrap =
          reloaded.th2File.elementByMPID(id(reloaded, 's1')) as THScrap;

      expect(scrap.childrenMPIDs.first, id(reloaded, 'p1'));
      expect(reloaded.enableSaveButton, isFalse);
    });

    test('standalone controllers outside the project are untouched', () async {
      final _TempProject project = newProject();

      await mpLocator.thProjectController.openProject(project.configPath);

      final TH2FileEditController standalone = await loadStandalone(
        _th2Contents,
      );

      mpLocator.thProjectController.closeProject();

      expect(standalone.isDisposed, isFalse);
      expect(
        mpLocator.mpGeneralController.getTH2FileEditControllerIfExists(
          standalone.th2File.filename,
        ),
        same(standalone),
      );
    });
  });

  group('disposal paths', () {
    test('closing a tab disposes its controller', () async {
      final TH2FileEditController controller = await loadStandalone(
        _th2Contents,
      );

      mpLocator.mpGeneralController.addFileTab(controller.th2File.filename);
      controller.close();

      expect(controller.isDisposed, isTrue);
    });

    test('reloadTH2File disposes the replaced controller', () async {
      final _TempProject project = newProject();
      final TH2FileEditController controller = await loadTablessController(
        project.th2Path,
      );
      final TH2FileEditController replacement = await mpLocator
          .mpGeneralController
          .reloadTH2File(project.th2Path);

      expect(controller.isDisposed, isTrue);
      expect(replacement.isDisposed, isFalse);
    });

    test('forceNewController disposes the replaced controller', () async {
      final TH2FileEditController controller = await loadStandalone(
        _th2Contents,
      );

      mpLocator.mpGeneralController.getTH2FileEditController(
        filename: controller.th2File.filename,
        forceNewController: true,
      );

      expect(controller.isDisposed, isTrue);
    });

    test('close followed by removal disposes once', () async {
      final TH2FileEditController controller = await loadStandalone(
        _th2Contents,
      );

      mpLocator.mpGeneralController.addFileTab(controller.th2File.filename);
      controller.close();
      controller.dispose();
      mpLocator.mpGeneralController.removeFileController(
        filename: controller.th2File.filename,
      );

      expect(controller.isDisposed, isTrue);
      expect(
        () => ChangeNotifier.debugAssertNotDisposed(
          controller.isInteractiveLineSimplificationDialogOpen,
        ),
        throwsFlutterError,
      );
    });

    test('a controller without a canvas disposes its focus node now', () async {
      final TH2FileEditController controller = await loadStandalone(
        _th2Contents,
      );

      controller.dispose();

      expect(
        () => ChangeNotifier.debugAssertNotDisposed(controller.th2FileFocusNode),
        throwsFlutterError,
      );
      expect(
        () => ChangeNotifier.debugAssertNotDisposed(
          controller.isInteractiveLineSimplificationDialogOpen,
        ),
        throwsFlutterError,
      );
    });

    test('reset disposes every registered TH2 controller', () async {
      final TH2FileEditController first = await loadStandalone(_th2Contents);
      final TH2FileEditController second = mpLocator.mpGeneralController
          .getTH2FileEditControllerForNewFile(
            scrapTHID: 'new',
            scrapOptions: const <THCommandOption>[],
            encoding: mpDefaultEncoding,
          );

      mpLocator.mpGeneralController.reset();

      expect(first.isDisposed, isTrue);
      expect(second.isDisposed, isTrue);
    });

    testWidgets('closing a mounted canvas tab disposes its focus node later', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final TH2FileEditController controller = mpLocator.mpGeneralController
          .getTH2FileEditController(
            filename: '/tmp/mapiah-t3945-canvas.th2',
            fileBytes: Uint8List.fromList(utf8.encode(_th2Contents)),
          );

      await tester.runAsync(() => controller.load());
      await tester.pumpWidget(
        buildTH2FileTabsPageTestApp(th2FileEditController: controller),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(TH2FileWidget), findsOneWidget);

      final FocusNode focusNode = controller.th2FileFocusNode;

      controller.close();

      expect(() => ChangeNotifier.debugAssertNotDisposed(focusNode), returnsNormally);

      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(
        () => ChangeNotifier.debugAssertNotDisposed(focusNode),
        throwsFlutterError,
      );
    });
  });

  group('structure revision', () {
    test('loading valid, broken and new files each leave exactly one', () async {
      final TH2FileEditController valid = await loadStandalone(_th2Contents);

      expect(valid.structureRevision, 1);

      final TH2FileEditController broken = mpLocator.mpGeneralController
          .getTH2FileEditController(
            filename: '/tmp/mapiah-t3945-broken.th2',
            fileBytes: Uint8List.fromList(
              utf8.encode('encoding utf-8\npoint 1 1 station\n'),
            ),
          );

      await broken.load();

      expect(broken.isBroken, isTrue);
      expect(broken.structureRevision, 1);

      final TH2FileEditController newFile = mpLocator.mpGeneralController
          .getTH2FileEditControllerForNewFile(
            scrapTHID: 'new',
            scrapOptions: const <THCommandOption>[],
            encoding: mpDefaultEncoding,
          );

      expect(newFile.structureRevision, 1);
    });

    test('advances once per move, undo and redo', () async {
      final TH2FileEditController controller = await loadStandalone(
        _th2Contents,
      );

      controller.elementEditController.bringForward(
        elementMPIDs: <int>[id(controller, 'p1')],
      );
      expect(controller.structureRevision, 2);

      controller.undo();
      expect(controller.structureRevision, 3);

      controller.redo();
      expect(controller.structureRevision, 4);
    });

    test('does not advance when a line segment is added', () async {
      final TH2FileEditController controller = await loadStandalone(
        _th2Contents,
      );
      final int line = id(controller, 'l1');

      controller.elementEditController.executeAddLineSegment(
        newLineSegment: THStraightLineSegment(
          parentMPID: line,
          endPoint: THPositionPart(coordinates: const Offset(60, 70)),
        ),
        lineSegmentPositionInParent: mpAddChildAtEndMinusOneOfParentChildrenList,
      );

      expect(controller.structureRevision, 1);
    });

    test('advances on a type edit and on id option changes', () async {
      final TH2FileEditController controller = await loadStandalone(
        _th2Contents,
      );
      final int point = id(controller, 'p2');

      controller.execute(
        MPCommandFactory.editPointsType(
          pointMPIDs: <int>[point],
          newPointType: THPointType.fromString('label'),
          unknownPLAType: '',
        ),
      );
      expect(controller.structureRevision, 2);

      controller.execute(
        MPSetOptionToElementCommand(
          toOption: THIDCommandOption(parentMPID: point, thID: 'renamed'),
        ),
      );
      expect(controller.structureRevision, 3);

      controller.execute(
        MPCommandFactory.removeOptionFromElements(
          optionType: THCommandOptionType.id,
          parentMPIDs: <int>[point],
          th2File: controller.th2File,
        ),
      );
      expect(controller.structureRevision, 4);
    });

    test('does not advance on geometry moves', () async {
      final TH2FileEditController controller = await loadStandalone(
        _th2Contents,
      );
      final THPoint point =
          controller.th2File.elementByMPID(id(controller, 'p1')) as THPoint;

      controller.execute(
        MPMovePointCommand(
          pointMPID: point.mpID,
          fromPosition: point.position,
          toPosition: THPositionPart(coordinates: const Offset(9, 9)),
          fromOriginalLineInTH2File: point.originalLineInTH2File,
          toOriginalLineInTH2File: '',
        ),
      );

      expect(controller.structureRevision, 1);
    });

    test('removing a scrap with children advances once', () async {
      final TH2FileEditController controller = await loadStandalone(
        _th2Contents,
      );
      final TH2File th2File = controller.th2File;

      controller.execute(
        MPCommandFactory.removeScrapFromExisting(
          existingScrapMPID: id(controller, 's2'),
          th2File: th2File,
        ),
      );

      expect(controller.structureRevision, 2);
    });
  });
}
