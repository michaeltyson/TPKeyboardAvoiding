//
//  TPKeyboardAvoidingCollectionView.h
//
//  Created by Michael Tyson on 26/11/2013.
//  Copyright 2013 A Tasty Pixel & The CocoaBots. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPKeyboardAvoidingProxy : NSObject

@property (nonatomic, weak) UIScrollView *parent;

+ (instancetype)proxyWithParent:(UIScrollView *)parent;

- (void)delayedAssignTextDelegateForViews;

@end
