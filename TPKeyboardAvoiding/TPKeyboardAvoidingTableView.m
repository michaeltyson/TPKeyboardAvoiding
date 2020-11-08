//
//  TPKeyboardAvoidingTableView.m
//  TPKeyboardAvoiding
//
//  Created by Michael Tyson on 30/09/2013.
//  Copyright 2015 A Tasty Pixel. All rights reserved.
//

#import "TPKeyboardAvoidingTableView.h"

#if ! TARGET_OS_TV

@interface TPKeyboardAvoidingTableView () <UITextFieldDelegate, UITextViewDelegate>
@end

@implementation TPKeyboardAvoidingTableView

#pragma mark - Setup/Teardown

- (void)setupKeyboardAvoiding {
    if ( [self hasAutomaticKeyboardAvoidingBehaviour] ) return;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TPKeyboardAvoiding_keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TPKeyboardAvoiding_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToActiveTextField) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToActiveTextField) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToNextTextField) name:TPKeyboardAvoidingActionNextTextField object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToPrevTextField) name:TPKeyboardAvoidingActionPrevTextField object:nil];
}

-(id)initWithFrame:(CGRect)frame {
    if ( !(self = [super initWithFrame:frame]) ) return nil;
    [self setupKeyboardAvoiding];
    return self;
}

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)withStyle {
    if ( !(self = [super initWithFrame:frame style:withStyle]) ) return nil;
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

-(BOOL)hasAutomaticKeyboardAvoidingBehaviour {
    if ( [self.delegate isKindOfClass:[UITableViewController class]] ) {
        // Theory: Apps built using the iOS 8.3 SDK (probably: older SDKs not tested) seem to handle keyboard
        // avoiding automatically with UITableViewController. This doesn't seem to be documented anywhere
        // by Apple, so results obtained only empirically.
        return YES;
    }

    return NO;
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if ( [self hasAutomaticKeyboardAvoidingBehaviour] ) return;
    [self TPKeyboardAvoiding_updateContentInset];
}

-(void)setContentSize:(CGSize)contentSize {
    if ( [self hasAutomaticKeyboardAvoidingBehaviour] ) {
        [super setContentSize:contentSize];
        return;
    }
	if (CGSizeEqualToSize(contentSize, self.contentSize)) {
		// Prevent triggering contentSize when it's already the same
		// this cause table view to scroll to top on contentInset changes
		return;
	}
    [super setContentSize:contentSize];
    [self TPKeyboardAvoiding_updateContentInset];
}

- (BOOL)focusNextTextField {
    return [self TPKeyboardAvoiding_focusNextTextField];
}

- (BOOL)focusPrevTextField {
    return [self TPKeyboardAvoiding_focusPrevTextField];
}

- (void)scrollToActiveTextField {
    return [self TPKeyboardAvoiding_scrollToActiveTextField];
}

#pragma mark - Responders, events

-(void) goToNextTextField {
    [self focusNextTextField];
}

-(void) goToPrevTextField {
    [self focusPrevTextField];
}

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

