//
//  TPKATableViewController.m
//  TPKeyboardAvoidingSample
//
//  Created by Michael Tyson on 26/06/2015.
//  Copyright (c) 2015 A Tasty Pixel. All rights reserved.
//

#import "TPKATableViewController.h"

@implementation TPKATableViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        cell.accessoryView = textField;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Label %d", (int)indexPath.row];
    ((UITextField*)cell.accessoryView).placeholder = [NSString stringWithFormat:@"Field %d", (int)indexPath.row];
    
    return cell;
}

@end
