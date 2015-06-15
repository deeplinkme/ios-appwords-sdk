<p align="center">
<img src="/deeplink-appwords.png" width="220"/>
</p>

<h1 align="center">AppWords</h1>


<p align="center">
<a href="https://travis-ci.org/Amit Attias/AppWords"><img src="http://img.shields.io/travis/Amit Attias/AppWords.svg?style=flat" alt="CI Status" />
<a href="http://cocoadocs.org/docsets/AppWords"><img src="https://img.shields.io/cocoapods/v/AppWords.svg?style=flat" alt="Version" />
<a href="http://cocoadocs.org/docsets/AppWords"><img src="https://img.shields.io/cocoapods/l/AppWords.svg?style=flat" alt="License" />
<a href="http://cocoadocs.org/docsets/AppWords"><img src="https://img.shields.io/cocoapods/p/AppWords.svg?style=flat" alt="Platform" />
</p>
<br>

## SDK Components (included with this SDK):

* *AppWordsSDK.framework*

The *AppWordsSDKExample* app is also available from our *git* repository; feel free to use the source files as a basis for your own SDK integration.

## Integration Steps

When installing via CocoaPods, just add this line to your Podfile:

        pod "AppWords"

When manually installing the framework:

* Add the *AppWordsSDK.framework* file to your project (the *Copy items if needed* box needs to be checked).

* Make sure you add *AdSupport.framework* and *SystemConfiguration.framework* to your Project Target’s *Linked Frameworks and Libraries* section in *General* (or to its *Link Binary with Libraries* section in *Build Phases*).

## Using the AppWords SDK in your app

### *0) Header file*

To access the SDK from your code, you will need to import the SDK header file:

```objc
#import <AppWordsSDK/AppWordsSDK.h>
```

### *1) Initializing*

Before retrieving deeplinks, the SDK needs to scan your device for Deeplink AppWords apps. This happens off the main thread, and should consume negligible resources. You may wish call this method in your App Delegate’s *application:didFinishLaunchingWithOptions:* method.

```objc
[[AppWordsSDK sharedInstance] initializeWithApiKey:@"API_KEY"
                                        andAppID:@"APP_ID"
                                        completion:^(NSError *error) {
    if (error == nil) {
        NSLog(@"AppWords initialized");
    }
    else {
        NSLog(@"AppWords init failed: %@", [AppWordsSDK descriptionForError: error]);
    }
}];
```

Notes:

* The completion handler will be called on the main thread.

* The `API_KEY` is the unique developer ID, assigned to you on registering for a Deeplink account. The `APP_ID` is the unique app ID, assigned to the app on creating a new one.

* Note: `API_KEY` and `APP_ID` are not checked by this method – just cached for future use.

* The SDK status can always be checked by way of the isInitialized property.

### *2) Getting a deeplink*

Just call the `getLinkWithKeywords:completion:` method.

The completion handler will always be called on the main thread.

The completion handler will receive `error` & `deeplink` parameters, only one of which will be non-`nil`.
 
The `deeplink` is a `DLMELink` object that encapsulates information for displaying and following the link. To follow the `deeplink`, call the method `open:`

```objc
[[AppWordsSDK sharedInstance] getLinkWithKeywords:self.keywordsTextField.text
                                       completion:^(NSError *error, DLMELink *deeplink) {
    if (! error) {
        [deeplink open:(^(BOOL succeeded) {
            if (succeeded) {
                NSLog(@"Opened deeplink: %@", deeplink.title);
            }
        })];
    }
}];
```

#### Using the `keywords` parameter:

The keywords parameter is a space-separated list of terms.

Anything inside double quotation marks loses any special meaning, and is considered part of its surrounding term; the double quotation marks are then discarded.

Each term can be a pure search string or a specialized search command.
    
Search strings can either be single words, or multi-word phrases (delimited by double quotation marks).
    
Search commands consist of command prefixes followed by the command parameter(s) (no space in between).
Here is a brief summary of current prefixes, commands, and valid parameters:
    
| Prefixes | Command |
| -------- | ------- |
| **category:** | Category search  | 
| **#**         | Category search  | 
| **location:** | Location search  |
| *@*  	        | Location search  |
| **host:**     | Host search      |
        
Be sure to quote any `:`, `#`, `@` that is *not* part of a command prefix.

##### **Category search:** 

This restricts results to the category specified in the parameter. The parameter can be one of Apple's iTunes App Store categories, exactly as spelled by Apple including spaces.
You will need to quote any parameter containing spaces.

You may also use one of the following special categories:
         
| Parameter | Description | Example |
| --------- | ----------- | ------- |
| **product** | Buy a physical product  | `"cowboy hat" #product` *[purchase a cowboy hat]* |
| **service** | Subscribe or pay for some service *or* non-physical product | `category:service shrimp "new york"` *[venues serving shrimp in New York]* |
| **ticket**  | Purchase tickets to events/performances/movies  |  `circus category:ticket "Los Angeles"` *[circus tickets in LA]* |
| **taxi**    | Hire a taxi | `#taxi` *[order a taxi]* |

Put double quotation marks around any space-separated words you want to search for as a phrase;
in fact, anything in between double quotation marks will be considered as a unit, and any other contained character will not be considered special.

##### **Location search:**

This restricts results to physical place situated within 1km of the coordinates specified in the parameter.
The parameter must be of the form `latitude,longitude`, specified as signed, floating-point decimal numbers.

e.g. `#service steakhouse @37.7952852,-122.4022904` *[steakhouse within 1 kilometre of the Transamerica Pyramid, San Francisco]*

##### **Host search:**

This restricts results to apps which correspond to a specific website domain. The parameter is a hostname (any `www.` prefix will be stripped off).

e.g. `iPhone cases host:etsy.com` *[iPhone cases on Etsy]*

### *3) Handle your app being opened from a deeplink*

Your app will need to register a custom URL Scheme before it can receive incoming deeplinks. Please see our [Deeplinkme documentation](https://portal.deeplink.me/documentation/schemes-url-handling) for details.

For tracking purposes, your app must call `handleOpenURL:apiKey:` in your App Delegate, either in  `application:handleOpenURL:` or in `application:openURL:sourceApplication:annotation:`

```objc
[AppWordsSDK handleOpenURL:url apiKey:@"API_KEY"];
```

The `API_KEY` is the unique developer ID, assigned to you on registering for a Deeplink account.

Note that the SDK need not be initialized before calling this method.

## FAQ

**Q: What errors are returned by the SDK?**

A: The SDK uses `NSError` instances to report errors. Every `NSError` instance returned by the SDK uses the private `DLMEErrorDomain` domain. The specific error is indicated by the `DLMEError` value, available via the `code` method; more detailed information is sometimes available via the `localizedDescription` method. You may use the SDK’s `descriptionForError:` class method to pretty-print this error.

**Q: The SDK takes a long time to initialize; is something wrong?**

A: Before retrieving deeplinks the SDK needs to scan your device for Deeplink AppWords apps. This can take time, especially since the SDK does this happens *off* the main thread at a low priority.

It may also be the case that your device is not connected to the internet. The SDK handles this scenario intelligently by waiting until there is a connection, rather than immediately failing. You will see any connection errors logged in the XCode debug console.

**Q: I am not getting any deeplinks when testing in the simulator**

A: The SDK will link with your app for the simulator, but is hardwired to succeed initialization and fail to retrieve any deeplinks. However, the SDK *will* correctly strip AppWords tokens from a URL passed to `handleOpenURL:apiKey:`

**Q:  I am not getting any deeplinks when testing on a device**

A: The SDK only returns deeplinks to installed apps and, even then, only to those apps for which are in the AppWords network. A good app to install for testing purposes is TripAdvisor or, alternatively, Booking.com

Another way to test the connection to the server is using the *AppWordsSDKExample* app, available from our *git* repository:

* Build and install the *AppWordsSDKExample* app on the device.

* Call `getLinkWithKeywords:completion:` from your app, using **appwordssdkexample** (exactly as written, no spaces) as the `keywords` parameter. If the SDK can communicate with the server, then the server should return a `DLMELink` object.

* Call `open` on the returned `DLMELink` object. This should launch the *AppWordsSDKExample* app.

The *AppWordsSDKExample* app registers the Custom URL Scheme `AppWordsSDKExample` to enable this magic to happen.

**Q:  HELP!!! I am STILL not getting any deeplinks even when testing on a device!**

A: The SDK respects the *Limit Ad Targeting* setting on the device by not sending any data to Deeplink.me. This means that no deeplinks are currently sent to the device. Please ensure that *Limit Ad Targeting* is turned off on your test device.

**Please be in touch if you have any additional questions!**

**[itamar@deeplink.me](mailto:itamar@deeplink.me)**

**[noah@deeplink.me](mailto:noah@deeplink.me)**

**[hey@deeplink.me](mailto:hey@deeplink.me)**
