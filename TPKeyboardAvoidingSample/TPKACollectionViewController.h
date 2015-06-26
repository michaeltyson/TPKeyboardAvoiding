//
//  TPKACollectionViewController.h
//  TPKeyboardAvoidingSample
//
//  Created by Michael Tyson on 26/06/2015.
//  Copyright (c) 2015 A Tasty Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPKACollectionViewController : UICollectionViewController

@end

@interface TPKACollectionViewControllerCell : UICollectionViewCell
@property (nonatomic, strong) IBOutlet UILabel * label;
@property (nonatomic, strong) IBOutlet UITextField * textField;
@end