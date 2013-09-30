//
//  UIScrollView+TPKeyboardAvoidingAdditions.h
//  TPKeyboardAvoidingSample
//
//  Created by Michael Tyson on 30/09/2013.
//
//

#import <Foundation/Foundation.h>

@interface UIScrollView (TPKeyboardAvoidingAdditions)
- (BOOL)focusNextTextField;
- (void)scrollToActiveTextField;

- (void)TPKeyboardAvoiding_keyboardWillShow:(NSNotification*)notification;
- (void)TPKeyboardAvoiding_keyboardWillHide:(NSNotification*)notification;
- (void)updateContentInset;
- (void)updateFromContentSizeChange;
- (void)assignTextDelegateForViewsBeneathView:(UIView*)view;
- (UIView*)findFirstResponderBeneathView:(UIView*)view;
-(CGSize)calculatedContentSizeFromSubviewFrames;
@end
