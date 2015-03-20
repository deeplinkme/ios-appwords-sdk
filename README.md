<p align="center"><img src="https://www.dropbox.com/s/1bbfjsxi4qilcec/deeplink-appwordsHIGHREZ.png?dl=0" width="204"/></p>

<h1 align="center">AppWords</h1>


<p align="center">
<a href="https://travis-ci.org/Amit Attias/AppWords"><img src="http://img.shields.io/travis/Amit Attias/AppWords.svg?style=flat" alt="CI Status" />
<a href="http://cocoadocs.org/docsets/AppWords"><img src="https://img.shields.io/cocoapods/v/AppWords.svg?style=flat" alt="Version" />
<a href="http://cocoadocs.org/docsets/AppWords"><img src="https://img.shields.io/cocoapods/l/AppWords.svg?style=flat" alt="License" />
<a href="http://cocoadocs.org/docsets/AppWords"><img src="https://img.shields.io/cocoapods/p/AppWords.svg?style=flat" alt="Platform" />
</p>


## SDK Components (included with this SDK):

* AppWordsSDK.framework


## Integration Steps

* Add the AppWordsSDK.framework file to your project (the *Copy items if needed* box needs to be checked).
* Make sure you add AdSupport.framework to your Project Target’s *Linked Frameworks and Libraries* section in *General* (or to its *Link Binary with Libraries* section in *Build Phases*).


## Using the AppWords SDK in your app

#### 1. Initializing

* Add `#import <AppWordsSDK/AppWordsSDK.h>` to your App Delegate.
Before retrieving deeplinks the SDK needs to scan your device for Deeplink AppWords apps
* This happens off the main thread, and should consume negligible resources. You may wish call this method in your App Delegate’s application:didFinishLaunchingWithOptions: method.

		[[AppWordsSDK sharedInstance] initializeWithApiKey:@"API_key"
			andAppID:@"APP_ID"
			completion:^(NSError *error) {
				if (error == nil) {
					NSLog(@"AppWords initialized");
				}
		}];

* The `API_KEY` is the unique developer ID, assigned to you on registering for a Deeplink account. The `APP_ID` is the unique app ID, assigned to the app on creating a new one.
* Note: `API_KEY` and `APP_ID` are not checked by this method – just cached for future use.
* The SDK status can always be checked by way of the isInitialized property.


#### 2. Getting a deeplink

* Just call the `getLinkWithKeywords:completion:` method. Only one of error & deeplink will be non-nil on completion:
* The deeplink is a DLMELink object that encapsulates the following information:
  * title
  * text
  * host
* To follow the deeplink, call the method open:

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


#### 3. Handle your app being opened from a deeplink

* Your app will need to register a custom URL Scheme before it can receive incoming deeplinks. Please see our [Deeplinkme documentation](http://portal.deeplink.me/documentation/schemes-url-handling) for details.
* For tracking purposes, your app must call `handleOpenURL:apiKey:` in your App Delegate, either in `application:handleOpenURL:` or in `application:openURL:sourceApplication:annotation:`

		[AppWordsSDK handleOpenURL:url apiKey:@"API_key"];

* The `API_KEY` is the unique developer ID, assigned to you on registering for a Deeplink account.
* Note that the SDK need not be initialized before calling this method.


## FAQ

##### Q: What errors are returned by the SDK?

A: The SDK uses *NSError* instances to report errors. Every *NSError* instance returned by the SDK uses the private *DLMEErrorDomain* domain. The specific error is indicated by the *DLMEError* value, available via the code method; more detailed information is sometimes available via the *localizedDescription* method.
Note that the SDK needs to communicate with the AppWords server to provide deeplinks. To prevent errors, you should ensure that the device is connected to the internet before calling the Deeplinkme SDK. 

##### Q: I am not getting any deeplinks when testing in the simulator
A: The SDK will link with your app for the simulator, but is hardwired to succeed initialization and fail to retrieve any deeplinks. However, the SDK *will* correctly strip AppWords tokens from a URL passed to `handleOpenURL:apiKey:`

##### Q: I am not getting any deeplinks when testing on a device
A: The SDK only returns deeplinks to installed apps and, even then, only to those apps for which are in the AppWords network. A good app to install for testing purposes is TripAdvisor or, alternatively, Booking.com

##### Q: HELP!!! I am STILL not getting any deeplinks even when testing on a device!
A: The SDK respects the *Limit Ad Targeting* setting on the device by not sending any data to Deeplink.me. This means that no deeplinks are currently sent to the device. Please ensure that *Limit Ad Targeting* is turned off on your test device.


## Please be in touch if you have any additional questions!  

[itamar@deeplink.me](mailto:itamar@deeplink.me)

[noah@deeplink.me](mailto:noah@deeplink.me)

[hey@deeplink.me](mailto:hey@deeplink.me)