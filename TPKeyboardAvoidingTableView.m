//
//  TPKeyboardAvoidingTableView.m
//
//  Created by Michael Tyson on 11/04/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//

#import "TPKeyboardAvoidingTableView.h"

#define _UIKeyboardFrameEndUserInfoKey (&UIKeyboardFrameEndUserInfoKey != NULL ? UIKeyboardFrameEndUserInfoKey : @"UIKeyboardBoundsUserInfoKey")

@interface TPKeyboardAvoidingTableView ()
- (UIView*)findFirstResponderBeneathView:(UIView*)view;
@end

@implementation TPKeyboardAvoidingTableView

- (void)setup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if ( !(self = [super initWithFrame:frame style:style]) ) return nil;
    [self setup];
    return self;
}

-(void)awakeFromNib {
    [self setup];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


- (void)keyboardWillShow:(NSNotification*)notification {
    if ( !CGRectEqualToRect(priorFrame, CGRectZero) ) return;
    
    UIView *firstResponder = [self findFirstResponderBeneathView:self];
    if ( !firstResponder ) {
        // No child view is the first responder - nothing to do here
        return;
    }
    
    priorFrame = self.frame;
    
    // Use this view's coordinate system
    CGRect keyboardBounds = [self convertRect:[[[notification userInfo] objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
    CGRect screenBounds = [self convertRect:[UIScreen mainScreen].bounds fromView:nil];
    if ( keyboardBounds.origin.y == 0 ) keyboardBounds.origin = CGPointMake(0, screenBounds.size.height - keyboardBounds.size.height);
    
    CGFloat spaceAboveKeyboard = keyboardBounds.origin.y - self.bounds.origin.y;
    CGFloat offset = -1;
    
    CGRect newFrame = self.frame;
    newFrame.size.height -= keyboardBounds.size.height - 
    ((keyboardBounds.origin.y+keyboardBounds.size.height) 
     - (self.bounds.origin.y+self.bounds.size.height));
    
    CGRect firstResponderFrame = [firstResponder convertRect:firstResponder.bounds toView:self];
    if ( firstResponderFrame.origin.y + firstResponderFrame.size.height >= screenBounds.origin.y + screenBounds.size.height - keyboardBounds.size.height ) {
        // Prepare to scroll to make sure the view is above the keyboard
        offset = firstResponderFrame.origin.y + self.contentOffset.y;
        if ( self.contentSize.height - offset < newFrame.size.height ) {
            // Scroll to the bottom
            offset = self.contentSize.height - newFrame.size.height;
        } else {
            if ( firstResponder.bounds.size.height < spaceAboveKeyboard ) {
                // Center vertically if there's room
                offset -= floor((spaceAboveKeyboard-firstResponder.bounds.size.height)/2.0);
            }
            if ( offset + newFrame.size.height > self.contentSize.height ) {
                // Clamp to content size
                offset = self.contentSize.height - newFrame.size.height;
            }
        }
    }
    
    // Shrink view's height by the keyboard's height, and scroll to show the text field/view being edited
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    self.frame = newFrame;
    
    if ( offset != -1 ) {
        [self setContentOffset:CGPointMake(self.contentOffset.x, offset) animated:YES];
    }
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    if ( CGRectEqualToRect(priorFrame, CGRectZero) ) return;
    
    // Restore dimensions to prior size
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    self.frame = priorFrame;
    priorFrame = CGRectZero;
    [UIView commitAnimations];
}

- (UIView*)findFirstResponderBeneathView:(UIView*)view {
    // Search recursively for first responder
    for ( UIView *childView in view.subviews ) {
        if ( [childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder] ) return childView;
        UIView *result = [self findFirstResponderBeneathView:childView];
        if ( result ) return result;
    }
    return nil;
}

@end
