//
//  TPKeyboardAvoidingScrollView.h
//
//  Created by Michael Tyson on 11/04/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//

@interface TPKeyboardAvoidingScrollView : UIScrollView {
    UIEdgeInsets priorInset;
    BOOL _keyboardVisible;
}

- (void)adjustOffsetToIdealIfNeeded;
@end
