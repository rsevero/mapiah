import 'package:mapiah/src/th_definitions.dart';

/// Base class for all elements that form a THFile, including THFile itself.
abstract class THElement {
  late final int _id;
  late final THFile _thFile;
  late THParent parent;

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
    parent.addElement(this);
  }

  get id {
    return _id;
  }

  get thFile {
    return _thFile;
  }
}

/// Parent elements.
///
/// Mixin that provides parenting capabilities.
mixin THParent on THElement {
  final List<THElement> _children = [];

  int addElement(THElement aElement) {
    _children.add(aElement);
    return aElement.id;
  }
}

/// THFile represents the complete contents of a .th or .th2 file.
///
/// It should be defined in the same file as THElement so it can access
/// THElement parameterless private constructor.
class THFile extends THElement with THParent {
  final Map<int, THElement> _elements = {};
  var _nextID = 0;

  var encoding = thDefaultEncoding;
  var readFromFilename = '';

  THFile() : super._() {
    _id = -1;
    parent = this;
    _thFile = this;
  }

  Map<int, THElement> get elements {
    return _elements;
  }

  @override
  int addElement(THElement aElement) {
    aElement._id = _nextID;
    _elements[_nextID] = aElement;
    _nextID++;

    return super.addElement(aElement);
  }

  bool hasElementByID(int aID) {
    return _elements.containsKey(aID);
  }

  THElement? elementByID(int aID) {
    if (_elements.containsKey(aID)) {
      return _elements[aID];
    } else {
      return null;
    }
  }
}
