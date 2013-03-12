//
//  FirstViewController.h
//  TPKeyboardAvoidingSample
//
//  Created by Michael Tyson on 14/04/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPKeyboardAvoidingScrollView;

@interface FirstViewController : UIViewController
@property (nonatomic, retain) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@end
