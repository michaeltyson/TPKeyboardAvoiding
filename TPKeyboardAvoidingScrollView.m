//
//  TPKeyboardAvoidingScrollView.m
//
//  Created by Michael Tyson on 11/04/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//

#import "TPKeyboardAvoidingScrollView.h"

#define _UIKeyboardFrameEndUserInfoKey (&UIKeyboardFrameEndUserInfoKey != NULL ? UIKeyboardFrameEndUserInfoKey : @"UIKeyboardBoundsUserInfoKey")

@interface TPKeyboardAvoidingScrollView ()
- (UIView*)findFirstResponderBeneathView:(UIView*)view;
- (CGFloat)idealOffsetForView:(UIView *)view withSpace:(CGFloat)space;
@end

@implementation TPKeyboardAvoidingScrollView

- (void)setup {
    if ( CGSizeEqualToSize(self.contentSize, CGSizeZero) ) {
        self.contentSize = self.bounds.size;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(id)initWithFrame:(CGRect)frame {
    if ( !(self = [super initWithFrame:frame]) ) return nil;
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
    if (!UIEdgeInsetsEqualToEdgeInsets(priorInset, UIEdgeInsetsZero)) return;
    
    UIView *firstResponder = [self findFirstResponderBeneathView:self];
    if ( !firstResponder ) {
        // No child view is the first responder - nothing to do here
        return;
    }
    
    priorInset = self.contentInset;
    
    // Use this view's coordinate system
    CGRect keyboardBounds = [self convertRect:[[[notification userInfo] objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
    CGRect screenBounds = [self convertRect:[UIScreen mainScreen].bounds fromView:nil];
    if ( keyboardBounds.origin.y == 0 ) keyboardBounds.origin = CGPointMake(0, screenBounds.size.height - keyboardBounds.size.height);
    
    CGFloat spaceAboveKeyboard = keyboardBounds.origin.y - self.bounds.origin.y;
    
    UIEdgeInsets newInset = self.contentInset;
    
    newInset.bottom = keyboardBounds.size.height - 
    ((keyboardBounds.origin.y+keyboardBounds.size.height) 
     - (self.bounds.origin.y+self.bounds.size.height));
    
    
    CGFloat offset = [self idealOffsetForView:firstResponder withSpace:spaceAboveKeyboard];
    
    // Shrink view's inset by the keyboard's height, and scroll to show the text field/view being edited
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    self.contentInset = newInset;
    
    
    [self setContentOffset:CGPointMake(self.contentOffset.x, offset) animated:YES];
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    if (UIEdgeInsetsEqualToEdgeInsets(priorInset, UIEdgeInsetsZero)) return;
    
    // Restore dimensions to prior size
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    self.contentInset = priorInset;
    priorInset = UIEdgeInsetsZero;
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


-(CGFloat)idealOffsetForView:(UIView *)view withSpace:(CGFloat)space
{
    
    CGFloat offset = view.frame.origin.y;
    
    if ( self.contentSize.height - offset < space ) {
        // Scroll to the bottom
        offset = self.contentSize.height - space;
    } else {
        if ( view.bounds.size.height < space ) {
            // Center vertically if there's room
            offset -= floor((space-view.bounds.size.height)/2.0);
        }
        if ( offset + space > self.contentSize.height ) {
            // Clamp to content size
            offset = self.contentSize.height - space;
        }
    }
    
    if (offset < 0) offset = 0;
    
    return offset;
}
@end
