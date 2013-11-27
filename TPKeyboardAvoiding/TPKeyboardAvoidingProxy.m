//
//  UIScrollView+TPKeyboardAvoidingAdditions.m
//
//  Created by Michael Tyson on 26/11/2013.
//  Copyright 2013 A Tasty Pixel. All rights reserved.
//

#import "TPKeyboardAvoidingProxy.h"
#import "UIScrollView+TPKeyboardAvoidingAdditions.h"

@implementation TPKeyboardAvoidingProxy

+ (instancetype)proxyWithParent:(UIScrollView *)parent
{
    return [[TPKeyboardAvoidingProxy alloc] initWithParent:parent];
}

- (id)initWithParent:(UIScrollView *)parent
{
    if (self = [super init]) {
        _parent = parent;
    }
    return self;
}

- (void)delayedAssignTextDelegateForViews
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(assignTextDelegateForViews) object:nil];
    [self performSelector:@selector(assignTextDelegateForViews) withObject:nil afterDelay:0.1];
}

#pragma mark - Private

- (void)assignTextDelegateForViews
{
    if (_parent)
        [_parent TPKeyboardAvoiding_assignTextDelegateForViewsBeneathView:_parent];
}

@end
