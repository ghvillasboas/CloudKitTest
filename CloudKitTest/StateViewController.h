//
//  StateViewController.h
//  CloudKitTest
//
//  Created by George Villasboas on 7/8/14.
//  Copyright (c) 2014 CocoaHeads Brasil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>
#import "CloudKitParams.h"

@interface StateViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (strong, nonatomic) CKRecord *record;
@end
