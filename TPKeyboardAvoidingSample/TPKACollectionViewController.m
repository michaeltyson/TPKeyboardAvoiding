//
//  TPKACollectionViewController.m
//  TPKeyboardAvoidingSample
//
//  Created by Michael Tyson on 26/06/2015.
//  Copyright (c) 2015 A Tasty Pixel. All rights reserved.
//

#import "TPKACollectionViewController.h"

@implementation TPKACollectionViewController

static NSString * const reuseIdentifier = @"Cell";

#pragma mark Collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 30;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TPKACollectionViewControllerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.label.text = [NSString stringWithFormat:@"Label %d", (int)indexPath.row];
    cell.textField.placeholder = [NSString stringWithFormat:@"Field %d", (int)indexPath.row];
    
    return cell;
}

@end

@implementation TPKACollectionViewControllerCell
@end
