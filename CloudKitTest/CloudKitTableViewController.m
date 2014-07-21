//
//  CloudKitTableViewController.m
//  CloudKitTest
//
//  Created by George Villasboas on 7/8/14.
//  Copyright (c) 2014 CocoaHeads Brasil. All rights reserved.
//

#import "CloudKitTableViewController.h"
#import <CloudKit/CloudKit.h>
#import "CloudKitParams.h"

@interface CloudKitTableViewController ()
@property (nonatomic, readonly) CKContainer *defaultContainer;
@property (nonatomic, readonly) CKDatabase *publicDatabase;
@property (strong, nonatomic) NSMutableArray *results;
@end

@implementation CloudKitTableViewController

#pragma mark -
#pragma mark Getters overriders

- (CKContainer *)defaultContainer
{
    return [CKContainer defaultContainer];
}

- (CKDatabase *)publicDatabase
{
    return self.defaultContainer.publicCloudDatabase;
}

- (NSMutableArray *)results
{
    if (!_results) {
        _results = [[NSMutableArray alloc] init];
    }
    
    return _results;
}

#pragma mark -
#pragma mark Setters overriders

#pragma mark -
#pragma mark Designated initializers

#pragma mark -
#pragma mark Public methods

#pragma mark -
#pragma mark Private methods

/**
 *  Query cloud kit for initial fetch (thread safe)
 */
- (void)queryCloudKit
{
    CKQuery *query = [[CKQuery alloc] initWithRecordType:GVCloudKitRecordType
                                               predicate:[NSPredicate predicateWithFormat:@"TRUEPREDICATE"]];
    [self.publicDatabase performQuery:query
                         inZoneWithID:nil
                    completionHandler:^(NSArray *results, NSError *error) {
                        
                        if (!error) {
                            
                            // CK convenience methods completion
                            // arent executed on the callers thread.
                            // more info: http://openradar.appspot.com/radar?id=5534800471392256
                            
                            // Update: Apple engineers replied this radar saying this is an
                            // expected behaviour and it's up to us to decide in which thread
                            // to run. I believe it's just extra work and it should always execute
                            // the completion on the thread it was originated.
                            @synchronized(self){
                                self.results = [results mutableCopy];
                                
                                // make sure it executes on main thread
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.tableView reloadData];
                                });
                            }
                            
                        }
                        else{
                            NSLog(@"FETCH ERROR: %@", error);
                        }
                    }];
}

/**
 *  Subscribe to CK pushes on record creations
 */
- (void)subscribeToCloudKitPushes
{
    CKSubscription *subscription = [[CKSubscription alloc]
                                    initWithRecordType:GVCloudKitRecordType predicate:[NSPredicate predicateWithFormat:@"TRUEPREDICATE"] subscriptionID:GVCloudKitSubscriptionId options:CKSubscriptionOptionsFiresOnRecordCreation];
    
    CKNotificationInfo *notificationInfo = [CKNotificationInfo new];
    notificationInfo.alertLocalizationKey = @"LOCAL_NOTIFICATION_KEY";
    subscription.notificationInfo = notificationInfo;
    
    [self.publicDatabase saveSubscription:subscription
                        completionHandler:^(CKSubscription *subscription, NSError *error) {
                            if (error) {
                                // On iOS Beta 3 this always fires an error, but pushes
                                // are recieved! (FIXED ON BETA 4)
                                // more info: http://openradar.appspot.com/radar?id=6172661096906752
                                NSLog(@"SUBSCRIPTION ERROR! %@", error);
                            }
                        }];
}

/**
 *  Plays with the CK discoverability features.
 */
- (void)playWithDiscoverability
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // check for previous user data fetches
    if (![defaults objectForKey:@"firstName"]) {
        [self.defaultContainer fetchUserRecordIDWithCompletionHandler:^(CKRecordID *recordID, NSError *error) {
            if (!error) {
                [self.publicDatabase fetchRecordWithID:recordID completionHandler:^(CKRecord *record, NSError *error2) {
                    if (!error2) {
                        [self.defaultContainer discoverUserInfoWithUserRecordID:recordID completionHandler:^(CKDiscoveredUserInfo *userInfo, NSError *error3) {
                            if (!error3 && ![@"" isEqualToString:userInfo.firstName]) {
                                // save to NSUserDefaults
                                
                                [defaults setObject:userInfo.firstName forKey:@"firstName"];
                                [defaults setObject:userInfo.lastName forKey:@"lastname"];
                                [defaults synchronize];
                                
                                
                                // Makes sure it runs on the main thread!
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    self.title = [NSString stringWithFormat:@"%@'s Heroes", userInfo.firstName];
                                });
                            }
                        }];
                    }
                }];
            }
        }];
    }
    else{
        self.title = [NSString stringWithFormat:@"%@'s Heroes", [defaults objectForKey:@"firstName"]];
    }
}

#pragma mark -
#pragma mark ViewController life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // make first call to CK
    [self queryCloudKit];
    
    // subscribe to notifications, if needed
    [self subscribeToCloudKitPushes];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // play with user's discoverability feature
    // just customizes the navcon title
    [self playWithDiscoverability];
    
    // Always reload the table when it will appear.
    // This is necessary because the device that published new data
    // to CloudKit, doesnt receive the CKNotitication, what makes sense.
    
    // This feature is new on beta 4!
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // When a push from CK arrives, the appdelegate dispatches a notification
    // using the default central. We listen to it and then update the UI.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(update:)
                                                 name:GVCloudKitRecordCreationNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // we're off screen. Unsubscribe.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Overriden methods

#pragma mark -
#pragma mark Storyboards Segues

#pragma mark -
#pragma mark Target/Actions

#pragma mark -
#pragma mark Delegates and Datasources

#pragma mark TableView Datasources

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    if (cell) {
        // Configure the cell...
        CKRecord *record = self.results[indexPath.row];
        cell.textLabel.text = [record objectForKey:@"name"];
    }
    
    return cell;
}

#pragma mark -
#pragma mark Notification center

- (void)update:(NSNotification *)notification
{
    // CK convenience methods completion arent executed on the callers thread.
    // So we make sure its on main thread and thread safe.
    // more info: http://openradar.appspot.com/radar?id=5534800471392256
    
    // Update: Apple engineers replied this radar saying this is an
    // expected behaviour and it's up to us to decide in which thread
    // to run. I believe it's just extra work and it should always execute
    // the completion on the thread it was originated.
    @synchronized(self){
        if ([notification.object isKindOfClass:[CKRecord class]]) {
            [self.results addObject:notification.object];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }
}

@end
