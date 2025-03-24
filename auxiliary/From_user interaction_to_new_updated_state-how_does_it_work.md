# From user interaction to new updated state: how does Mapiah works?

Here is a brief explanation of the infrastructure involved in the actual execution of a action requested by the user in Mapiah.

## Altering data actions from general widgets events

These are the actions that alter THFile data originated in events of general widgets (i.e. not MPListenerWidget). These actions should be registered in the undo/redo chains.

1. The widget responsible for generating the event calls one local method that gathers the necessary info on the widget and calls a *Prep* method in the appropriate controller.
2. The called controller method, - i.e. the *Prep* method - receives the appropriate info from the widget, gathers any other necessary info and creates the single MPCommand necessary to execute the requested action. It also calls the execute() method of MPCommand.
3. The created MPCommand registers the necessary undo/redo info and calls its internal execute method called _actualExecute().
4. _actualExecute() calls one method from the appropriate controller (i.e. the *Exec* method that should be an @action) responsible for all actual changes in THFile, support data and necessary redraw triggers.

## Altering data actions generated in the MPListenerWidget

These are the actions that alter THFile data originated in events from MPListenerWidget. They are processed by the appropriate state method. These actions should be registered in the undo/redo chains.

1. The state method responsible for receiving the user interaction (button/mouse/key click, mouse move, etc) gathers the necessary info and calls a *Prep* method in the appropriate controller.
2. The called controller method, - i.e. the *Prep* method - receives the appropriate info from the state, gathers any other necessary info and creates the single MPCommand necessary to execute the requested action. It also calls the execute() method of MPCommand.
3. The created MPCommand registers the necessary undo/redo info and calls its internal execute method called _actualExecute().
4. _actualExecute() calls one method from the appropriate controller (i.e. the *Exec* method that should be an @action) responsible for all actual changes in THFile, support data and necessary redraw triggers.

## Non-altering data actions

These are the actions that does not alter THFile data, i.e, opening and closing overlay windows, button arrays, etc.

1. The widget responsible for receiving the user interaction (button/mouse/key click, mouse move, etc) gathers the necessary info on the widget and calls a single method in the appropriatte controller. This method should be an @action.
2. The called controller method executes all changes in support data and activates all appropriate redraw triggers.

## Controller method types

### Prep

Method called at the begining of the action chain to prepare create and prepare MPCommands. They are also responsaible for calling the execute() method of MPCommand.

### Exec

Last method called at the action chain responsible for actually making all necessary changes to THFile and support data and call all necessary redraw triggers.
