// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/controllers/mp_settings_controller.dart';
import 'package:mapiah/src/controllers/mp_window_placement_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/controllers/types/mp_window_placement.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _FakePlatformWindow implements MPPlatformWindow {
  final List<String> calls = <String>[];
  bool maximized = false;
  bool fullScreen = false;
  Rect bounds = const Rect.fromLTWH(10, 20, 800, 600);
  List<Rect> displayBounds = <Rect>[
    const Rect.fromLTWH(0, 0, 1920, 1080),
  ];
  Future<void> Function()? closeHandler;

  @override
  Future<void> destroy() async {
    calls.add('destroy');
  }

  @override
  Future<void> ensureInitialized() async {
    calls.add('ensureInitialized');
  }

  @override
  Future<Rect> getBounds() async {
    calls.add('getBounds');

    return bounds;
  }

  @override
  Future<List<Rect>> getDisplayBounds() async {
    calls.add('getDisplayBounds');

    return displayBounds;
  }

  @override
  Future<bool> isFullScreen() async {
    calls.add('isFullScreen');

    return fullScreen;
  }

  @override
  Future<bool> isMaximized() async {
    calls.add('isMaximized');

    return maximized;
  }

  @override
  Future<void> maximize() async {
    calls.add('maximize');
    maximized = true;
  }

  @override
  void setCloseHandler(Future<void> Function() closeHandler) {
    calls.add('setCloseHandler');
    this.closeHandler = closeHandler;
  }

  @override
  Future<void> setBounds(Rect bounds) async {
    calls.add('setBounds');
    this.bounds = bounds;
  }

  @override
  Future<void> setPreventClose(bool preventClose) async {
    calls.add('setPreventClose:$preventClose');
  }

  @override
  Future<void> unmaximize() async {
    calls.add('unmaximize');
    maximized = false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('window placement defaults to maximized', () async {
    final MPSettingsController settingsController = MPSettingsController();

    await settingsController.initialized;

    expect(settingsController.windowPlacement.isMaximized, isTrue);
    expect(settingsController.windowPlacement.bounds, isNull);
    expect(
      settingsController.getStringWithDefault(
        MPSettingID.Internal_WindowPlacement,
      ),
      MPWindowPlacement.maximizedSettingValue,
    );
  });

  test('windowed placement round-trips through its setting value', () {
    const Rect bounds = Rect.fromLTWH(-120, 45, 1280, 720);
    final MPWindowPlacement placement = MPWindowPlacement.windowed(
      bounds: bounds,
    );

    final MPWindowPlacement? restored = MPWindowPlacement.tryParse(
      placement.toSettingValue(),
    );

    expect(restored, isNotNull);
    expect(restored!.isMaximized, isFalse);
    expect(restored.bounds, bounds);
  });

  test('malformed window placement is rejected', () {
    expect(MPWindowPlacement.tryParse('not-json'), isNull);
    expect(
      MPWindowPlacement.tryParse(
        '{"left":0,"top":0,"width":0,"height":720}',
      ),
      isNull,
    );
    expect(
      MPWindowPlacement.tryParse(
        '{"left":0,"top":0,"width":"wide","height":720}',
      ),
      isNull,
    );
  });

  test('window lifecycle applies the default maximized placement', () async {
    final MPSettingsController settingsController = MPSettingsController();
    final _FakePlatformWindow platformWindow = _FakePlatformWindow();

    await settingsController.initialized;

    final MPWindowPlacementController controller =
        MPWindowPlacementController(
          settingsController: settingsController,
          platformWindow: platformWindow,
          onError: (String _, Object _, StackTrace _) {},
        );

    await controller.initialize();

    expect(platformWindow.maximized, isTrue);
    expect(platformWindow.closeHandler, isNotNull);
    expect(platformWindow.calls, <String>[
      'ensureInitialized',
      'setCloseHandler',
      'setPreventClose:true',
      'maximize',
    ]);
  });

  test('window lifecycle restores saved normal bounds', () async {
    const Rect savedBounds = Rect.fromLTWH(25, 35, 1024, 768);
    final MPSettingsController settingsController = MPSettingsController();
    final _FakePlatformWindow platformWindow = _FakePlatformWindow()
      ..maximized = true;

    await settingsController.initialized;
    await settingsController.setWindowPlacement(
      MPWindowPlacement.windowed(bounds: savedBounds),
    );

    final MPWindowPlacementController controller =
        MPWindowPlacementController(
          settingsController: settingsController,
          platformWindow: platformWindow,
          onError: (String _, Object _, StackTrace _) {},
        );

    await controller.initialize();

    expect(platformWindow.maximized, isFalse);
    expect(platformWindow.bounds, savedBounds);
    expect(platformWindow.calls, containsAllInOrder(<String>[
      'ensureInitialized',
      'setCloseHandler',
      'setPreventClose:true',
      'getDisplayBounds',
      'unmaximize',
      'setBounds',
    ]));
  });

  test(
    'window lifecycle maximizes placement from a disconnected display',
    () async {
      const Rect savedBounds = Rect.fromLTWH(2200, 100, 1024, 768);
      final MPSettingsController settingsController = MPSettingsController();
      final _FakePlatformWindow platformWindow = _FakePlatformWindow();

      await settingsController.initialized;
      await settingsController.setWindowPlacement(
        MPWindowPlacement.windowed(bounds: savedBounds),
      );

      final MPWindowPlacementController controller =
          MPWindowPlacementController(
            settingsController: settingsController,
            platformWindow: platformWindow,
            onError: (String _, Object _, StackTrace _) {},
          );

      await controller.initialize();

      expect(platformWindow.maximized, isTrue);
      expect(platformWindow.bounds, isNot(savedBounds));
      expect(platformWindow.calls, containsAllInOrder(<String>[
        'ensureInitialized',
        'setCloseHandler',
        'setPreventClose:true',
        'getDisplayBounds',
        'maximize',
      ]));
      expect(platformWindow.calls, isNot(contains('setBounds')));
    },
  );

  test('partly visible placement remains compatible', () {
    const Rect savedBounds = Rect.fromLTWH(-30, 100, 1024, 768);
    final List<Rect> displayBounds = <Rect>[
      const Rect.fromLTWH(0, 0, 1920, 1080),
    ];

    expect(
      MPWindowPlacementController.isPlacementCompatibleWithDisplays(
        savedBounds,
        displayBounds,
      ),
      isTrue,
    );
  });

  test('placement larger than the current desktop is incompatible', () {
    const Rect savedBounds = Rect.fromLTWH(0, 0, 2560, 1440);
    final List<Rect> displayBounds = <Rect>[
      const Rect.fromLTWH(0, 0, 1920, 1080),
    ];

    expect(
      MPWindowPlacementController.isPlacementCompatibleWithDisplays(
        savedBounds,
        displayBounds,
      ),
      isFalse,
    );
  });

  test('closing a normal window persists its bounds', () async {
    const Rect closingBounds = Rect.fromLTWH(-50, 75, 1440, 900);
    final MPSettingsController settingsController = MPSettingsController();
    final _FakePlatformWindow platformWindow = _FakePlatformWindow()
      ..bounds = closingBounds;

    await settingsController.initialized;

    final MPWindowPlacementController controller =
        MPWindowPlacementController(
          settingsController: settingsController,
          platformWindow: platformWindow,
          onError: (String _, Object _, StackTrace _) {},
        );

    await controller.saveAndClose();

    final MPSettingsController reloadedSettingsController =
        MPSettingsController();

    await reloadedSettingsController.initialized;

    expect(settingsController.windowPlacement.isMaximized, isFalse);
    expect(settingsController.windowPlacement.bounds, closingBounds);
    expect(reloadedSettingsController.windowPlacement.isMaximized, isFalse);
    expect(reloadedSettingsController.windowPlacement.bounds, closingBounds);
    expect(platformWindow.calls, <String>[
      'isMaximized',
      'isFullScreen',
      'getBounds',
      'destroy',
    ]);
  });

  test('closing a maximized window persists maximized state', () async {
    final MPSettingsController settingsController = MPSettingsController();
    final _FakePlatformWindow platformWindow = _FakePlatformWindow()
      ..maximized = true;

    await settingsController.initialized;

    final MPWindowPlacementController controller =
        MPWindowPlacementController(
          settingsController: settingsController,
          platformWindow: platformWindow,
          onError: (String _, Object _, StackTrace _) {},
        );

    await controller.saveAndClose();

    expect(settingsController.windowPlacement.isMaximized, isTrue);
    expect(platformWindow.calls, <String>['isMaximized', 'destroy']);
  });
}
