PopoverTokenField
=================

Subclass of NSTokenField that achieves two main goal. First it presents the list of
suggestions in a NSPopover filled with suggestion tokens. Second it enables the 
possibility of showing the suggestion when the control becomes first responder.
It is useful when the list of suggestions is always limited and the developer wants to
provide the user with possible tokens just before editing.

This is how it looks:
![JSTokenCloud](http://s10.postimage.org/f6rd4sbyh/Screen_Shot.png)

How to use it
-----------------

The class can be used directly as an alternative for NSTokenField. The subclass hijack the
-(NSArray *)tokenField:(NSTokenField *)tokenField completionsForSubstring:(NSString *)substring indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(NSInteger *)selectedIndex
delegate method but forward every other delegate method as usual.

It also add the -(NSArray *)tokenField:(JSTokenField *)tokenField tokensGivenCurrentTokens:(NSArray *)tokens;
delegate method to provide the control with a list of possible tokens to display in the
suggestion list in the popover.

Current Limitations
-----------------

* The code has essentially no comments in it. Hopefully I will write them in the next
or so.
* There is currently no way to browse the token suggestions with the keyboard the same 
way it is possible to browse the suggestion menu of a NSTokenField.
* Various bugs with forwarding delegate methods.

Credits
-----------------

The code include parts from from M3TokenController (http://www.mcubedsw.com/dev)
Copyright (c) 2006-2009 M Cubed Software
