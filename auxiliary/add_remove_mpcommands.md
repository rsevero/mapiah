# Add/remove commands in Mapiah

1. The _elementPositionInParent_ parameter determines the position at which the new element will be inserted in the parent's children list:
    * **\>= 0**: indicates the specific position in the list (used on the undo add commands of remove commands);
    * **= -1**: indicates the element should be added to the last minus 1 position at the end of the list so it gets just before the _THEnd[line|area|scrap]_ element (used when the user creates a new child element);
    * **= -2**: indicates the element should be added to the end of the list (used at the __actualExecute_ method of add commands);
1. Elements _with THIsParentMixin_:
    * have a dedicated _applyAddPARENT_ method which inserts the PARENT element with an empty children list;
    * have a _childrenList_ property so its children list is properly populated;
    * the last element of the _childrenList_ should be the appropriate _THEnd[area|line|point|scrap]_ element.
1. The _add_ commands __actualExecute_ methods should call the appropriate _applyAdd[PARENT/Element]_ method passing the respective children list and the registered _elementPositionInParent_ parameter value.
1. The _applyAddPARENT_ methods should:
    1. insert the main element with an empty children list using the informed _elementPositionInParent_ parameter value;
    1. call the appropriate _applyAdd[PARENT/Element]_ method for each child element being created with _elementPositionInParent_ = -2 so each child is added at the very end of the parents children list;
    1. call the appropriate _updateAfterAdd[PARENT/ELEMENT]_ method to update the UI.
    1. call the appropriate triggers.
1. For non parent elements, the __actualExecute_ method should:
    1. call _applyAddElement_ with the registered _elementPositionInParent_ parameter value;
    1. call the appropriate _updateAfterAddELEMENT_ method to update the UI.
    1. call the appropriate triggers.
1. The _remove_ commands __createUndo_ methods should:
    1. call create the respective add method with the _elementPositionInParent_ parameter set to the child position of the removed element.
