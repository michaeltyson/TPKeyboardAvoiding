//
//  TPKeyboardAvoidingCollectionView.m
//
//  Created by Michael Tyson on 30/09/2013.
//  Copyright 2013 A Tasty Pixel & The CocoaBots. All rights reserved.
//

#import "TPKeyboardAvoidingCollectionView.h"
#import "TPKeyboardAvoidingProxy.h"

@interface TPKeyboardAvoidingCollectionView () <UITextFieldDelegate, UITextViewDelegate>
@end

@implementation TPKeyboardAvoidingCollectionView
{
    TPKeyboardAvoidingProxy *_proxy;
}

#pragma mark - Setup/Teardown

- (void)setup {
    _proxy = [TPKeyboardAvoidingProxy proxyWithParent:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TPKeyboardAvoiding_keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TPKeyboardAvoiding_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(id)initWithFrame:(CGRect)frame {
    if ( !(self = [super initWithFrame:frame]) ) return nil;
    [self setup];
    return self;
}

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if ( !(self = [super initWithFrame:frame collectionViewLayout:layout]) ) return nil;
    [self setup];
    return self;
}

-(void)awakeFromNib {
    [self setup];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self TPKeyboardAvoiding_updateContentInset];
}

-(void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    [self TPKeyboardAvoiding_updateContentInset];
}

- (BOOL)focusNextTextField {
    return [self TPKeyboardAvoiding_focusNextTextField];
    
}
- (void)scrollToActiveTextField {
    return [self TPKeyboardAvoiding_scrollToActiveTextField];
}

#pragma mark - Responders, events

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self TPKeyboardAvoiding_findFirstResponderBeneathView:self] resignFirstResponder];
    [super touchesEnded:touches withEvent:event];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ( ![self focusNextTextField] ) {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [self scrollToActiveTextField];
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    [self scrollToActiveTextField];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [_proxy delayedAssignTextDelegateForViews];
}

@end
