//
//  TPKeyboardAvoidingScrollView.m
//  TPKeyboardAvoiding
//
//  Created by Michael Tyson on 30/09/2013.
//  Copyright 2015 A Tasty Pixel. All rights reserved.
//

#import "TPKeyboardAvoidingScrollView.h"

#if ! TARGET_OS_TV

@interface TPKeyboardAvoidingScrollView () <UITextFieldDelegate, UITextViewDelegate>
@end

@implementation TPKeyboardAvoidingScrollView

#pragma mark - Setup/Teardown

- (void)setupKeyboardAvoiding {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TPKeyboardAvoiding_keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TPKeyboardAvoiding_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToActiveTextField) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToActiveTextField) name:UITextFieldTextDidBeginEditingNotification object:nil];
}

-(id)initWithFrame:(CGRect)frame {
    if ( !(self = [super initWithFrame:frame]) ) return nil;
    [self setupKeyboardAvoiding];
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self setupKeyboardAvoiding];
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
    [self TPKeyboardAvoiding_updateFromContentSizeChange];
}

- (void)contentSizeToFit {
    self.contentSize = [self TPKeyboardAvoiding_calculatedContentSizeFromSubviewFrames];
}

- (BOOL)focusNextTextField {
    return [self TPKeyboardAvoiding_focusNextTextField];
    
}
- (void)scrollToActiveTextField {
    return [self TPKeyboardAvoiding_scrollToActiveTextField];
}

#pragma mark - Responders, events

-(void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if ( !newSuperview ) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(TPKeyboardAvoiding_assignTextDelegateForViewsBeneathView:) object:self];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self TPKeyboardAvoiding_findFirstResponderBeneathView:self] resignFirstResponder];
    [super touchesEnded:touches withEvent:event];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(TPKeyboardAvoiding_assignTextDelegateForViewsBeneathView:) object:self];
    [self performSelector:@selector(TPKeyboardAvoiding_assignTextDelegateForViewsBeneathView:) withObject:self afterDelay:0.1];
}

#pragma mark - UITextField delegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ( ![self focusNextTextField] ) {
        [textField resignFirstResponder];
    }
    
    if ([[self textFieldDelegates] objectForKey:textField]
        && [[[self textFieldDelegates] objectForKey:textField] respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [[[self textFieldDelegates] objectForKey:textField] textFieldShouldReturn:textField];
    }
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([[[self textFieldDelegates] objectForKey:textField] respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [[[self textFieldDelegates] objectForKey:textField] textFieldDidBeginEditing:textField];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if ([[[self textFieldDelegates] objectForKey:textField] respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [[[self textFieldDelegates] objectForKey:textField] textFieldDidEndEditing:textField];
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([[self textFieldDelegates] objectForKey:textField]
        && [[[self textFieldDelegates] objectForKey:textField] respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        return [[[self textFieldDelegates] objectForKey:textField] textFieldShouldBeginEditing:textField];
    }
    
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([[self textFieldDelegates] objectForKey:textField]
        && [[[self textFieldDelegates] objectForKey:textField] respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        return [[[self textFieldDelegates] objectForKey:textField] textFieldShouldEndEditing:textField];
    }
    
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([[self textFieldDelegates] objectForKey:textField]
        && [[[self textFieldDelegates] objectForKey:textField] respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        return [[[self textFieldDelegates] objectForKey:textField] textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField {
    if ([[self textFieldDelegates] objectForKey:textField]
        && [[[self textFieldDelegates] objectForKey:textField] respondsToSelector:@selector(textFieldShouldClear:)]) {
        return [[[self textFieldDelegates] objectForKey:textField] textFieldShouldClear:textField];
    }
    
    return YES;
}

@end

#endif

