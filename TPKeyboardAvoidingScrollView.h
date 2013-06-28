//
//  TPKeyboardAvoidingScrollView.h
//
//  Created by Michael Tyson on 11/04/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPKeyboardAvoidingScrollView : UIScrollView
@property (assign, nonatomic) BOOL autoAdjustsContentSizeToBounds;
- (BOOL)focusNextTextField;
- (void)scrollToActiveTextField;
@end
