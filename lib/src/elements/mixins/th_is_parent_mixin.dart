// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/mixins/mp_thfile_reference_mixin.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

/// Parent elements.
///
/// Mixin that provides parenting capabilities.
mixin THIsParentMixin on MPTH2FileReferenceMixin {
  // Here are registered all children mapiah IDs.
  final List<int> childrenMPIDs = [];

  List<int>? _drawableChildrenMPIDs;

  static const Set<THElementType> drawableChildElementTypes = {
    THElementType.line,
    THElementType.point,
    THElementType.scrap,
  };

  /// The elementPositionInParent parameter determines the position at which the
  /// new element will be inserted in the parent's children list:
  /// >= 0 => indicates the specific position in the list;
  /// mpAddChildAtEndMinusOneOfParentChildrenList => indicates the element
  ///         should be added to the last minus 1 position at the end of the
  ///         list so it gets just before the THEnd[line|area|scrap] element;
  /// mpAddChildAtEndOfParentChildrenList => indicates the element should be
  ///         added to the end of the list;
  void addElementToParent(
    THElement element, {
    int elementPositionInParent = mpAddChildAtEndMinusOneOfParentChildrenList,
  }) {
    final int elementMPID = element.mpID;

    if (childrenMPIDs.contains(elementMPID)) {
      return;
    }

    if (elementPositionInParent == mpAddChildAtEndOfParentChildrenList) {
      childrenMPIDs.add(elementMPID);
    } else if (elementPositionInParent ==
        mpAddChildAtEndMinusOneOfParentChildrenList) {
      if (element.parentMPID > 0) {
        if (childrenMPIDs.isEmpty) {
          throw THCustomException(
            "At THIsParentMixin.addElementToParent cannot add at end minus one position when there are no children.",
          );
        }

        final int endElementIndex = childrenMPIDs.length - 1;

        childrenMPIDs.insert(endElementIndex, elementMPID);
      } else {
        childrenMPIDs.add(elementMPID);
      }
    } else if (elementPositionInParent >= 0) {
      if (elementPositionInParent > childrenMPIDs.length) {
        throw THCustomException(
          "At THIsParentMixin.addElementToParent too big 'childPositionInParent' value : '$elementPositionInParent'.",
        );
      }

      childrenMPIDs.insert(elementPositionInParent, elementMPID);
    } else {
      throw THCustomException(
        "At THIsParentMixin.addElementToParent unsupported 'childPositionInParent' value : '$elementPositionInParent'.",
      );
    }

    if (th2File != null) {
      element.setTH2File(th2File!);
    }

    if (drawableChildElementTypes.contains(element.elementType)) {
      _drawableChildrenMPIDs = null;
    }
  }

  void setTH2FileToChildren(TH2File th2File) {
    for (final THElement child in getChildren(th2File)) {
      child.setTH2File(th2File);
    }
  }

  int getChildPosition(THElement element) {
    final int index = childrenMPIDs.indexOf(element.mpID);

    if (index < 0) {
      throw THCustomException(
        "At THIsParentMixin.getChildPosition: '$element' not found.",
      );
    }

    return index;
  }

  void removeElementFromParent(THElement element) {
    if (!childrenMPIDs.remove(element.mpID)) {
      throw THCustomException("'$element' not found.");
    }

    if (th2File == null) {
      throw THCustomException(
        "At THIsParentMixin.removeElementFromParent: TH2File is null.",
      );
    }

    if (th2File!.hasTHIDByElement(element)) {
      th2File!.unregisterElementTHIDByElement(element);
    }

    if (drawableChildElementTypes.contains(element.elementType)) {
      _drawableChildrenMPIDs = null;
    }
  }

  Iterable<THElement> getChildren(TH2File th2File) {
    return childrenMPIDs.map((mpID) => th2File.elementByMPID(mpID));
  }

  int get mpID;

  List<int> getDrawableChildrenMPIDs() {
    _drawableChildrenMPIDs ??= _getDrawableChildrenMPIDs();

    return _drawableChildrenMPIDs!;
  }

  List<int> _getDrawableChildrenMPIDs() {
    final List<int> drawableChildrenMPIDs = [];

    for (final int childMPID in childrenMPIDs) {
      final THElementType childElementType = th2File!.getElementTypeByMPID(
        childMPID,
      );

      if (drawableChildElementTypes.contains(childElementType)) {
        drawableChildrenMPIDs.add(childMPID);
      }
    }

    return drawableChildrenMPIDs;
  }
}
