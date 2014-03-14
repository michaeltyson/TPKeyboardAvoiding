//
//  TPKeyboardAvoidingTableView.h
//
//  Created by Michael Tyson on 30/09/2013.
//  Copyright 2013 A Tasty Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+TPKeyboardAvoidingAdditions.h"

@interface TPKeyboardAvoidingTableView : UITableView <UITextFieldDelegate, UITextViewDelegate>

@property (assign, nonatomic) CGFloat contentPadding;

- (BOOL)focusNextTextField;
- (void)scrollToActiveTextField;
@end
