# From user interaction to new updated state: how does Mapiah works?

Here is a brief explanation of the infrastructure involved in the actual execution of a action requested by the user in Mapiah.

## Altering data actions

These are the actions that alter THFile data, i.e., that should be registered in the undo/redo chains.

1. The widget responsible for receiving the user interaction (button/mouse/key click, mouse move, etc) gathers the necessary info on the widget and calls a TH2FileEditUserInteraction method.
2. The called TH2FileEditUserInteraction method receives the appropriate info from the widget, gathers any other necessary info and creates the single MPCommand necessary to execute the requested action and executes it.
3. The created MPCommand registers the necessary undo/redo info and calls its internal execute method called _actualExecute().
4. _actualExecute() calls one @action from TH2FileEditElementEditController responsible for all actual changes in THFile, support data and necessary redraw triggers.

## Non-altering data actions

These are the actions that does not alter THFile data, i.e, opening and closing overlay windows, button arrays, etc.

1. The widget responsible for receiving the user interaction (button/mouse/key click, mouse move, etc) gathers the necessary info on the widget and calls a single method in the appropriatte controller. This method should be an @action.
2. The called controller method executes all changes in support data and activates all appropriate redraw triggers.
