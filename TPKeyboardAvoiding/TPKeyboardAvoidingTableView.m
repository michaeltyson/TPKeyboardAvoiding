//
//  TPKeyboardAvoidingTableView.m
//  TPKeyboardAvoiding
//
//  Created by Michael Tyson on 30/09/2013.
//  Copyright 2015 A Tasty Pixel. All rights reserved.
//

#import "TPKeyboardAvoidingTableView.h"

@interface TPKeyboardAvoidingTableView () <UITextFieldDelegate, UITextViewDelegate>
@end

@implementation TPKeyboardAvoidingTableView

#pragma mark - Setup/Teardown

- (void)setup {
    if ( [self hasAutomaticKeyboardAvoidingBehaviour] ) return;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TPKeyboardAvoiding_keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TPKeyboardAvoiding_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToActiveTextField) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToActiveTextField) name:UITextFieldTextDidBeginEditingNotification object:nil];
}

-(id)initWithFrame:(CGRect)frame {
    if ( !(self = [super initWithFrame:frame]) ) return nil;
    [self setup];
    return self;
}

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)withStyle {
    if ( !(self = [super initWithFrame:frame style:withStyle]) ) return nil;
    [self setup];
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
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
	
	if(self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
		return [self.textFieldDelegate textFieldShouldReturn:textField];
	}
	
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
	if(self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
		[self.textFieldDelegate textFieldDidBeginEditing:textField];
	}
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	if(self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
		[self.textFieldDelegate textFieldDidEndEditing:textField];
	}
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if(self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
		return [self.textFieldDelegate textFieldShouldBeginEditing:textField];
	}
	
	return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	if(self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
		return [self.textFieldDelegate textFieldShouldEndEditing:textField];
	}
	
	return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if(self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
		return [self.textFieldDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
	}
	
	return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField {
	if(self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textFieldShouldClear:)]) {
		return [self.textFieldDelegate textFieldShouldClear:textField];
	}
	
	return YES;
}

#pragma mark - UITextView delegate methods

-(void)textViewDidBeginEditing:(UITextView *)textView {
	if(self.textViewDelegate && [self.textViewDelegate respondsToSelector:@selector(textViewDidBeginEditing:)]) {
		[self.textViewDelegate textViewDidBeginEditing:textView];
	}
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	if(self.textViewDelegate && [self.textViewDelegate respondsToSelector:@selector(textViewShouldEndEditing:)]) {
		return [self.textViewDelegate textViewShouldEndEditing:textView];
	}
	
	return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	if(self.textViewDelegate && [self.textViewDelegate respondsToSelector:@selector(textViewDidEndEditing:)]) {
		return [self.textViewDelegate textViewDidEndEditing:textView];
	}
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	if(self.textViewDelegate && [self.textViewDelegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
		return [self.textViewDelegate textView:textView shouldChangeTextInRange:range replacementText:text];
	}
	
	return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
	if(self.textViewDelegate && [self.textViewDelegate respondsToSelector:@selector(textViewDidChange:)]) {
		return [self.textViewDelegate textViewDidChange:textView];
	}
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
	if(self.textViewDelegate && [self.textViewDelegate respondsToSelector:@selector(textViewDidChangeSelection:)]) {
		return [self.textViewDelegate textViewDidChangeSelection:textView];
	}
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
	if(self.textViewDelegate && [self.textViewDelegate respondsToSelector:@selector(textView:shouldInteractWithURL:inRange:)]) {
		return [self.textViewDelegate textView:textView shouldInteractWithURL:URL inRange:characterRange];
	}
	return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
	if(self.textViewDelegate && [self.textViewDelegate respondsToSelector:@selector(textView:shouldInteractWithTextAttachment:inRange:)]) {
		return [self.textViewDelegate textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange];
	}
	
	return YES;
}

@end
