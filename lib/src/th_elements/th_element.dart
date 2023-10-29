import 'package:mapiah/src/th_definitions.dart';
import 'package:mapiah/src/th_exceptions/th_element_by_index_missing.dart';

/// Base class for all elements that form a THFile, including THFile itself.
abstract class THElement {
  late final int _index;
  late final THFile _thFile;
  late THParent parent;
  String? sameLineComment;

  /// Generic private constructor.
  ///
  /// Only used for special descendants that set by themselves their essential
  /// properties.
  ///
  /// Special descendants: THFile.
  THElement._();

  /// Main constructor.
  ///
  /// Main constructor that sets all essential properties. Any change made here
  /// should eventually be reproduced in the special descendants that don´t use
  /// this constructor but the [Generic private constructor].
  THElement.withParent(this.parent) {
    _thFile = parent.thFile;
    parent._addElement(this);
  }

  int get index {
    return _index;
  }

  THFile get thFile {
    return _thFile;
  }

  String type() {
    return runtimeType.toString().substring(2).toLowerCase();
  }

  void removeSameLineComment() {
    sameLineComment = null;
  }
}

/// Parent elements.
///
/// Mixin that provides parenting capabilities.
mixin THParent on THElement {
  final List<THElement> _children = [];

  int _addElement(THElement aElement) {
    _thFile._includeElementInFile(aElement);
    _children.add(aElement);

    return aElement.index;
  }

  List<THElement> get children {
    return _children;
  }
}

/// THFile represents the complete contents of a .th or .th2 file.
///
/// It should be defined in the same file as THElement so it can access
/// THElement parameterless private constructor.
class THFile extends THElement with THParent {
  final Map<int, THElement> _elements = {};
  var filename = 'unnamed file';

  var encoding = thDefaultEncoding;
  var _nextIndex = 0;

  THFile() : super._() {
    _index = -1;
    parent = this;
    _thFile = this;
  }

  Map<int, THElement> get elements {
    return _elements;
  }

  int countElements() {
    return _elements.length;
  }

  void _includeElementInFile(THElement aElement) {
    aElement._index = _nextIndex;
    _elements[_nextIndex] = aElement;
    _nextIndex++;
  }

  bool hasElementByIndex(int aIndex) {
    return _elements.containsKey(aIndex);
  }

  THElement elementByIndex(int aIndex) {
    if (!hasElementByIndex(aIndex)) {
      throw THElementByIndexMissingException(_thFile.filename, aIndex);
    }

    return _elements[aIndex]!;
  }
}
