//
//  TPKeyboardAvoidingCollectionView.h
//
//  Created by Tony Arnold on 4/08/2013.
//  Copyright 2013 The CocoaBots. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+TPKeyboardAvoidingAdditions.h"

@interface TPKeyboardAvoidingCollectionView : UICollectionView
- (BOOL)focusNextTextField;
- (void)scrollToActiveTextField;
@end
