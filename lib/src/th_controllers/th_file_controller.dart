import 'dart:ui';
import 'package:get/get.dart';

class THFileController extends GetxController {
  // Reactive canvas size
  var canvasSize = Size.zero.obs;

  var canvasScale = 1.0.obs;

  var canvasOffset = Offset.zero.obs;

  var canvasScaleOffsetUndefined = true;

  // Method to update the canvas size
  void updateCanvasSize(Size newSize) {
    canvasSize.value = newSize;
  }

  void updateCanvasScale(double newScale) {
    canvasScale.value = newScale;
  }

  void updateCanvasOffset(Offset newOffset) {
    canvasOffset.value = newOffset;
  }

  void updateCanvasScaleOffsetUndefined(bool newValue) {
    canvasScaleOffsetUndefined = newValue;
  }
}
