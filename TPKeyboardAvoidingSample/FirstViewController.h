//
//  FirstViewController.h
//  TPKeyboardAvoidingSample
//
//  Created by Michael Tyson on 14/04/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPKeyboardAvoidingScrollView;

@interface FirstViewController : UIViewController <UITextFieldDelegate> {

    TPKeyboardAvoidingScrollView *scrollView;
    UITextField *txtIggle;
    UITextField *txtNiggle;
    UITextField *txtOggle;
    UITextField *txtBogle;
    UITextField *txtSplat;
}
@property (nonatomic, retain) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UITextField *txtIggle;
@property (nonatomic, retain) IBOutlet UITextField *txtNiggle;
@property (nonatomic, retain) IBOutlet UITextField *txtOggle;
@property (nonatomic, retain) IBOutlet UITextField *txtBogle;
@property (nonatomic, retain) IBOutlet UITextField *txtSplat;

@end
