// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';
import 'dart:typed_data';

import 'package:mapiah/src/elements/th_project/th_config_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_data_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';
import 'package:mapiah/src/mp_file_read_write/th_config_file_writer.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_writer.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_parser.dart';

/// Asynchronous full-project / file-node load. Mirrors
/// [THProjectParser.loadFileNode], adding the content/revision override map so
/// a dirty-preserving in-memory full re-parse can build nodes from pending
/// contents instead of disk.
typedef THProjectLoadOperation =
    Future<THProjectLoadResult> Function(
      String rootFilePath, {
      THProjectShape? expectedShape,
      String? projectRootDirectory,
      Map<String, THProjectContentOverride> contentOverrides,
    });

/// Asynchronous shallow parse of a single edited file's own directives, with
/// no children built. Mirrors [THProjectParser.parseFileContent].
typedef THProjectParseFileContentOperation =
    Future<THProjectFileNode> Function({
      required String canonicalPath,
      required String content,
      required THProjectShape shape,
      required String sourceFilePath,
      required int lineNumber,
    });

/// Asynchronous rebuild of one node's children, reusing unchanged subtrees.
/// Mirrors [THProjectParser.spliceFileNodeChildren].
typedef THProjectSpliceOperation =
    Future<THProjectSpliceResult> Function({
      required THProjectFileNode targetNode,
      required String canonicalPath,
      required String projectRootDirectory,
      Map<String, THProjectFileNode> reuseByCanonicalPath,
    });

/// Synchronous encoding-aware read of a file's decoded content. Mirrors
/// [THProjectParser.readFileContent].
typedef THProjectReadFileContentOperation =
    ({String content, String encoding}) Function(String absolutePath);

/// Synchronous serialization of a writable config/data node to bytes.
typedef THProjectSerializeNodeOperation =
    Uint8List Function(THProjectFileNode node);

/// Asynchronous byte write for one canonical path.
typedef THProjectWriteBytesOperation =
    Future<void> Function(String canonicalPath, Uint8List bytes);

/// Immutable bundle of the parser/serializer/reader/writer boundaries a
/// [THProjectController] touches during lifecycle, re-parse, revert, and save.
///
/// Production construction uses [THProjectControllerOperations.defaults], which
/// preserves the current static-parser / concrete-writer / `File` behavior.
/// Controller unit tests inject a bundle through the constructor to hold each
/// operation at its real `await` boundary and to force read/serialize/write
/// failures independently — without touching `mpLocator`, static parser state,
/// or process-wide callbacks.
class THProjectControllerOperations {
  final THProjectLoadOperation loadProject;

  final THProjectParseFileContentOperation parseFileContent;

  final THProjectSpliceOperation spliceFileNodeChildren;

  final THProjectReadFileContentOperation readFileContent;

  final THProjectSerializeNodeOperation serializeNode;

  final THProjectWriteBytesOperation writeBytes;

  const THProjectControllerOperations({
    required this.loadProject,
    required this.parseFileContent,
    required this.spliceFileNodeChildren,
    required this.readFileContent,
    required this.serializeNode,
    required this.writeBytes,
  });

  factory THProjectControllerOperations.defaults() {
    return THProjectControllerOperations(
      loadProject:
          (
            String rootFilePath, {
            THProjectShape? expectedShape,
            String? projectRootDirectory,
            Map<String, THProjectContentOverride> contentOverrides =
                const <String, THProjectContentOverride>{},
          }) => Future<THProjectLoadResult>(
            () => THProjectParser.loadFileNode(
              rootFilePath,
              expectedShape: expectedShape,
              projectRootDirectory: projectRootDirectory,
              contentOverrides: contentOverrides,
            ),
          ),
      parseFileContent:
          ({
            required String canonicalPath,
            required String content,
            required THProjectShape shape,
            required String sourceFilePath,
            required int lineNumber,
          }) => Future<THProjectFileNode>(
            () => THProjectParser.parseFileContent(
              canonicalPath: canonicalPath,
              content: content,
              shape: shape,
              sourceFilePath: sourceFilePath,
              lineNumber: lineNumber,
            ),
          ),
      spliceFileNodeChildren:
          ({
            required THProjectFileNode targetNode,
            required String canonicalPath,
            required String projectRootDirectory,
            Map<String, THProjectFileNode> reuseByCanonicalPath =
                const <String, THProjectFileNode>{},
          }) => Future<THProjectSpliceResult>(
            () => THProjectParser.spliceFileNodeChildren(
              targetNode: targetNode,
              canonicalPath: canonicalPath,
              projectRootDirectory: projectRootDirectory,
              reuseByCanonicalPath: reuseByCanonicalPath,
            ),
          ),
      readFileContent: THProjectParser.readFileContent,
      serializeNode: _defaultSerializeNode,
      writeBytes: (String canonicalPath, Uint8List bytes) =>
          File(canonicalPath).writeAsBytes(bytes),
    );
  }

  static Uint8List _defaultSerializeNode(THProjectFileNode node) {
    if (node is THConfigFileNode) {
      return THConfigFileWriter().serializeToBytes(node.configFile);
    }

    if (node is THDataFileNode) {
      return THFileWriter().serializeToBytes(node.dataFile);
    }

    throw ArgumentError(
      'THProjectControllerOperations.serializeNode: '
      '${node.runtimeType} is not a writable config/data node.',
    );
  }
}
