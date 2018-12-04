# Nearby Messages

Allow your users to find nearby devices and share messages in a way that’s as
frictionless as a conversation. This enables rich interactions such as as
collaborative editing, forming a group, voting, or broadcasting a resource.

The Nearby Messages API is available for Android and iOS, allowing for
seamless cross-platform experiences.

## Usage

See the complete documentation on the [Nearby developer site]
(https://developers.google.com/nearby/messages/ios/get-started).

### Creating a Message Manager

This code creates a message manager object, which lets you publish and
subscribe.  Message exchange is unauthenticated, so you will need to supply a
public API key for iOS.  You can create one using the [developer console]
(https://console.developers.google.com/) entry for your project.

```objective-c
#import <GNSMessages.h>

GNSMessageManager *messageManager =
    [[GNSMessageManager alloc] initWithAPIKey:kMyAPIKey];
```

### Publishing a Message

This code snippet demonstrates publishing a message containing a name.
The publication is active as long as the publication object exists. To stop
publishing, release the publication object.

```objective-c
id<GNSPublication> publication =
    [messageManager publicationWithMessage:[GNSMessage messageWithContent:[name dataUsingEncoding:NSUTF8StringEncoding]]];
```

### Subscribing for Messages

This code snippet demonstrates subscribing to all names shared by the
previous publication snippet. The subscription is active as long as the
subscription objects exists. To stop subscribing, release the subscription
object.

The message found handler is called when nearby devices that are publishing
messages are discovered. The message lost handler is called when a message is no
longer observed (the device has gone out of range or is no longer publishing the
message).

```objective-c
id<GNSSubscription> subscription =
    [messageManager subscriptionWithMessageFoundHandler:^(GNSMessage *message) {
      // Add the name to a list for display
    }
    messageLostHandler:^(GNSMessage *message) {
      // Remove the name from the list
    }];
```

### Controlling the Mediums used for Discovery

By default, both mediums (audio and Bluetooth) will be used to discover nearby
devices, and both mediums will broadcast and scan.  For certain cases, you are
required to add the following entries to your app's `Info.plist`:

* If your app scans using audio, add `NSMicrophoneUsageDescription`, which is a
  string describing why you will be using the microphone.  For example, "The
  microphone listens for anonymous tokens from nearby devices."

* If your app broadcasts using BLE, add
  `NSBluetoothPeripheralUsageDescription`, which is a string describing why you
  will be advertising on BLE.  For example, "An anonymous token is advertised
  via Bluetooth to discover nearby devices."

In some cases, your app may need to use only one of the mediums, and it
may not need to do both broadcasting and scanning on that medium.

For instance, an app that is designed to connect to a set-top box that's
broadcasting on audio only needs to scan on audio to discover it. The following
snippet shows how to publish a message to that set-top box using only audio
scanning for discovery:

```objective-c
id<GNSPublication> publication = [messageManager publicationWithMessage:message
    paramsBlock:^(GNSPublicationParams *params) {
      params.strategy = [GNSStrategy strategyWithParamsBlock:^(GNSStrategyParams *params) {
        params.discoveryMediums = kGNSDiscoveryMediumsAudio;
        params.discoveryMode = kGNSDiscoveryModeScan;
      }];
    }];
```

### Tracking the Nearby permission state

User consent is required to enable device discovery. This is indicated by the
Nearby permission state. On the first call to create a publication or
subscription, the user is presented with a consent dialog. If the user does not
consent, device discovery will not work. In this case, your app should show a
message to remind the user that device discovery is disabled. The permission
state is stored in `NSUserDefaults`.

The following snippet demonstrates subscribing to the permission state.  The
permission state changed handler is called whenever the state changes, and it is
not called the first time until the user has given or denied permission.
Release the permission object to stop subscribing.

```objective-c
GNSPermission *nearbyPermission = [[GNSPermission alloc] initWithChangedHandler:^(BOOL granted) {
  // Update the UI here
}];
```

Your app can provide a way for the user to change the permission state; for
example, by using a toggle switch on a settings page.

Here’s an example of how to get and set the permission state.

```objective-c
BOOL permissionState = [GNSPermission isGranted];
[GNSPermission setGranted:!permissionState];  // toggle the state
```

Note: The app should only set the permission state in response to user input.
Never change the permission state without user consent.

### Tracking user settings that affect Nearby

If the user has denied microphone permission, denied Bluetooth permission, or
has turned Bluetooth off, Nearby will not work as well, or may not work at all.
Your app should show a message in these cases, alerting the user that Nearby’s
operations are being hindered. The following snippet shows how to track the
status of these user settings by passing handlers when creating the message
manager:

```objective-c
GNSMessageManager *messageManager = [[GNSMessageManager alloc]
    initWithAPIKey:kMyAPIKey
       paramsBlock:^(GNSMessageManagerParams *params) {
         params.microphonePermissionErrorHandler = ^(BOOL hasError) {
           // Update the UI for microphone permission
         };
         params.bluetoothPowerErrorHandler = ^(BOOL hasError) {
           // Update the UI for Bluetooth power
         };
         params.bluetoothPermissionErrorHandler = ^(BOOL hasError) {
           // Update the UI for Bluetooth permission
         };
}];
```

### Scanning for Beacons

Your app can subscribe to Bluetooth Low Energy (BLE) [beacon messages]
(https://developers.google.com/beacons/)
using the same mechanism that is used to subscribe to messages published by
other nearby devices.  To subscribe to beacons, set the `deviceTypesToDiscover`
parameter to `kGNSDeviceBLEBeacon` in the subscription parameters.  This code
snippet demonstrates how to do this:

```objective-c
id<GNSSubscription> beaconSubscription = [messageManager
    subscriptionWithMessageFoundHandler:myMessageFoundHandler
                     messageLostHandler:myMessageLostHandler
                            paramsBlock:^(GNSSubscriptionParams *params) {
                              params.deviceTypesToDiscover = kGNSDeviceBLEBeacon;
                            }];
```

For complete documentation of beacon scanning, see the [Nearby developer site]
(https://developers.google.com/nearby/messages/ios/get-beacon-messages).

### Enabling Debug Logging

Debug logging prints significant internal events to the console that can be
useful for tracking down problems that you may encounter when integrating Nearby
Messages into your app.  We will ask for these logs if you contact us for help.

You should enable it before creating a message manager.  This code snippet shows
how to enable debug logging:

```objective-c
[GNSMessageManager setDebugLoggingEnabled:YES];
```

## Installation

[CocoaPods](http://cocoapods.org/) is the recommended installation method.  Add
the following line to your project's Podfile:

```ruby
pod 'NearbyMessages'
```

## License

See the [Nearby](https://developers.google.com/nearby) developer site for license details.
