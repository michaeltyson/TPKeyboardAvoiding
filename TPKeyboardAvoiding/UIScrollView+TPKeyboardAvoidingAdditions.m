//
//  UIScrollView+TPKeyboardAvoidingAdditions.m
//  TPKeyboardAvoidingSample
//
//  Created by Michael Tyson on 30/09/2013.
//  Copyright 2013 A Tasty Pixel. All rights reserved.
//

#import "UIScrollView+TPKeyboardAvoidingAdditions.h"
#import <objc/runtime.h>

static const CGFloat kMinimumScrollOffsetPadding = 20;
static const CGFloat kDefaultContentPadding = 10;
static const int kStateKey;

#define _UIKeyboardFrameEndUserInfoKey (&UIKeyboardFrameEndUserInfoKey != NULL ? UIKeyboardFrameEndUserInfoKey : @"UIKeyboardBoundsUserInfoKey")

@interface TPKeyboardAvoidingState : NSObject

@property (nonatomic, assign) UIEdgeInsets priorInset;
@property (nonatomic, assign) UIEdgeInsets priorScrollIndicatorInsets;
@property (nonatomic, assign) BOOL         keyboardVisible;
@property (nonatomic, assign) CGRect       keyboardRect;
@property (nonatomic, assign) CGSize       priorContentSize;

@end

@implementation UIScrollView (TPKeyboardAvoidingAdditions)

- (TPKeyboardAvoidingState*)keyboardAvoidingState {
    TPKeyboardAvoidingState *state = objc_getAssociatedObject(self, &kStateKey);
    if (state)
        return state;
    
    state = [[TPKeyboardAvoidingState alloc] init];
    objc_setAssociatedObject(self, &kStateKey, state, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#if !__has_feature(objc_arc)
    [state release];
#endif
    
    return state;
}

- (void)TPKeyboardAvoiding_keyboardWillShow:(NSNotification*)notification {
    TPKeyboardAvoidingState *state = self.keyboardAvoidingState;
    
    if (state.keyboardVisible)
        return;
    
    UIView *firstResponder = [self TPKeyboardAvoiding_findFirstResponderBeneathView:self];
    bool noChildrenWithFocus = !firstResponder;
    if (noChildrenWithFocus)
        return;
    
    state.keyboardRect = [self.superview convertRect:[[[notification userInfo] objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
    state.keyboardVisible = YES;
    state.priorInset = self.contentInset;
    state.priorScrollIndicatorInsets = self.scrollIndicatorInsets;
    
    if ( [self isKindOfClass:[TPKeyboardAvoidingScrollView class]] ) {
        state.priorContentSize = self.contentSize;
        
        if ( CGSizeEqualToSize(self.contentSize, CGSizeZero) ) {
            // Set the content size, if it's not set. Do not set content size explicitly if auto-layout
            // is being used to manage subviews
            self.contentSize = [self TPKeyboardAvoiding_calculatedContentSizeFromSubviewFrames];
        }
    }
    
    // Shrink view's inset by the keyboard's height, and scroll to show the text field/view being edited
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    
    self.contentInset = [self TPKeyboardAvoiding_contentInsetForKeyboard];
    
    if (firstResponder) {
        CGFloat viewableHeight = self.bounds.size.height - self.contentInset.top - self.contentInset.bottom;
        CGFloat yOffset = [self TPKeyboardAvoiding_idealOffsetForView:firstResponder withViewingAreaHeight:viewableHeight];
        [self setContentOffset:CGPointMake(self.contentOffset.x, yOffset) animated:NO];
    }
    
    self.scrollIndicatorInsets = self.contentInset;
    
    [UIView commitAnimations];
}

- (void)TPKeyboardAvoiding_keyboardWillHide:(NSNotification*)notification {
    TPKeyboardAvoidingState *state = self.keyboardAvoidingState;
    
    if (!state.keyboardVisible)
        return;
    
    state.keyboardRect = CGRectZero;
    state.keyboardVisible = NO;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    [self restoreDimensionsToPriorSize:state];
    [UIView commitAnimations];
}

- (void)restoreDimensionsToPriorSize:(TPKeyboardAvoidingState*)state {
    if ([self isKindOfClass:[TPKeyboardAvoidingScrollView class]])
        self.contentSize = state.priorContentSize;
    
    self.contentInset = state.priorInset;
    self.scrollIndicatorInsets = state.priorScrollIndicatorInsets;
}

- (void)TPKeyboardAvoiding_updateContentInset {
    TPKeyboardAvoidingState *state = self.keyboardAvoidingState;
    if (!state.keyboardVisible)
        return;
    
    self.contentInset = [self TPKeyboardAvoiding_contentInsetForKeyboard];
}

- (void)TPKeyboardAvoiding_updateFromContentSizeChange {
    TPKeyboardAvoidingState *state = self.keyboardAvoidingState;
    if (!state.keyboardVisible)
        return;
    
    state.priorContentSize = self.contentSize;
    self.contentInset = [self TPKeyboardAvoiding_contentInsetForKeyboard];
}

#pragma mark - Utilities
- (BOOL)TPKeyboardAvoiding_focusNextTextField {
    UIView *firstResponder = [self TPKeyboardAvoiding_findFirstResponderBeneathView:self];
    if (!firstResponder)
        return NO;
    
    CGFloat minY = CGFLOAT_MAX;
    UIView *view = nil;
    [self TPKeyboardAvoiding_findTextFieldAfterTextField:firstResponder beneathView:self minY:&minY foundView:&view];
    
    if (view) {
        [firstResponder resignFirstResponder];
        [view performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
        return YES;
    }
    
    return NO;
}

- (void)TPKeyboardAvoiding_scrollToActiveTextField {
    TPKeyboardAvoidingState *state = self.keyboardAvoidingState;
    
    if (!state.keyboardVisible)
        return;
    
    CGFloat visibleSpace = self.bounds.size.height - self.contentInset.top - self.contentInset.bottom;
    
    CGPoint idealOffset = CGPointMake(0, [self TPKeyboardAvoiding_idealOffsetForView:[self TPKeyboardAvoiding_findFirstResponderBeneathView:self] withViewingAreaHeight:visibleSpace]);
    
    // Ordinarily we'd use -setContentOffset:animated:YES here, but it does not appear to
    // scroll to the desired content offset. So we wrap in our own animation block.
    [UIView animateWithDuration:0.25 animations:^{
        [self setContentOffset:idealOffset animated:NO];
    }];
}

#pragma mark - Helpers

/*! Search recursively for first responder */
- (UIView*)TPKeyboardAvoiding_findFirstResponderBeneathView:(UIView*)view {
    
    for ( UIView *childView in view.subviews ) {
        if ([childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder])
            return childView;
        
        UIView *result = [self TPKeyboardAvoiding_findFirstResponderBeneathView:childView];
        if (result)
            return result;
    }
    
    return nil;
}

/*! Search recursively for text field or text view below priorTextField */
- (void)TPKeyboardAvoiding_findTextFieldAfterTextField:(UIView*)priorTextField beneathView:(UIView*)view minY:(CGFloat*)minY foundView:(UIView**)foundView {
    CGFloat priorFieldOffset = CGRectGetMinY([self convertRect:priorTextField.frame fromView:priorTextField.superview]);
    CGFloat priorFieldOffX = CGRectGetMinX([self convertRect:priorTextField.frame fromView:priorTextField.superview]);
    
    for ( UIView *childView in view.subviews ) {
        if (childView.hidden)
            continue;
        
        bool childIsTextFieldOrView = ([childView isKindOfClass:[UITextField class]] || [childView isKindOfClass:[UITextView class]]);
        
        if (!childIsTextFieldOrView) {
            [self TPKeyboardAvoiding_findTextFieldAfterTextField:priorTextField beneathView:childView minY:minY foundView:foundView];
            continue;
        }
        
        CGRect frame = [self convertRect:childView.frame fromView:view];
        bool notPriorTextField = (childView != priorTextField);
        bool equalOrGreaterThanPriorOffset = CGRectGetMinY(frame) >= priorFieldOffset;
        bool lessThanFoundY = CGRectGetMinY(frame) < *minY;
        bool xIsLessThanPriorX = (frame.origin.y == priorFieldOffset
                                  && frame.origin.x < priorFieldOffX);
        
        if (notPriorTextField && equalOrGreaterThanPriorOffset && lessThanFoundY && !xIsLessThanPriorX ) {
            *minY = CGRectGetMinY(frame);
            *foundView = childView;
        }
    }
}

- (void)TPKeyboardAvoiding_assignTextDelegateForViewsBeneathView:(UIView*)view {
    for (UIView *childView in view.subviews) {
        bool childIsTextFieldOrView = ([childView isKindOfClass:[UITextField class]] || [childView isKindOfClass:[UITextView class]]);
        
        if (childIsTextFieldOrView)
            [self TPKeyboardAvoiding_initializeView:childView];
        else
            [self TPKeyboardAvoiding_assignTextDelegateForViewsBeneathView:childView];
    }
}

- (CGSize)TPKeyboardAvoiding_calculatedContentSizeFromSubviewFrames {
    
    BOOL wasShowingVerticalScrollIndicator = self.showsVerticalScrollIndicator;
    BOOL wasShowingHorizontalScrollIndicator = self.showsHorizontalScrollIndicator;
    
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    CGRect rect = CGRectZero;
    for (UIView *view in self.subviews)
        rect = CGRectUnion(rect, view.frame);
    
    CGFloat contentPadding = kDefaultContentPadding;
    if ([self respondsToSelector:@selector(contentPadding)])
    {
        NSNumber* contentPadNum = [self valueForKey:@"contentPadding"];
        contentPadding = [contentPadNum floatValue];
    }
    
    rect.size.height += contentPadding;
    
    self.showsVerticalScrollIndicator = wasShowingVerticalScrollIndicator;
    self.showsHorizontalScrollIndicator = wasShowingHorizontalScrollIndicator;
    
    return rect.size;
}


- (UIEdgeInsets)TPKeyboardAvoiding_contentInsetForKeyboard {
    TPKeyboardAvoidingState *state = self.keyboardAvoidingState;
    UIEdgeInsets newInset = self.contentInset;
    CGRect keyboardRect = state.keyboardRect;
    CGFloat idk = (CGRectGetMaxY(keyboardRect) - CGRectGetMaxY(self.frame));
    newInset.bottom = CGRectGetHeight(keyboardRect) - idk;
    return newInset;
}

- (CGFloat)TPKeyboardAvoiding_idealOffsetForView:(UIView *)view withViewingAreaHeight:(CGFloat)viewAreaHeight {
    CGSize contentSize = self.contentSize;
    CGFloat offset = 0.0;
    
    CGRect subviewRect = [view convertRect:view.bounds toView:self];
    
    // Attempt to center the subview in the visible space, but if that means there will be less than kMinimumScrollOffsetPadding
    // pixels above the view, then substitute kMinimumScrollOffsetPadding
    CGFloat padding = (viewAreaHeight - subviewRect.size.height) / 2;
    if ( padding < kMinimumScrollOffsetPadding ) {
        padding = kMinimumScrollOffsetPadding;
    }
    
    // Ideal offset places the subview rectangle origin "padding" points from the top of the scrollview.
    // If there is a top contentInset, also compensate for this so that subviewRect will not be placed under
    // things like navigation bars.
    offset = subviewRect.origin.y - padding - self.contentInset.top;
    
    // Constrain the new contentOffset so we can't scroll past the bottom. Note that we don't take the bottom
    // inset into account, as this is manipulated to make space for the keyboard.
    if ( offset > (contentSize.height - viewAreaHeight) ) {
        offset = contentSize.height - viewAreaHeight;
    }
    
    // Constrain the new contentOffset so we can't scroll past the top, taking contentInsets into account
    if ( offset < -self.contentInset.top ) {
        offset = -self.contentInset.top;
    }
    
    return offset;
}

- (void)TPKeyboardAvoiding_initializeView:(UIView*)view {
    bool viewIsTextField = [view isKindOfClass:[UITextField class]];
    if (!viewIsTextField)
        return;
    
    UITextField* textField          = (UITextField*)view;
    bool viewHasDefaultReturnKey    = textField.returnKeyType == UIReturnKeyDefault;
    bool viewDelegateIsNotSet       = textField.delegate == nil;
    bool viewDelegateIsSelf         = textField.delegate == self;
    
    if (!viewHasDefaultReturnKey)
        return;
    
    if (!viewDelegateIsNotSet && !viewDelegateIsSelf)
        return;
    
    [textField setDelegate:self];
    
    UIView *otherView   = nil;
    CGFloat minY        = CGFLOAT_MAX;
    [self TPKeyboardAvoiding_findTextFieldAfterTextField:view beneathView:self minY:&minY foundView:&otherView];
    
    if (otherView)
        textField.returnKeyType = UIReturnKeyNext;
    else
        textField.returnKeyType = UIReturnKeyDone;
}

@end


@implementation TPKeyboardAvoidingState
@end
