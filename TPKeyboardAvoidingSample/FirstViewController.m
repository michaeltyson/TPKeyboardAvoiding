//
//  FirstViewController.m
//  TPKeyboardAvoidingSample
//
//  Created by Michael Tyson on 14/04/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//

#import "FirstViewController.h"
#import "TPKeyboardAvoidingScrollView.h"

@implementation FirstViewController
@synthesize scrollView;
@synthesize txtIggle;
@synthesize txtNiggle;
@synthesize txtOggle;
@synthesize txtBogle;
@synthesize txtSplat;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Calculate content size given contents
    CGRect contentRect = CGRectZero;
    for ( UIView *subview in self.scrollView.subviews ) {
        contentRect = CGRectUnion(contentRect, subview.frame);
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, CGRectGetMaxY(contentRect)+10);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setTxtIggle:nil];
    [self setTxtNiggle:nil];
    [self setTxtOggle:nil];
    [self setTxtBogle:nil];
    [self setTxtSplat:nil];
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [scrollView release];
    [txtIggle release];
    [txtNiggle release];
    [txtOggle release];
    [txtBogle release];
    [txtSplat release];
    [super dealloc];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == txtIggle) {
        [txtNiggle becomeFirstResponder];
    }
    
    else if (textField == txtNiggle) {
        [txtOggle becomeFirstResponder];
    }
    
    else if (textField == txtOggle) {
        [txtBogle becomeFirstResponder];
    }
    
    else if (textField == txtBogle) {
        [txtSplat becomeFirstResponder];
    }
    else{
        [textField resignFirstResponder];
    }
    
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [scrollView adjustOffsetToIdealIfNeeded];
}

@end
