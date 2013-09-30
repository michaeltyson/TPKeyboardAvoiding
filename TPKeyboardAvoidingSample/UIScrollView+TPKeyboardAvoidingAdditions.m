//
//  UIScrollView+TPKeyboardAvoidingAdditions.m
//  TPKeyboardAvoidingSample
//
//  Created by Michael Tyson on 30/09/2013.
//
//

#import "UIScrollView+TPKeyboardAvoidingAdditions.h"
#import "TPKeyboardAvoidingScrollView.h"
#import <objc/runtime.h>

static const CGFloat kCalculatedContentPadding = 10;
static const CGFloat kMinimumScrollOffsetPadding = 20;

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
    if ( !state ) {
        state = [[TPKeyboardAvoidingState alloc] init];
        objc_setAssociatedObject(self, &kStateKey, state, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#if !__has_feature(objc_arc)
        [state release];
#endif
    }
    return state;
}

- (void)TPKeyboardAvoiding_keyboardWillShow:(NSNotification*)notification {
    UIView *firstResponder = [self TPKeyboardAvoiding_findFirstResponderBeneathView:self];
    if ( !firstResponder ) {
        // No child view is the first responder - nothing to do here
        return;
    }
    
    TPKeyboardAvoidingState *state = self.keyboardAvoidingState;
    state.keyboardRect = [[[notification userInfo] objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue];
    state.keyboardVisible = YES;
    state.priorInset = self.contentInset;
    state.priorScrollIndicatorInsets = self.scrollIndicatorInsets;
    
    if ( [self isKindOfClass:[TPKeyboardAvoidingScrollView class]] ) {
        state.priorContentSize = self.contentSize;
        
        if ( CGSizeEqualToSize(self.contentSize, CGSizeZero) ) {
            // Set the content size, if it's not set
            self.contentSize = [self TPKeyboardAvoiding_calculatedContentSizeFromSubviewFrames];
        }
    }
    
    // Shrink view's inset by the keyboard's height, and scroll to show the text field/view being edited
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    
    self.contentInset = [self TPKeyboardAvoiding_contentInsetForKeyboard];
    [self setContentOffset:CGPointMake(self.contentOffset.x,
                                    [self TPKeyboardAvoiding_idealOffsetForView:firstResponder
                                                          withViewingAreaHeight:CGRectGetMinY(state.keyboardRect) - CGRectGetMinY([self convertRect:self.bounds toView:nil])])
                  animated:NO];
    self.scrollIndicatorInsets = self.contentInset;
    
    [UIView commitAnimations];
}

- (void)TPKeyboardAvoiding_keyboardWillHide:(NSNotification*)notification {
    TPKeyboardAvoidingState *state = self.keyboardAvoidingState;
    
    if ( !state.keyboardVisible ) {
        return;
    }
    
    state.keyboardRect = CGRectZero;
    state.keyboardVisible = NO;
    
    // Restore dimensions to prior size
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    
    if ( [self isKindOfClass:[TPKeyboardAvoidingScrollView class]] ) {
        self.contentSize = state.priorContentSize;
    }
    
    self.contentInset = state.priorInset;
    self.scrollIndicatorInsets = state.priorScrollIndicatorInsets;
    [UIView commitAnimations];
}

- (void)TPKeyboardAvoiding_updateContentInset {
    TPKeyboardAvoidingState *state = self.keyboardAvoidingState;
    if ( state.keyboardVisible ) {
        self.contentInset = [self TPKeyboardAvoiding_contentInsetForKeyboard];
    }
}

- (void)TPKeyboardAvoiding_updateFromContentSizeChange {
    TPKeyboardAvoidingState *state = self.keyboardAvoidingState;
    if ( state.keyboardVisible ) {
		state.priorContentSize = self.contentSize;
        self.contentInset = [self TPKeyboardAvoiding_contentInsetForKeyboard];
    }
}

#pragma mark - Utilities

- (BOOL)TPKeyboardAvoiding_focusNextTextField {
    UIView *firstResponder = [self TPKeyboardAvoiding_findFirstResponderBeneathView:self];
    if ( !firstResponder ) {
        return NO;
    }
    
    CGFloat minY = CGFLOAT_MAX;
    UIView *view = nil;
    [self TPKeyboardAvoiding_findTextFieldAfterTextField:firstResponder beneathView:self minY:&minY foundView:&view];
    
    if ( view ) {
        [view becomeFirstResponder];
        return YES;
    }
    
    return NO;
}

-(void)TPKeyboardAvoiding_scrollToActiveTextField {
    TPKeyboardAvoidingState *state = self.keyboardAvoidingState;
    
    if ( !state.keyboardVisible ) return;
    
    CGFloat visibleSpace = self.bounds.size.height - self.contentInset.top - self.contentInset.bottom;
    
    CGPoint idealOffset = CGPointMake(0, [self TPKeyboardAvoiding_idealOffsetForView:[self TPKeyboardAvoiding_findFirstResponderBeneathView:self]
                                                               withViewingAreaHeight:visibleSpace]);
    
    [self setContentOffset:idealOffset animated:YES];
}

#pragma mark - Helpers

- (UIView*)TPKeyboardAvoiding_findFirstResponderBeneathView:(UIView*)view {
    // Search recursively for first responder
    for ( UIView *childView in view.subviews ) {
        if ( [childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder] ) return childView;
        UIView *result = [self TPKeyboardAvoiding_findFirstResponderBeneathView:childView];
        if ( result ) return result;
    }
    return nil;
}

- (void)TPKeyboardAvoiding_findTextFieldAfterTextField:(UIView*)priorTextField beneathView:(UIView*)view minY:(CGFloat*)minY foundView:(UIView**)foundView {
    // Search recursively for text field or text view below priorTextField
    CGFloat priorFieldOffset = CGRectGetMinY([self convertRect:priorTextField.frame fromView:priorTextField.superview]);
    for ( UIView *childView in view.subviews ) {
        if ( childView.hidden ) continue;
        if ( ([childView isKindOfClass:[UITextField class]] || [childView isKindOfClass:[UITextView class]]) ) {
            CGRect frame = [self convertRect:childView.frame fromView:view];
            if ( childView != priorTextField && CGRectGetMinY(frame) >= priorFieldOffset && CGRectGetMinY(frame) < *minY ) {
                *minY = CGRectGetMinY(frame);
                *foundView = childView;
            }
        } else {
            [self TPKeyboardAvoiding_findTextFieldAfterTextField:priorTextField beneathView:childView minY:minY foundView:foundView];
        }
    }
}

- (void)TPKeyboardAvoiding_assignTextDelegateForViewsBeneathView:(UIView*)view {
    for ( UIView *childView in view.subviews ) {
        if ( ([childView isKindOfClass:[UITextField class]] || [childView isKindOfClass:[UITextView class]]) ) {
            [self TPKeyboardAvoiding_initializeView:childView];
        } else {
            [self TPKeyboardAvoiding_assignTextDelegateForViewsBeneathView:childView];
        }
    }
}

-(CGSize)TPKeyboardAvoiding_calculatedContentSizeFromSubviewFrames {
    CGRect rect = CGRectZero;
    for ( UIView *view in self.subviews ) {
        rect = CGRectUnion(rect, view.frame);
    }
    rect.size.height += kCalculatedContentPadding;
    return rect.size;
}

- (UIEdgeInsets)TPKeyboardAvoiding_contentInsetForKeyboard {
    TPKeyboardAvoidingState *state = self.keyboardAvoidingState;
    UIEdgeInsets newInset = self.contentInset;
    CGRect keyboardRect = state.keyboardRect;
    newInset.bottom = keyboardRect.size.height
                        - (CGRectGetMaxY(keyboardRect) - CGRectGetMaxY([self convertRect:self.bounds toView:nil]));
    return newInset;
}

-(CGFloat)TPKeyboardAvoiding_idealOffsetForView:(UIView *)view withViewingAreaHeight:(CGFloat)viewAreaHeight {
    
    // Convert the rect to get the view's distance from the top of the scrollView.
    CGRect rect = CGRectInset([view convertRect:view.bounds toView:self], 0, -kMinimumScrollOffsetPadding);
    
    CGFloat offset;
    
    if ( self.contentSize.height - rect.origin.y < viewAreaHeight ) {
        // Scroll to the bottom
        offset = self.contentSize.height - viewAreaHeight;
    } else {
        offset = CGRectGetMinY(rect);
        
        if ( view.bounds.size.height < viewAreaHeight ) {
            // Center vertically if there's room
            offset = CGRectGetMinY(rect) - floor((viewAreaHeight-rect.size.height)/2.0);
        }
        if ( rect.origin.y + viewAreaHeight > self.contentSize.height ) {
            // Clamp to content size
            offset = self.contentSize.height - viewAreaHeight;
        }
    }
    
    if ( offset < 0 ) {
        offset = 0;
    }
    
    return offset;
}

- (CGRect)TPKeyboardAvoiding_keyboardRect {
    TPKeyboardAvoidingState *state = self.keyboardAvoidingState;
    CGRect keyboardRect = [self convertRect:state.keyboardRect fromView:nil];
    if ( keyboardRect.origin.y == 0 ) {
        CGRect screenBounds = [self convertRect:[UIScreen mainScreen].bounds fromView:nil];
        keyboardRect.origin = CGPointMake(0, screenBounds.size.height - keyboardRect.size.height);
    }
    return keyboardRect;
}

- (void)TPKeyboardAvoiding_initializeView:(UIView*)view {
    if ( ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]]) && (![(id)view delegate] || [(id)view delegate] == self) ) {
        [(id)view setDelegate:self];
        
        if ( [view isKindOfClass:[UITextField class]] ) {
            UIView *otherView = nil;
            CGFloat minY = CGFLOAT_MAX;
            [self TPKeyboardAvoiding_findTextFieldAfterTextField:view beneathView:self minY:&minY foundView:&otherView];
            
            if ( otherView ) {
                ((UITextField*)view).returnKeyType = UIReturnKeyNext;
            } else {
                ((UITextField*)view).returnKeyType = UIReturnKeyDone;
            }
        }
    }
}

@end


@implementation TPKeyboardAvoidingState
@end