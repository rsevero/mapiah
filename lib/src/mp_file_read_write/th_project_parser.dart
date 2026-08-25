// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:io';
import 'package:charset/charset.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/th_config/th_config_file.dart';
import 'package:mapiah/src/elements/th_config/th_config_input.dart';
import 'package:mapiah/src/elements/th_config/th_config_source.dart';
import 'package:mapiah/src/elements/th_data/th_centreline.dart';
import 'package:mapiah/src/elements/th_data/th_data_element.dart';
import 'package:mapiah/src/elements/th_data/th_data_file.dart';
import 'package:mapiah/src/elements/th_data/th_data_input.dart';
import 'package:mapiah/src/elements/th_data/th_import.dart';
import 'package:mapiah/src/elements/th_data/th_inline_scrap.dart';
import 'package:mapiah/src/elements/th_data/th_map.dart';
import 'package:mapiah/src/elements/th_data/th_survey.dart';
import 'package:mapiah/src/elements/th_project/th2_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_centreline_node.dart';
import 'package:mapiah/src/elements/th_project/th_config_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_data_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_map_node.dart';
import 'package:mapiah/src/elements/th_project/th_missing_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';
import 'package:mapiah/src/elements/th_project/th_scrap_node.dart';
import 'package:mapiah/src/elements/th_project/th_survey_node.dart';
import 'package:mapiah/src/mp_file_read_write/th_config_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:path/path.dart' as p;

/// Result of loading a whole Therion project from a root file.
class THProjectLoadResult {
  final THProjectFileNode rootNode;

  final Map<String, Set<String>> fileDependencies;

  final Map<String, Set<String>> reverseDependencies;

  final List<THProjectParseError> projectErrors;

  THProjectLoadResult({
    required this.rootNode,
    required this.fileDependencies,
    required this.reverseDependencies,
    required this.projectErrors,
  });
}

/// Result of splicing a single edited file's children back into an existing
/// project tree via [THProjectParser.spliceFileNodeChildren].
class THProjectSpliceResult {
  final THProjectFileNode node;

  final Map<String, Set<String>> fileDependencies;

  final Map<String, Set<String>> reverseDependencies;

  final List<THProjectParseError> projectErrors;

  THProjectSpliceResult({
    required this.node,
    required this.fileDependencies,
    required this.reverseDependencies,
    required this.projectErrors,
  });
}

/// Recursive project tree loader and dependency-graph builder.
class THProjectParser {
  final THConfigFileParser _configParser = THConfigFileParser();

  final THFileParser _fileParser = THFileParser();

  final Map<String, THProjectFileNode> _visited = <String, THProjectFileNode>{};

  /// Canonical path -> already-built node to reuse instead of re-reading and
  /// re-parsing from disk. Populated only when splicing an incremental
  /// re-parse; empty for a normal full project load.
  final Map<String, THProjectFileNode> _reuseCache =
      <String, THProjectFileNode>{};

  final Map<String, Set<String>> _forwardDependencies =
      <String, Set<String>>{};

  final Map<String, Set<String>> _reverseDependencies =
      <String, Set<String>>{};

  final List<THProjectParseError> _projectErrors = <THProjectParseError>[];

  String _projectRootCanonical = '';

  String _projectRootDirectory = '';

  final RegExp _encodingDirectiveRegex = RegExp(
    r'^encoding\s+([a-zA-Z0-9-]+)',
    caseSensitive: false,
  );

  final RegExp _configOnlyDirectiveRegex = RegExp(
    r'^\s*(layout|export|select|unselect|source)\b',
    caseSensitive: false,
  );

  final RegExp _parseErrorLineRegex = RegExp(
    r'line\s+(\d+)',
    caseSensitive: false,
  );

  final RegExp _isoEncodingRegex = RegExp(
    r'^iso([^_-].*)$',
    caseSensitive: false,
  );

  THProjectParser._();

  /// Loads a project starting from [rootFilePath].
  ///
  /// The root may be a `thconfig` file with any filename, or a `.th` file
  /// when the project has no configuration file.
  static THProjectLoadResult loadProject(
    String rootFilePath, {
    THProjectShape? expectedShape,
  }) {
    return loadFileNode(rootFilePath, expectedShape: expectedShape);
  }

  /// Loads a file and its whole subtree, as if [filePath] were a project
  /// root. Used both for [loadProject] and for loading a newly added include
  /// during an incremental re-parse splice.
  ///
  /// [projectRootDirectory] controls how descendant
  /// [THProjectFileNode.relativePathToProjectRoot] values are computed; when
  /// omitted, [filePath]'s own directory is used, matching a genuine project
  /// root load.
  static THProjectLoadResult loadFileNode(
    String filePath, {
    THProjectShape? expectedShape,
    String? projectRootDirectory,
  }) {
    final THProjectParser parser = THProjectParser._();
    final String absoluteRootPath = p.absolute(filePath);

    parser._projectRootCanonical = THProjectPathResolver.canonicalize(
      absoluteRootPath,
    );
    parser._projectRootDirectory =
        projectRootDirectory ?? p.dirname(parser._projectRootCanonical);

    final THProjectFileNode rootNode = parser._loadFileNode(
      absoluteRootPath,
      rawPath: filePath,
      expectedShape: expectedShape,
    );

    return THProjectLoadResult(
      rootNode: rootNode,
      fileDependencies: parser._forwardDependencies,
      reverseDependencies: parser._reverseDependencies,
      projectErrors: parser._projectErrors,
    );
  }

  /// Parses [content] into a shallow [THProjectFileNode]: the file's own
  /// directives/parse errors are populated, but its children (includes and
  /// logical nodes) are not built. Used to inspect a freshly edited file's
  /// shape/content before deciding how to splice it into an existing tree.
  /// Reads and decodes [absolutePath], detecting its declared Therion
  /// `encoding` directive the same way a full project load does.
  static ({String content, String encoding}) readFileContent(
    String absolutePath,
  ) {
    final THProjectParser parser = THProjectParser._();

    return parser._readContent(absolutePath);
  }

  static THProjectFileNode parseFileContent({
    required String canonicalPath,
    required String content,
    required THProjectShape shape,
    required String sourceFilePath,
    required int lineNumber,
  }) {
    final THProjectParser parser = THProjectParser._();
    parser._projectRootCanonical = canonicalPath;
    parser._projectRootDirectory = p.dirname(canonicalPath);

    final THProjectFileNode node = shape == THProjectShape.config
        ? parser._createConfigFileNode(
            content: content,
            absolutePath: canonicalPath,
            canonicalPath: canonicalPath,
            lineNumber: lineNumber,
            sourceFilePath: sourceFilePath,
          )
        : parser._createDataFileNode(
            content: content,
            absolutePath: canonicalPath,
            canonicalPath: canonicalPath,
            lineNumber: lineNumber,
            sourceFilePath: sourceFilePath,
          );

    final List<String> parseErrors = shape == THProjectShape.config
        ? (node as THConfigFileNode).configFile.parseErrors
        : (node as THDataFileNode).dataFile.parseErrors;
    parser._attachParseErrors(node, parseErrors, canonicalPath);

    return node;
  }

  /// Rebuilds [targetNode]'s children (includes and logical nodes) from its
  /// already-parsed content, reusing subtrees found in
  /// [reuseByCanonicalPath] instead of reading/parsing them again, and
  /// loading only newly referenced includes from disk.
  ///
  /// Includes no longer referenced by [targetNode]'s content are simply not
  /// visited and therefore do not appear in the returned subtree.
  static THProjectSpliceResult spliceFileNodeChildren({
    required THProjectFileNode targetNode,
    required String canonicalPath,
    required String projectRootDirectory,
    Map<String, THProjectFileNode> reuseByCanonicalPath =
        const <String, THProjectFileNode>{},
  }) {
    final THProjectParser parser = THProjectParser._();

    parser._projectRootCanonical = canonicalPath;
    parser._projectRootDirectory = projectRootDirectory;
    parser._reuseCache.addAll(reuseByCanonicalPath);
    parser._visited[canonicalPath] = targetNode;
    parser._forwardDependencies[canonicalPath] = <String>{};

    if (targetNode is THConfigFileNode) {
      parser._buildConfigChildren(targetNode, canonicalPath);
    } else if (targetNode is THDataFileNode) {
      parser._buildDataChildren(targetNode, canonicalPath);
    }

    return THProjectSpliceResult(
      node: targetNode,
      fileDependencies: parser._forwardDependencies,
      reverseDependencies: parser._reverseDependencies,
      projectErrors: parser._projectErrors,
    );
  }

  THProjectFileNode _loadFileNode(
    String filePath, {
    String? rawPath,
    THProjectShape? expectedShape,
    _THIncludeSite? includeSite,
  }) {
    final String absolutePath = p.absolute(filePath);
    final String canonicalPath = THProjectPathResolver.canonicalize(absolutePath);

    final THProjectFileNode? reusedNode = _reuseCache[canonicalPath];
    if (reusedNode != null) {
      _visited[canonicalPath] = reusedNode;

      return reusedNode;
    }

    final THProjectFileNode? existingNode = _visited[canonicalPath];
    if (existingNode != null) {
      _addProjectError(
        message:
            'Cycle detected: "${p.basename(canonicalPath)}" is already loaded.',
        severity: THProjectParseErrorSeverity.warning,
        filePath: includeSite?.filePath ?? canonicalPath,
        lineNumber: includeSite?.lineNumber ?? 0,
      );

      return existingNode;
    }

    final String displayPath = rawPath ?? filePath;
    final String errorFilePath = includeSite?.filePath ?? canonicalPath;
    final int errorLineNumber = includeSite?.lineNumber ?? 0;

    if (!File(absolutePath).existsSync()) {
      final THMissingFileNode missingNode = _createMissingFileNode(
        absolutePath: absolutePath,
        canonicalPath: canonicalPath,
        requestedPath: displayPath,
        sourceFilePath: errorFilePath,
        lineNumber: errorLineNumber,
      );

      _addErrorToNode(
        missingNode,
        message: 'File not found: $displayPath',
        severity: THProjectParseErrorSeverity.error,
        filePath: errorFilePath,
        lineNumber: errorLineNumber,
      );

      return missingNode;
    }

    final ({String content, String encoding}) readContent =
        _readContent(absolutePath);

    final THProjectShape shape =
        expectedShape ?? _detectRootShape(readContent.content, absolutePath);

    final bool isConfigShape = shape == THProjectShape.config;
    final THProjectFileNode node = isConfigShape
        ? _createConfigFileNode(
            content: readContent.content,
            absolutePath: absolutePath,
            canonicalPath: canonicalPath,
            lineNumber: errorLineNumber,
            sourceFilePath: errorFilePath,
          )
        : _createDataFileNode(
            content: readContent.content,
            absolutePath: absolutePath,
            canonicalPath: canonicalPath,
            lineNumber: errorLineNumber,
            sourceFilePath: errorFilePath,
          );

    _visited[canonicalPath] = node;
    _forwardDependencies[canonicalPath] = <String>{};

    final List<String> parseErrors = isConfigShape
        ? (node as THConfigFileNode).configFile.parseErrors
        : (node as THDataFileNode).dataFile.parseErrors;
    _attachParseErrors(node, parseErrors, canonicalPath);

    if (isConfigShape) {
      _buildConfigChildren(node as THConfigFileNode, canonicalPath);
    } else {
      _buildDataChildren(node as THDataFileNode, canonicalPath);
    }

    return node;
  }

  THProjectShape _detectRootShape(String content, String rootPath) {
    if ((p.basename(rootPath).toLowerCase() == 'thconfig') ||
        (p.extension(rootPath).toLowerCase() ==
            mpTherionConfigFileExtension)) {
      return THProjectShape.config;
    }

    final List<String> lines = content.split(RegExp(r'\r?\n'));

    for (final String line in lines) {
      final String trimmedLine = line.trim();

      if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) {
        continue;
      }

      if (_configOnlyDirectiveRegex.hasMatch(line)) {
        return THProjectShape.config;
      }

      return THProjectShape.data;
    }

    return THProjectShape.data;
  }

  THConfigFileNode _createConfigFileNode({
    required String content,
    required String absolutePath,
    required String canonicalPath,
    required int lineNumber,
    required String sourceFilePath,
  }) {
    final THConfigFile configFile = _configParser.parseString(
      content,
      filename: absolutePath,
    );

    return THConfigFileNode(
      configFile: configFile,
      id: 'file:$canonicalPath',
      label: p.basename(absolutePath),
      sourceFilePath: sourceFilePath,
      lineNumber: lineNumber,
      absolutePath: canonicalPath,
      relativePathToProjectRoot: _relativePathToProjectRoot(absolutePath),
      encoding: configFile.encoding,
      isLoaded: true,
    );
  }

  THDataFileNode _createDataFileNode({
    required String content,
    required String absolutePath,
    required String canonicalPath,
    required int lineNumber,
    required String sourceFilePath,
  }) {
    final THDataFile dataFile = _fileParser.parseString(
      content,
      filename: absolutePath,
    );

    return THDataFileNode(
      dataFile: dataFile,
      id: 'file:$canonicalPath',
      label: p.basename(absolutePath),
      sourceFilePath: sourceFilePath,
      lineNumber: lineNumber,
      absolutePath: canonicalPath,
      relativePathToProjectRoot: _relativePathToProjectRoot(absolutePath),
      encoding: dataFile.encoding,
      isLoaded: true,
    );
  }

  THMissingFileNode _createMissingFileNode({
    required String absolutePath,
    required String canonicalPath,
    required String requestedPath,
    required String sourceFilePath,
    required int lineNumber,
  }) {
    return THMissingFileNode(
      requestedPath: requestedPath,
      id: 'file:$canonicalPath',
      label: p.basename(absolutePath),
      sourceFilePath: sourceFilePath,
      lineNumber: lineNumber,
      absolutePath: canonicalPath,
      relativePathToProjectRoot: _relativePathToProjectRoot(absolutePath),
      encoding: mpDefaultEncoding,
    );
  }

  void _buildConfigChildren(THConfigFileNode node, String canonicalPath) {
    for (final THConfigSource source in node.configFile.elements
        .whereType<THConfigSource>()) {
      if (source.filePath.isEmpty) {
        continue;
      }

      final String resolvedPath = THProjectPathResolver.resolve(
        rawPath: source.filePath,
        includingFileAbsolutePath: canonicalPath,
        defaultExtension: '.th',
      );

      final THProjectFileNode childNode = _loadFileNode(
        resolvedPath,
        rawPath: source.filePath,
        expectedShape: THProjectShape.data,
        includeSite: _THIncludeSite(
          filePath: canonicalPath,
          lineNumber: source.lineNumber,
        ),
      );

      node.addChild(childNode);
      _addDependency(canonicalPath, THProjectPathResolver.canonicalize(resolvedPath));
    }

    for (final THConfigInput input in node.configFile.elements
        .whereType<THConfigInput>()) {
      final String resolvedPath = THProjectPathResolver.resolve(
        rawPath: input.filePath,
        includingFileAbsolutePath: canonicalPath,
      );

      final THProjectFileNode childNode = _loadFileNode(
        resolvedPath,
        rawPath: input.filePath,
        expectedShape: THProjectShape.config,
        includeSite: _THIncludeSite(
          filePath: canonicalPath,
          lineNumber: input.lineNumber,
        ),
      );

      node.addChild(childNode);
      _addDependency(canonicalPath, THProjectPathResolver.canonicalize(resolvedPath));
    }
  }

  void _buildDataChildren(THDataFileNode node, String canonicalPath) {
    final Map<String, THMap> mapsById = _collectMaps(node.dataFile.elements);

    _buildDataElements(
      elements: node.dataFile.elements,
      parent: node,
      canonicalPath: canonicalPath,
      surveyIds: <String>[],
      mapsById: mapsById,
    );
  }

  void _buildDataElements({
    required List<THDataElement> elements,
    required THProjectNode parent,
    required String canonicalPath,
    required List<String> surveyIds,
    required Map<String, THMap> mapsById,
  }) {
    for (final THDataElement element in elements) {
      if (element is THSurvey) {
        final List<String> currentSurveyIds = <String>[
          ...surveyIds,
          element.surveyId,
        ];

        final THSurveyNode surveyNode = THSurveyNode(
          survey: element,
          fullNamespace: currentSurveyIds.reversed.join('.'),
          id: 'survey:$canonicalPath:${element.lineNumber}',
          label: element.surveyId,
          sourceFilePath: canonicalPath,
          lineNumber: element.lineNumber,
        );

        parent.addChild(surveyNode);
        _buildDataElements(
          elements: element.children,
          parent: surveyNode,
          canonicalPath: canonicalPath,
          surveyIds: currentSurveyIds,
          mapsById: mapsById,
        );
      } else if (element is THCentreline) {
        final THCentrelineNode centrelineNode = THCentrelineNode(
          centreline: element,
          id: 'centreline:$canonicalPath:${element.lineNumber}',
          label: 'centreline',
          sourceFilePath: canonicalPath,
          lineNumber: element.lineNumber,
        );

        parent.addChild(centrelineNode);
      } else if (element is THMap) {
        final THMapNode mapNode = THMapNode(
          map: element,
          id: 'map:$canonicalPath:${element.lineNumber}',
          label: element.mapId,
          sourceFilePath: canonicalPath,
          lineNumber: element.lineNumber,
        );

        parent.addChild(mapNode);
        _addNestedMapChildren(
          map: element,
          mapNode: mapNode,
          canonicalPath: canonicalPath,
          mapsById: mapsById,
        );
      } else if (element is THInlineScrap) {
        final THScrapNode scrapNode = THScrapNode(
          scrapId: element.scrapId,
          isFromTH2File: false,
          id: 'scrap:$canonicalPath:${element.lineNumber}',
          label: element.scrapId,
          sourceFilePath: canonicalPath,
          lineNumber: element.lineNumber,
        );

        parent.addChild(scrapNode);
      } else if (element is THDataInput) {
        _addDataInput(
          input: element,
          parent: parent,
          canonicalPath: canonicalPath,
        );
      } else if (element is THImport) {
        _diagnoseImport(element, parent, canonicalPath);
      }
    }
  }

  Map<String, THMap> _collectMaps(List<THDataElement> elements) {
    final Map<String, THMap> mapsById = <String, THMap>{};

    void visit(List<THDataElement> list) {
      for (final THDataElement element in list) {
        if (element is THMap) {
          mapsById.putIfAbsent(element.mapId, () => element);
        } else if (element is THSurvey) {
          visit(element.children);
        }
      }
    }

    visit(elements);

    return mapsById;
  }

  void _addNestedMapChildren({
    required THMap map,
    required THMapNode mapNode,
    required String canonicalPath,
    required Map<String, THMap> mapsById,
  }) {
    final Set<String> addedMapIds = <String>{};

    for (final String item in map.items) {
      final THMap? referencedMap = mapsById[item];

      if ((referencedMap == null) ||
          addedMapIds.contains(item) ||
          (item == map.mapId)) {
        continue;
      }

      final THMapNode childMapNode = THMapNode(
        map: referencedMap,
        id: 'map:$canonicalPath:${referencedMap.lineNumber}',
        label: referencedMap.mapId,
        sourceFilePath: canonicalPath,
        lineNumber: referencedMap.lineNumber,
      );

      mapNode.addChild(childMapNode);
      addedMapIds.add(item);
    }
  }

  void _addDataInput({
    required THDataInput input,
    required THProjectNode parent,
    required String canonicalPath,
  }) {
    final String resolvedPath = THProjectPathResolver.resolve(
      rawPath: input.rawPath,
      includingFileAbsolutePath: canonicalPath,
      defaultExtension: '.th',
    );

    final _THIncludeSite includeSite = _THIncludeSite(
      filePath: canonicalPath,
      lineNumber: input.lineNumber,
    );

    final THProjectFileNode childNode;
    if (_isTH2Path(resolvedPath)) {
      final String th2CanonicalPath = THProjectPathResolver.canonicalize(
        resolvedPath,
      );
      final THProjectFileNode? reusedTH2Node = _reuseCache[th2CanonicalPath];

      childNode = reusedTH2Node ??
          _createTH2FileNode(
            resolvedPath: resolvedPath,
            includeSite: includeSite,
          );
    } else {
      childNode = _loadFileNode(
        resolvedPath,
        rawPath: input.rawPath,
        expectedShape: THProjectShape.data,
        includeSite: includeSite,
      );
    }

    parent.addChild(childNode);
    _addDependency(canonicalPath, THProjectPathResolver.canonicalize(resolvedPath));
  }

  bool _isTH2Path(String path) {
    return p.extension(path).toLowerCase() == '.th2';
  }

  TH2FileNode _createTH2FileNode({
    required String resolvedPath,
    required _THIncludeSite includeSite,
  }) {
    final String canonicalPath = THProjectPathResolver.canonicalize(resolvedPath);

    return TH2FileNode(
      id: 'file:$canonicalPath',
      label: p.basename(resolvedPath),
      sourceFilePath: includeSite.filePath,
      lineNumber: includeSite.lineNumber,
      absolutePath: canonicalPath,
      relativePathToProjectRoot: _relativePathToProjectRoot(resolvedPath),
      encoding: mpDefaultEncoding,
      isLoaded: File(resolvedPath).existsSync(),
    );
  }

  void _diagnoseImport(
    THImport imp,
    THProjectNode parent,
    String canonicalPath,
  ) {
    final String resolvedPath = THProjectPathResolver.resolve(
      rawPath: imp.filePath,
      includingFileAbsolutePath: canonicalPath,
    );

    if (!File(resolvedPath).existsSync()) {
      _addErrorToNode(
        parent,
        message: 'Import file not found: ${imp.filePath}',
        severity: THProjectParseErrorSeverity.error,
        filePath: canonicalPath,
        lineNumber: imp.lineNumber,
      );
    }
  }

  void _addDependency(String includingFilePath, String includedFilePath) {
    _forwardDependencies
        .putIfAbsent(includingFilePath, () => <String>{})
        .add(includedFilePath);
    _reverseDependencies
        .putIfAbsent(includedFilePath, () => <String>{})
        .add(includingFilePath);
  }

  String _relativePathToProjectRoot(String absolutePath) {
    final String canonicalPath = THProjectPathResolver.canonicalize(absolutePath);

    if (canonicalPath == _projectRootCanonical) {
      return p.basename(absolutePath);
    }

    return p.relative(absolutePath, from: _projectRootDirectory);
  }

  ({String content, String encoding}) _readContent(String absolutePath) {
    final List<int> bytes = File(absolutePath).readAsBytesSync();
    final String encoding = _encodingNameFromBytes(bytes);

    return (content: _decodeBytes(bytes, encoding), encoding: encoding);
  }

  String _encodingNameFromBytes(List<int> bytes) {
    final String latin1Text = latin1.decode(bytes);
    final List<String> lines = latin1Text.split(RegExp(r'\r?\n'));

    for (final String line in lines) {
      final String trimmedLine = line.trim();

      if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) {
        continue;
      }

      final RegExpMatch? match = _encodingDirectiveRegex.firstMatch(trimmedLine);
      if (match != null) {
        return match.group(1)!.toUpperCase();
      }

      break;
    }

    return mpDefaultEncoding;
  }

  String _decodeBytes(List<int> bytes, String encoding) {
    final String normalizedEncoding = encoding.toUpperCase();

    switch (normalizedEncoding) {
      case 'UTF-8':
        return utf8.decode(bytes);
      case 'ASCII':
        return ascii.decode(bytes);
      case 'ISO-8859-1':
      case 'ISO8859-1':
        return latin1.decode(bytes);
      default:
        final RegExpMatch? isoMatch = _isoEncodingRegex.firstMatch(
          normalizedEncoding,
        );
        final String charsetName = isoMatch == null
            ? normalizedEncoding
            : 'ISO-${isoMatch.group(1)}';

        final Encoding? encoder = Charset.getByName(charsetName);

        return encoder == null
            ? utf8.decode(bytes)
            : encoder.decode(bytes);
    }
  }

  void _attachParseErrors(
    THProjectFileNode node,
    List<String> parseErrors,
    String canonicalPath,
  ) {
    for (final String message in parseErrors) {
      final int lineNumber = _lineNumberFromParseError(message);

      _addErrorToNode(
        node,
        message: message,
        severity: THProjectParseErrorSeverity.error,
        filePath: canonicalPath,
        lineNumber: lineNumber,
      );
    }
  }

  int _lineNumberFromParseError(String message) {
    final RegExpMatch? match = _parseErrorLineRegex.firstMatch(message);

    return match == null ? 0 : int.parse(match.group(1)!);
  }

  void _addErrorToNode(
    THProjectNode node, {
    required String message,
    required THProjectParseErrorSeverity severity,
    required String filePath,
    required int lineNumber,
  }) {
    final THProjectParseError error = THProjectParseError(
      message: message,
      severity: severity,
      filePath: filePath,
      lineNumber: lineNumber,
    );

    node.parseErrors.add(error);
    _projectErrors.add(error);
  }

  void _addProjectError({
    required String message,
    required THProjectParseErrorSeverity severity,
    required String filePath,
    required int lineNumber,
  }) {
    final THProjectParseError error = THProjectParseError(
      message: message,
      severity: severity,
      filePath: filePath,
      lineNumber: lineNumber,
    );

    _projectErrors.add(error);
  }
}

enum THProjectShape { config, data }

class _THIncludeSite {
  final String filePath;

  final int lineNumber;

  const _THIncludeSite({
    required this.filePath,
    required this.lineNumber,
  });
}
