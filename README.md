CloudKit Test
=============

This is an implementation of CloudKit exploring the convenience methods,
like save and fetch, record id and subscriptions.

To make it work, you should have an paid subscription of Apple's iOS developer
program, iOS 8 betas installed and Xcode 6. It will not fully work on the simulators
since they don't support push notifications.

## Just follow the steps.

CloudKit Setup (client side)
1. Clone and open this repository with XCode 6.
2. Change the bundle name, usually with you own reverse domain.
3. Change your team settings for the project, usually with your own certificate.
4. On the Capabilities tab, turn off and on the switch for iCloud, checking the CloudKit service box. It should look like the image below.

![Cloud Kit Client Side Setup](https://raw.github.com/ghvillasboas/CloudKitTest/master/images/cloudkit1.png)

5. XCode should be able to to all this setup and provisioning for you. If not, login the Certificates, Identifiers & Profiles on the DevPortal and create a new AppID with the iCloud application services enabled.

CloudKit Setup (server side)
1. Login to the CloudKit Dashboard (https://icloud.developer.apple.com/dashboard)
2. Create Record Types (left column) and add a new record by clicking the "+" button.
3. Enter "Heros" as the new record type.
4. Add a new attribute named "name" and type String. It should look like the image below.

![Cloud Kit Server Side Setup](https://raw.github.com/ghvillasboas/CloudKitTest/master/images/cloudkit2.png)

Enable Push Notification
1. In order to make CloudKit subscriptions work, you have to enable push notification provisioning on your app.
2. Login to the Certificates, Identifiers & Profiles on the DevPortal, click on AppIDs and locate your app (it should be created by XCode).
3. Enable Push notifications. To enable it you should create at least the developement certificate. Just follow the instructions on screen.

If you don't enable push notifications, you should not be able to receive pushes from CloudKit.

# Side notes

- On versions prior to beta 3, subscriptions wasn't functional
- On beta 3, it was funcional but you should get an error message when subscribing to notifications, like the one below:

  2014-07-08 12:24:53.655 CloudKitTest[455:92919] SUBSCRIPTION ERROR! <CKError 0x15629430: "Server Rejected Request" (15/2032); "Error saving record subscription with id 4B8AE952-B571-441A-8E69-BB4D9B8EA4EF to server: (null)"; uuid = 128A9D96-C75E-441A-ADDB-C2E205C66360; container ID = "iCloud.br.com.cocoaheads.CloudKitTest">

You can ignore it for now. I got CK notifications working even though with this error.
If you wish to duplicate this radar to Apple, here's one I'd opened:
http://openradar.appspot.com/radar?id=6172661096906752

- It's cool to test this app on more then one device. You should see records appearing on both a little while after saving them.

- This example was builded and tested with iOS and Xcode 6 both in beta 3.

## Questions?

Just fire an Issue or give me a pull request.

Enjoy!
