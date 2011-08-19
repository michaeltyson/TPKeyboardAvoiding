TPKeyboardAvoiding
==================

A drop-in universal solution for moving text fields out of the way of the keyboard in iOS.

Introduction
------------

There are a hundred and one proposed solutions out there for how to move `UITextField` and `UITextView` out of the way of the keyboard during editing -- usually, it comes down to observing `UIKeyboardWillShowNotification` and `UIKeyboardWillHideNotification`, or implementing `UITextFieldDelegate` delegate methods, and adjusting the frame of the superview, or using `UITableView`'s `scrollToRowAtIndexPath:atScrollPosition:animated:`, but most proposed solutions tend to be quite DIY, and have to be implemented for each view controller that needs it.

This is a relatively universal, drop-in solution: `UIScrollView` and `UITableView` subclasses that handle everything.

When the keyboard is about to appear, the subclass will find the subview that's about to be edited, and adjust its frame and content offset to make sure that view is visible, with an animation to match the keyboard pop-up. When the keyboard disappears, it restores its prior size.

It should work with basically any setup, either a UITableView-based interface, or one consisting of views placed manually.

Usage
-----

For use with `UITableViewController` classes, drop `TPKeyboardAvoidingTableView.m` and `TPKeyboardAvoidingTableView.h` into your project, and make your UITableView a `TPKeyboardAvoidingTableView` in the xib.  If you're not using a xib with your controller, I know of no easy way to make its UITableView a custom class: The path of least resistance is to create a xib for it.

For non-UITableViewControllers, drop the `TPKeyboardAvoidingScrollView.m` and `TPKeyboardAvoidingScrollView.h` source files into your project, pop a `UIScrollView` into your view controller's xib, set the scroll view's class to `TPKeyboardAvoidingScrollView`, and put all your controls within that scroll view.  You can also create it programmatically, without using a xib - just use the TPKeyboardAvoidingScrollView as your top-level view.

Notes
-----

On iOS 4.3 and up, UITableView automatically supports moving out of the way of the keyboard.  Thus, using TPKeyboardAvoidingTableView on iOS 4.3+ environments will have no effect -- in fact, if iOS 4.3 or up is detected, the init methods for TPKeyboardAvoidingTableView will return a UITableView instead.

These classes currently adjust the contentInset parameter to avoid content moving beneath the keyboard.  This is done, as opposed to adjusting the frame, in order to work around an iOS bug that results in a jerky animation where the view jumps upwards, before settling down.  In order to facilitate this workaround, the contentSize is maintained to be at least same size as the view's frame.

Licence
-------

Free for commercial use and redistribution in any form.  Credit is appreciated but not essential.  Oh, and there aint no warranty!

Michael Tyson, A Tasty Pixel  
michael@atastypixel.com