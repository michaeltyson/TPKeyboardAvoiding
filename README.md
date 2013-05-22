TPKeyboardAvoiding
==================

A drop-in universal solution for moving text fields out of the way of the keyboard in iOS.
<!-- MacBuildServer Install Button -->
<div class="macbuildserver-block">
    <a class="macbuildserver-button" href="http://macbuildserver.com/project/github/build/?xcode_project=TPKeyboardAvoidingSample.xcodeproj&amp;target=TPKeyboardAvoidingSample&amp;repo_url=https%3A%2F%2Fgithub.com%2Fmichaeltyson%2FTPKeyboardAvoiding&amp;build_conf=Release" target="_blank"><img src="http://com.macbuildserver.github.s3-website-us-east-1.amazonaws.com/button_up.png"/></a><br/><sup><a href="http://macbuildserver.com/github/opensource/" target="_blank">by MacBuildServer</a></sup>
</div>
<!-- MacBuildServer Install Button -->

Introduction
------------

There are a hundred and one proposed solutions out there for how to move `UITextField` and `UITextView` out of the way of the keyboard during editing -- usually, it comes down to observing `UIKeyboardWillShowNotification` and `UIKeyboardWillHideNotification`, or implementing `UITextFieldDelegate` delegate methods, and adjusting the frame of the superview, or using `UITableView`'s `scrollToRowAtIndexPath:atScrollPosition:animated:`, but most proposed solutions tend to be quite DIY, and have to be implemented for each view controller that needs it.

This is a relatively universal, drop-in solution: `UIScrollView` and `UITableView` subclasses that handle everything.

When the keyboard is about to appear, the subclass will find the subview that's about to be edited, and adjust its frame and content offset to make sure that view is visible, with an animation to match the keyboard pop-up. When the keyboard disappears, it restores its prior size.

It should work with basically any setup, either a UITableView-based interface, or one consisting of views placed manually.

It also automatically hooks up "Next" buttons on the keyboard to switch through the text fields.

Usage
-----

For use with `UITableViewController` classes, drop `TPKeyboardAvoidingTableView.m` and `TPKeyboardAvoidingTableView.h` into your project, and make your UITableView a `TPKeyboardAvoidingTableView` in the xib.  If you're not using a xib with your controller, I know of no easy way to make its UITableView a custom class: The path of least resistance is to create a xib for it.

For non-UITableViewControllers, drop the `TPKeyboardAvoidingScrollView.m` and `TPKeyboardAvoidingScrollView.h` source files into your project, pop a `UIScrollView` into your view controller's xib, set the scroll view's class to `TPKeyboardAvoidingScrollView`, and put all your controls within that scroll view.  You can also create it programmatically, without using a xib - just use the TPKeyboardAvoidingScrollView as your top-level view.

Notes
-----

These classes currently adjust the contentInset parameter to avoid content moving beneath the keyboard.  This is done, as opposed to adjusting the frame, in order to work around an iOS bug that results in a jerky animation where the view jumps upwards, before settling down.  In order to facilitate this workaround, the contentSize is maintained to be at least same size as the view's frame.

Licence
-------

Free for commercial use and redistribution in any form.  Credit is appreciated but not essential.  Oh, and there aint no warranty!

Michael Tyson, A Tasty Pixel  
michael@atastypixel.com
