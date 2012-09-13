PopoverTokenField
=================

Subclass of NSTokenField that achieves two main goal. First it presents the list of
suggestions in a NSPopover filled with suggestion tokens. Second it enables the 
possibility of showing the suggestion when the control becomes first responder.
It is useful when the list of suggestions is always limited and the developer wants to
provide the user with possible tokens just before editing.

Current Limitations
-----------------

* The code has essentially no comments in it. Hopefully I will write them in the next
or so.
* There is currently no way to browse the token suggestions with the keyboard the same 
way it is possible to browse the suggestion menu of a NSTokenField.
* Various bugs with forwarding delegate methods.
