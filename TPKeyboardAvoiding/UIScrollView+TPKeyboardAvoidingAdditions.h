//
//  UIScrollView+TPKeyboardAvoidingAdditions.h
//  TPKeyboardAvoiding
//
//  Created by Michael Tyson on 30/09/2013.
//  Copyright 2015 A Tasty Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingAction.h"

@interface UIScrollView (TPKeyboardAvoidingAdditions)

@property (strong, nonatomic) NSMapTable<UIView *, id<UITextFieldDelegate>>* textFieldDelegates;

- (BOOL)TPKeyboardAvoiding_focusNextTextField;
- (BOOL)TPKeyboardAvoiding_focusPrevTextField;
- (void)TPKeyboardAvoiding_scrollToActiveTextField;

- (void)TPKeyboardAvoiding_keyboardWillShow:(NSNotification*)notification;
- (void)TPKeyboardAvoiding_keyboardWillHide:(NSNotification*)notification;
- (void)TPKeyboardAvoiding_updateContentInset;
- (void)TPKeyboardAvoiding_updateFromContentSizeChange;
- (void)TPKeyboardAvoiding_assignTextDelegateForViewsBeneathView:(UIView*)view;
- (UIView*)TPKeyboardAvoiding_findFirstResponderBeneathView:(UIView*)view;
- (CGSize)TPKeyboardAvoiding_calculatedContentSizeFromSubviewFrames;
@end
