//
//  TPKeyboardAvoidingScrollView.h
//
//  Created by Michael Tyson on 30/09/2013.
//  Copyright 2013 A Tasty Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+TPKeyboardAvoidingAdditions.h"

@class TPKeyboardAvoidingScrollView;

@protocol TPKeyboardAvoidingScrollViewDelegate <NSObject>

@optional
/**
 *  Asks the delegate for a preferred content offset for a specific first responder. 
 *  Return the suggested offset if you agree with the default behaviour.
 *
 *  @param scrollView      The TPKeyboardAvoidingScrollView that is about to change its contentOffset.
 *  @param firstResponder  The view that has just become first responder and is the target for the scroll.
 *  @param suggestedOffset The offset suggested by TPKeyboardAvoidingScrollView. Return this value if you want the default behaviour for this first responder.
 *
 *  @return The new contentOffset for the scrollView. Return suggestedOffset for the default behaviour.
 */
- (CGPoint)scrollView:(TPKeyboardAvoidingScrollView *)scrollView contentOffsetForFirstResponder:(UIView *)firstResponder suggestedOffset:(CGPoint)suggestedOffset;


@end

@interface TPKeyboardAvoidingScrollView : UIScrollView <UITextFieldDelegate, UITextViewDelegate>

@property(nonatomic, assign) id<TPKeyboardAvoidingScrollViewDelegate> keyboardAvoidingDelegate;

- (void)contentSizeToFit;
- (BOOL)focusNextTextField;
- (void)scrollToActiveTextField;
@end
