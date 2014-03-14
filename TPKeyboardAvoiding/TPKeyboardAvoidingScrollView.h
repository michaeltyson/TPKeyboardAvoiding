//
//  TPKeyboardAvoidingScrollView.h
//
//  Created by Michael Tyson on 30/09/2013.
//  Copyright 2013 A Tasty Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPKeyboardAvoidingScrollView : UIScrollView <UITextFieldDelegate, UITextViewDelegate>

@property (assign, nonatomic) CGFloat contentPadding;

- (void)contentSizeToFit;
- (BOOL)focusNextTextField;
- (void)scrollToActiveTextField;

@end

#import "UIScrollView+TPKeyboardAvoidingAdditions.h"
