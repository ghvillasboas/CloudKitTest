//
//  StateViewController.m
//  CloudKitTest
//
//  Created by George Villasboas on 7/8/14.
//  Copyright (c) 2014 CocoaHeads Brasil. All rights reserved.
//

#import "StateViewController.h"

@interface StateViewController ()

@end

@implementation StateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.textField becomeFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)disableSaveButton
{
    self.saveButton.enabled = NO;
    [self.saveButton setTitle:@"Saving..." forState:UIControlStateNormal];
}

- (void)enableSaveButton
{
    self.saveButton.enabled = YES;
    [self.saveButton setTitle:@"Save to iCloud" forState:UIControlStateNormal];
}

- (IBAction)save:(id)sender
{
    if (![@"" isEqualToString:self.textField.text]) {
        
        // change UI while saving, preventing multiple saves
        [self disableSaveButton];
        
        CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
        CKRecordID *wellKnownID = [[CKRecordID alloc]
                                   initWithRecordName:self.textField.text];
        
        CKRecord *newState = [[CKRecord alloc] initWithRecordType:GVCloudKitRecordType
                                                         recordID:wellKnownID];
        [newState setObject:self.textField.text
                     forKey:@"name"];
        
        [publicDatabase saveRecord:newState
                 completionHandler:^(CKRecord *savedState, NSError *error) {
                     if (error) {
                         NSLog(@"ERROR SAVING: %@", error);
                         [self enableSaveButton];
                     }
                     else{
                         [self performSelectorOnMainThread:@selector(popToList) withObject:nil waitUntilDone:YES];
                     }
                 }];
    }
}

- (void)popToList
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
