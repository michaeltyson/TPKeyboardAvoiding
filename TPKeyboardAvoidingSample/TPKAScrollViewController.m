//
//  TPKAScrollViewController.m
//  TPKeyboardAvoidingSample
//
//  Created by Michael Tyson on 26/06/2015.
//  Copyright (c) 2015 A Tasty Pixel. All rights reserved.
//

#import "TPKAScrollViewController.h"

static const int kRowCount = 40;
static const int kGroupCount = 5;

@interface TPKAScrollViewController ()

@end

@implementation TPKAScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add some text fields in rows
    UIView * priorView = nil;
    for ( int i=0; i<kRowCount; i++ ) {
        UITextField * textField = [[UITextField alloc] initWithFrame:CGRectZero];
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        textField.placeholder = [NSString stringWithFormat:@"Field %d", i];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        [self.scrollView addSubview:textField];
        
        [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:30]];
        
        if ( (i % kGroupCount) < 3 ) {
            UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.text = @"Label";
            [self.scrollView addSubview:label];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:textField attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
            [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeadingMargin multiplier:1 constant:0], [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:80], [NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeTrailing multiplier:1 constant:10], [NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailingMargin multiplier:1 constant:0]]];
        } else {
            [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeadingMargin multiplier:1 constant:0], [NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailingMargin multiplier:1 constant:0]]];
        }
        
        if ( priorView ) {
            [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[priorView]-10-[textField]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(priorView, textField)]];
        } else {
            [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scrollView attribute:NSLayoutAttributeTopMargin multiplier:1 constant:0]];
        }
        
        priorView = textField;
        
        if ( !((i+1) % kGroupCount) && i != kRowCount-1 ) {
            // Add a horizontal line
            UIView * divider = [[UIView alloc] initWithFrame:CGRectZero];
            divider.translatesAutoresizingMaskIntoConstraints = NO;
            divider.backgroundColor = [UIColor lightGrayColor];
            [self.scrollView addSubview:divider];
            
            [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[textField]-10-[divider(==1)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textField, divider)]];
            [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:divider attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeadingMargin multiplier:1 constant:0], [NSLayoutConstraint constraintWithItem:divider attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailingMargin multiplier:1 constant:0]]];
            
            priorView = divider;
        }
    }
    
    // Add a button at the bottom, just for funzies
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTitle:@"Bing" forState:UIControlStateNormal];
    [self.scrollView addSubview:button];
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeadingMargin multiplier:1 constant:0], [NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailingMargin multiplier:1 constant:0]]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[priorView]-20-[button]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(priorView, button)]];
}

@end
