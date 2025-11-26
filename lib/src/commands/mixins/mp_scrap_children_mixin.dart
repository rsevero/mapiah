part of '../mp_command.dart';

mixin MPScrapChildrenMixin {
  MPCommand getAddScrapChildrenCommand({
    required THScrap scrap,
    required THFile thFile,
  }) {
    final List<THElement> scrapChildrenAsElements = scrap
        .getChildren(thFile)
        .toList();
    final MPCommand scrapChildrenCommand = MPCommandFactory.addElements(
      elements: scrapChildrenAsElements,
      thFile: thFile,
      positionInParent: mpAddChildAtEndOfParentChildrenList,
    );

    return scrapChildrenCommand;
  }
}
