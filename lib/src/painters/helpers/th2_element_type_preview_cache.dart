// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:collection';
import 'dart:ui' as ui;

import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mobx/mobx.dart';

/// App-wide, bounded least-recently-used cache of recorded element-type
/// previews.
///
/// It exclusively owns its pictures: [draw] looks a key up or records it,
/// draws the picture and returns without handing it out, so no picture
/// reference survives outside the cache. Each picture is disposed exactly
/// once, when evicted or cleared. A visualization-method change clears
/// every entry, since no current key can use them again.
class TH2ElementTypePreviewCache<K extends Object> {
  final int limit;

  final LinkedHashMap<K, ui.Picture> _pictures = LinkedHashMap<K, ui.Picture>();

  late final ReactionDisposer _visualizationMethodReaction;

  bool _isDisposed = false;

  TH2ElementTypePreviewCache({this.limit = mpTH2ElementTypeIconCacheLimit})
    : assert(limit > 0) {
    _visualizationMethodReaction = reaction<int>(
      (_) => mpLocator.mpSettingsController.getTrigger(
        MPSettingID.TH2Edit_VisualizationMethod,
      ),
      (_) => clear(),
    );
  }

  int get length => _pictures.length;

  bool get isDisposed => _isDisposed;

  bool contains(K key) => _pictures.containsKey(key);

  /// Draws the picture of [key] on [canvas], recording it with [record]
  /// when the cache does not hold it, and marks it as most recently used.
  /// Evicts least recently used pictures beyond [limit], never the one
  /// being drawn.
  void draw({
    required ui.Canvas canvas,
    required K key,
    required ui.Picture Function() record,
  }) {
    _checkNotDisposed();

    final ui.Picture picture = _pictures.remove(key) ?? record();

    _pictures[key] = picture;
    _evictBeyondLimit();
    canvas.drawPicture(picture);

    assert(_pictures.length <= limit);
  }

  /// Disposes and forgets every picture.
  void clear() {
    _checkNotDisposed();

    final List<ui.Picture> pictures = _pictures.values.toList();

    _pictures.clear();

    for (final ui.Picture picture in pictures) {
      picture.dispose();
    }
  }

  /// Stops reacting to setting changes and disposes every picture. Later
  /// use throws a [StateError]. Unmount the icons using the cache first.
  void dispose() {
    _checkNotDisposed();
    _visualizationMethodReaction();
    clear();
    _isDisposed = true;
  }

  void _evictBeyondLimit() {
    final int excess = _pictures.length - limit;

    for (int i = 0; i < excess; i++) {
      final K oldestKey = _pictures.keys.first;

      _pictures.remove(oldestKey)!.dispose();
    }
  }

  void _checkNotDisposed() {
    if (_isDisposed) {
      throw StateError('TH2ElementTypePreviewCache used after dispose.');
    }
  }
}
