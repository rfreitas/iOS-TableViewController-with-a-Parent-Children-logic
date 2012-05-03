iOS-TableViewController-with-a-Parent-Children-logic
====================================================

iOS TableViewController with a Parent Children logic. Each Section has one parent as the head row, the rest of the rows are its children.

 This project has only one abstract class (subclass of UITableViewController). This is an abstract class by implementation, which does not fail when instantiated, but its rather empty of functionality. It can be used concretely, but it will only display an empty table.
Therefore, in order to use it, it has to be subclassed and the methods in the protocol implemented.