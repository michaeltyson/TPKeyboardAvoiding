//
//  TPKeyboardAvoidingCollectionView.m
//  TPKeyboardAvoiding
//
//  Created by Michael Tyson on 30/09/2013.
//  Copyright 2015 A Tasty Pixel & The CocoaBots. All rights reserved.
//

#import "TPKeyboardAvoidingCollectionView.h"

#if ! TARGET_OS_TV

@interface TPKeyboardAvoidingCollectionView () <UITextFieldDelegate, UITextViewDelegate>
@end

@implementation TPKeyboardAvoidingCollectionView

#pragma mark - Setup/Teardown

- (void)setupKeyboardAvoiding {
    if ( [self hasAutomaticKeyboardAvoidingBehaviour] ) return;
    
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

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if ( !(self = [super initWithFrame:frame collectionViewLayout:layout]) ) return nil;
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
    if ( [[[UIDevice currentDevice] systemVersion] integerValue] >= 9
            && [self.delegate isKindOfClass:[UICollectionViewController class]] ) {
        // Theory: It looks like iOS 9's collection views automatically avoid the keyboard. As usual
        // Apple have totally failed to document this anywhere, so this is just a guess.
        return YES;
    }
    
    return NO;
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self TPKeyboardAvoiding_updateContentInset];
}

-(void)setContentSize:(CGSize)contentSize {
    if (CGSizeEqualToSize(contentSize, self.contentSize)) {
        // Prevent triggering contentSize when it's already the same that
        // cause weird infinte scrolling and locking bug
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ( ![self focusNextTextField] ) {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(TPKeyboardAvoiding_assignTextDelegateForViewsBeneathView:) object:self];
    [self performSelector:@selector(TPKeyboardAvoiding_assignTextDelegateForViewsBeneathView:) withObject:self afterDelay:0.1];
}

@end

#endif

