// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:mapiah/src/controllers/th_project_controller_operations.dart';
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_parser.dart';

/// A started/release gate for holding one asynchronous operation at its real
/// `await` boundary without duration-based sleeps.
///
/// A test awaits [started] to know the operation is in flight, performs a
/// lifecycle transition or concurrent edit, calls [release], then awaits the
/// controller result.
class MPAsyncGate {
  final Completer<void> _started = Completer<void>();
  final Completer<void> _release = Completer<void>();

  /// Completes the first time the gated operation begins.
  Future<void> get started => _started.future;

  /// Whether the gated operation has begun at least once.
  bool get hasStarted => _started.isCompleted;

  void markStarted() {
    if (!_started.isCompleted) {
      _started.complete();
    }
  }

  Future<void> get releaseFuture => _release.future;

  /// Lets the gated operation proceed past its `await`.
  void release() {
    if (!_release.isCompleted) {
      _release.complete();
    }
  }
}

/// Constructor-injected fake [THProjectControllerOperations] that delegates to
/// the real defaults but can hold each asynchronous operation on a gate and
/// force each read/serialize/write to throw independently.
class FakeProjectOperations {
  final THProjectControllerOperations _real =
      THProjectControllerOperations.defaults();

  MPAsyncGate? loadGate;
  MPAsyncGate? parseGate;
  MPAsyncGate? spliceGate;
  MPAsyncGate? writeGate;

  Object? loadError;
  Object? readError;
  Object? serializeError;
  Object? writeError;

  /// Canonical paths whose `writeBytes` should throw a [FileSystemException],
  /// leaving every other path writable. Lets a Save All test fail exactly one
  /// descriptor without touching filesystem permissions.
  final Set<String> writeErrorPaths = <String>{};

  int loadCount = 0;
  int parseCount = 0;
  int spliceCount = 0;
  bool writeInvoked = false;
  final List<String> writtenPaths = <String>[];
  final List<Map<String, THProjectContentOverride>> loadOverrides =
      <Map<String, THProjectContentOverride>>[];

  THProjectControllerOperations build() {
    return THProjectControllerOperations(
      loadProject:
          (
            String rootFilePath, {
            THProjectShape? expectedShape,
            String? projectRootDirectory,
            Map<String, THProjectContentOverride> contentOverrides =
                const <String, THProjectContentOverride>{},
          }) async {
            loadCount++;
            loadOverrides.add(contentOverrides);

            final MPAsyncGate? gate = loadGate;
            if (gate != null) {
              gate.markStarted();
              await gate.releaseFuture;
            }

            if (loadError != null) {
              throw loadError!;
            }

            return _real.loadProject(
              rootFilePath,
              expectedShape: expectedShape,
              projectRootDirectory: projectRootDirectory,
              contentOverrides: contentOverrides,
            );
          },
      parseFileContent:
          ({
            required String canonicalPath,
            required String content,
            required THProjectShape shape,
            required String sourceFilePath,
            required int lineNumber,
          }) async {
            parseCount++;

            final MPAsyncGate? gate = parseGate;
            if (gate != null) {
              gate.markStarted();
              await gate.releaseFuture;
            }

            return _real.parseFileContent(
              canonicalPath: canonicalPath,
              content: content,
              shape: shape,
              sourceFilePath: sourceFilePath,
              lineNumber: lineNumber,
            );
          },
      spliceFileNodeChildren:
          ({
            required THProjectFileNode targetNode,
            required String canonicalPath,
            required String projectRootDirectory,
            Map<String, THProjectFileNode> reuseByCanonicalPath =
                const <String, THProjectFileNode>{},
          }) async {
            spliceCount++;

            final MPAsyncGate? gate = spliceGate;
            if (gate != null) {
              gate.markStarted();
              await gate.releaseFuture;
            }

            return _real.spliceFileNodeChildren(
              targetNode: targetNode,
              canonicalPath: canonicalPath,
              projectRootDirectory: projectRootDirectory,
              reuseByCanonicalPath: reuseByCanonicalPath,
            );
          },
      readFileContent: (String absolutePath) {
        if (readError != null) {
          throw readError!;
        }

        return _real.readFileContent(absolutePath);
      },
      serializeNode: (THProjectFileNode node) {
        if (serializeError != null) {
          throw serializeError!;
        }

        return _real.serializeNode(node);
      },
      writeBytes: (String canonicalPath, Uint8List bytes) async {
        writeInvoked = true;

        final MPAsyncGate? gate = writeGate;
        if (gate != null) {
          gate.markStarted();
          await gate.releaseFuture;
        }

        if (writeError != null) {
          throw writeError!;
        }
        if (writeErrorPaths.contains(canonicalPath)) {
          throw FileSystemException('write denied by fake', canonicalPath);
        }

        writtenPaths.add(canonicalPath);

        return _real.writeBytes(canonicalPath, bytes);
      },
    );
  }
}
