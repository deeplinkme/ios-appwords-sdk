<p align="center">
<img src="/deeplink-appwords.png" width="220"/>
</p>

<h1 align="center">AppWords</h1>

<br>

Acquire and drive intent based traffic into your app, find great deep links to extend your app features.

**!! NEW for iOS 9 !!** Index your *iOS Search API* pages with AppWords, as well as with Apple.

## SDK Components (included with this SDK):

* *AppWordsSDK.framework*
* *(CoreSpotlight.framework)*

The *AppWordsSDKExample* app is also available from our CocoaPods *git* repository; feel free to use the source files as a basis for your own SDK integration.

## Integration Steps

### *CocoaPods*

* Add this line to your Podfile:

        pod "AppWords"

##### N.B. To build using *Xcode 7*, you will need to *delete* our dummy *CoreSpotlight.framework*. This is located (once the pod has been installed) in the *Xcode Project Manager* under the *Pods* project in *Pods»AppWords»Frameworks*

### *Manually install*

* Add the *AppWordsSDK.framework* file to your project (the *Copy items if needed* box needs to be checked).

* Make sure you add *AdSupport.framework* and *SystemConfiguration.framework* to your Project Target’s *Linked Frameworks and Libraries* section in *General* (or to its *Link Binary with Libraries* section in *Build Phases*).

##### N.B. To build using *Xcode* versions *prior* to 7, you  will need to *add* our dummy *CoreSpotlight.framework* to your project (the *Copy items if needed* box needs to be checked).

## Using the AppWords SDK in your app

### *0) Header file*

To access the SDK from your code, you will need to import the SDK header file:

```objc
#import <AppWordsSDK/AppWordsSDK.h>
```

### *1) Initializing*

Before retrieving deeplinks, the SDK needs to scan your device for deeplinkable AppWords apps. This happens off the main thread, and should consume negligible resources. You may wish call this method in your App Delegate’s *application:didFinishLaunchingWithOptions:* method.

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

* `API_KEY` and `APP_ID` are not checked by this method – just cached for future use.

* The SDK status can always be checked by way of the `isInitialized` property.

* **In iOS 9, scanning for apps is restricted to those apps whose scheme is
  declared in your Info.plist file.  To get deeplinks in iOS 9, it is
  essential that you copy the list below and paste it into Info.plist, just
  above the terminating `</dict></plist>`. (You may delete entries for apps that you don't wish to deeplink into.)**

```xml
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>abcnewsiphone</string><!-- ABC News -->
        <string>airbnb</string><!-- Airbnb -->
        <string>birchbox</string><!-- Birchbox -->
        <string>booking</string><!-- Booking.com -->
        <string>sportscenter</string><!-- ESPN -->
        <string>etsy</string><!-- Etsy -->
        <string>expda</string><!-- Expedia -->
        <string>foursquare</string><!-- Foursquare -->
        <string>jackthreads</string><!-- JackThreads -->
        <string>ls</string><!-- LivingSocial -->
        <string>reservetable-com.contextoptional.OpenTable-1</string><!-- OpenTable -->
        <string>pandora</string><!-- Pandora -->
        <string>pinterest</string><!-- Pinterest -->
        <string>poshmark</string><!-- Poshmark -->
        <string>shazam</string><!-- Shazam -->
        <string>soundcloud</string><!-- SoundCloud -->
        <string>stubhub</string><!-- StubHub -->
        <string>com.aol.mobile.techcrunch</string><!-- TechCrunch -->
        <string>threadflip</string><!-- Threadflip -->
        <string>todaytix</string><!-- TodayTix -->
        <string>tripadvisor</string><!-- TripAdvisor -->
        <string>urbanout</string><!-- UrbanOutfitters.com -->
        <string>yelp</string><!-- Yelp -->
        <string>com.yummly.production</string><!-- Yummly -->
        <string>zomato</string><!-- Zomato -->
    </array>
```



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

The `keywords` parameter is a space-separated list of terms.

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

This restricts results to the category specified in the parameter. The parameter can be one of Apple's iTunes App Store categories, exactly as spelled by Apple including spaces. You will need to quote any parameter containing spaces.

You may also use one of the following special categories:

| Category | Description | Example |
| --------- | ----------- | ------- |
| **product** | Buy a physical product  | `"cowboy hat" #product` *[purchase a cowboy hat]* |
| **service** | Subscribe or pay for some service *or* non-physical product | `category:service shrimp "new york"` *[venues serving shrimp in New York]* |
| **hotel** | Venues selling accommodation | `#hotel "San Francisco"` *[hotels in San Francisco]* |
| **restaurant** | Venues selling food | `category:restaurant shrimp "new york"` *[food venues serving shrimp in New York]* |
| **ticket**  | Purchase tickets to events/performances/movies  |  `circus category:ticket "Los Angeles"` *[circus tickets in LA]* |
| **taxi**    | Hire a taxi | `#taxi` *[order a taxi]* |

Put double quotation marks around any space-separated words you want to search for as a phrase; in fact, anything in between double quotation marks will be considered as a unit, and any other contained character will not be considered special.

##### **Location search:**

This restricts results to physical place situated within 1km of the coordinates specified in the parameter.

The parameter must be of the form `latitude,longitude`, specified as signed, floating-point decimal numbers.

e.g. `#restaurant steakhouse @37.7952852,-122.4022904` *[steakhouse within 1 kilometre of the Transamerica Pyramid, San Francisco]*

##### **Host search:**

This restricts results to apps which correspond to a specific website domain. The parameter is a hostname (any `www.` prefix will be stripped off).

e.g. `iPhone cases host:etsy.com` *[iPhone cases on Etsy]*

### *3) Handle your app being opened from a deeplink*

Your app will need to register a custom URL Scheme before it can receive incoming deeplinks. Please see our [Deeplinkme documentation](https://portal.deeplink.me/documentation#documentation-and-support-schemes-and-url-handling) for details.

For tracking purposes, your app must call `handleOpenURL:apiKey:` in your App Delegate, either in  `application:handleOpenURL:` or in `application:openURL:sourceApplication:annotation:`

```objc
[AppWordsSDK handleOpenURL:url apiKey:@"API_KEY"];
```

The `API_KEY` is the unique developer ID, assigned to you on registering for a Deeplink account.

Note that the SDK need not be initialized before calling this method.

### *3) Adding pages to the AppWords index (iOS 9 Only)*

AppWords provides an easy way to leverage Apple's new [iOS Search APIs](https://developer.apple.com/videos/wwdc/2015/?id=709).  After you prepare a `CSSearchableItem` or `NSUserActivity` object, pass it to the appropriate AppWords method for inclusion in our search index.

**N.B.** Any data sent via the following APIs will be publicly searchable and might be revealed to other users, so please do not include private user data. Even though AppWords will only index `NSUserActivity` objects marked as `eligibleForSearch` and `eligibleForPublicIndexing`, understand that any contained data will be treated as public by Apple, as well as by AppWords.

Here is the list of attributes in `CSSearchableItemAttributeSet` that will be indexed by AppWords:

* `title`:  **(required)** title of the page
* `contentDescription`: **(required)** description/summary of the page.
* `displayName`: name of the page, suitable to display in the user interface
* `latitude`, `longitude`: any relevant physical coordinates, e.g. physical location of a restaurant represented by the page
* `contentType`: uniform type identifier (see Apple [documentation](https://developer.apple.com/library/ios/documentation/General/Conceptual/DevPedia-CocoaCore/UniformTypeIdentifier.html))
* `contentTypeTree`: custom hierarchy of uniform type identifiers (see Apple [documentation](https://developer.apple.com/library/ios/documentation/General/Conceptual/DevPedia-CocoaCore/UniformTypeIdentifier.html))
* `relatedUniqueIdentifier`: this should be identical to the
  `uniqueIdentifier` of any  `CSSearchableItem` representing the same page (see below)

Other indexed data will be specified with the appropriate method.

**N.B.** `webpageURL` (see below) must uniquely identify each app page -- do not use a generic homepage url for multiple app pages!  The URL's hostname must *exactly* match the hostname you have declared on the AppWords portal.

#### *NSUserActivity*

Call the `addUserActivity:imageURL:completion:` method.

The (optional) completion handler will always be called on the main thread.

The completion handler `error` parameter  will be non-`nil` if an error occurs.

In addition to the relevant `CSSearchableItemAttributeSet` attributes of `contentAttributeSet` (specified above), AppWords will index the following `NSUserActivity` properties:

* `expirationDate`: date (& time) to expire this page from the index
* `webpageURL`: **(required)** webpage version of this app page; falls back to this page if the app is not installed.
* `keywords`: set of 3 to 5 relevant keywords, including synonyms, abbreviations, and category terms, to associate your results with different queries
* `title`: user-visible title of the page

AppWords will also index the following method parameters:

* `imageURL`: web address of image to be displayed with search results, preferably at least 600px × 600px

#### *CSSearchableItem*

Call the `addPublicallySearchableItem:webpageURL:keywords:imageURL:completion:` method.

The (optional) completion handler will always be called on the main thread.

The completion handler `error` parameter  will be non-`nil` if an error occurs.

In addition to the relevant `CSSearchableItemAttributeSet` attributes of `attributeSet` (specified above), AppWords will index the following `CSSearchableItem` properties:

* `expirationDate`: date (& time) to expire this page from the index
* `uniqueIdentifier`: it is recommended that this should be the same as both the `webpageURL` parameter, and also the `relatedUniqueIdentifier` of any `NSUserActivity` representing the same page

AppWords will also index the following method parameters:

* `webpageURL`:  **(required)** webpage version of this app page; falls back to this page if the app is not installed
* `keywords`: set of 3 to 5 relevant keywords, including synonyms, abbreviations, and category terms, to associate your results with different queries
* `imageURL`: web address of image to be displayed with search results, preferably at least 600px × 600px

## FAQ

**Q: I'm getting strange compiler/linker errors to do with CoreSpotlight**

A: Core Spotlight is a new feature of iOS 9, but is used by this SDK for AppWords indexing. We have included a dummy CoreSpotlight.framework so that projects built using Xcode versions < 7 can link without errors. However, if this dummy framework is present then Xcode 7 may fail to compile/link the project. See [Integration Steps](#integration-steps) to learn how to set up your Xcode Project correctly.

Note that you may have to delete the Pods folder, and perform a new `pod install` when switching Xcode versions.

**Q: What errors are returned by the SDK?**

A: The SDK uses `NSError` instances to report errors. Every `NSError` instance returned by the SDK uses the private `DLMEErrorDomain` domain. The specific error is indicated by the `DLMEError` value, available via the `code` method; more detailed information is sometimes available via the `localizedDescription` method. You may use the SDK’s `descriptionForError:` class method to pretty-print this error.

**Q: The SDK takes a long time to initialize; is something wrong?**

A: Before retrieving deeplinks the SDK needs to scan your device for Deeplink AppWords apps. This can take time, especially since the SDK does this happens *off* the main thread at a low priority.

It may also be the case that your device is not connected to the internet. The SDK handles this scenario intelligently by waiting until there is a connection, rather than immediately failing. You will see any connection errors logged in the Xcode debug console.

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

A: Are you testing on iOS 9? If so, be aware that Apple has changed the rules, and you will need to edit your Info.plist. See [Initializing](#1-initializing) for details.

**Q:  ARRGGHHH! WHERE ARE MY DEEPLINKS ON THE DEVICE????!!!????!!!**

A: The SDK respects the *Limit Ad Targeting* setting on the device by not sending any data to Deeplink.me. This means that no deeplinks are currently sent to the device. Please ensure that *Limit Ad Targeting* is turned off on your test device.

**Please be in touch if you have any additional questions!**

**[itamar@deeplink.me](mailto:itamar@deeplink.me)**

**[noah@deeplink.me](mailto:noah@deeplink.me)**

**[hey@deeplink.me](mailto:hey@deeplink.me)**
