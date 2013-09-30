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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [self.scrollView contentSizeToFit];
    [super viewDidLoad];
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
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [scrollView release];
    [super dealloc];
}

@end
