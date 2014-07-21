//
//  AppDelegate.m
//  CloudKitTest
//
//  Created by George Villasboas on 7/8/14.
//  Copyright (c) 2014 CocoaHeads Brasil. All rights reserved.
//

#import "AppDelegate.h"
#import <CloudKit/CloudKit.h>
#import "CloudKitParams.h"

@interface AppDelegate ()
@property (readonly, nonatomic) CKContainer *defaultContainer;
@end

@implementation AppDelegate

- (CKContainer *)defaultContainer
{
    return [CKContainer defaultContainer];
}

/**
 *  Check and ask for users permission on discoverability
 */
- (void)checkForCKDiscoverabiltyStatus
{
    // this will display a scary message for the user.
    // I'd opened a radar suggesting tweaks on it, so users can securelly opt-in to it.
    // more info: http://openradar.appspot.com/radar?id=5898405960220672
    [self.defaultContainer statusForApplicationPermission:CKApplicationPermissionUserDiscoverability completionHandler:^(CKApplicationPermissionStatus applicationPermissionStatus, NSError *error) {
        if (!error) {
            if (applicationPermissionStatus != CKApplicationPermissionStatusGranted &&
                applicationPermissionStatus != CKApplicationPermissionStatusDenied) {
                // request authorization.
                [self.defaultContainer requestApplicationPermission:CKApplicationPermissionUserDiscoverability completionHandler:nil];
            }
        }
        else{
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge categories:nil]];
    [application registerForRemoteNotifications];
    
    [self checkForCKDiscoverabiltyStatus];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Remote push notification from CK recieved!");
    
    CKNotification *cloudKitNotification = [CKNotification
                                            notificationFromRemoteNotificationDictionary:userInfo];
    
    if (cloudKitNotification.notificationType == CKNotificationTypeQuery) {
        CKQueryNotification *queryNotification = (CKQueryNotification *)cloudKitNotification;
        CKRecordID *recordID = [queryNotification recordID];
        CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
        
        [publicDatabase fetchRecordWithID:recordID
                        completionHandler:^(CKRecord *fetchedRecord, NSError *error) {
                            if (error) {
                                NSLog(@"ERROR FETCHING: %@", error);
                            }
                            else{
                                if (fetchedRecord) {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:GVCloudKitRecordCreationNotification object:fetchedRecord];
                                }
                            }
                        }];
    }
}

@end
