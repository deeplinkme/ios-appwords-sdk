//
//  AppWordsSDK.h
//  AppWordsSDK
//
//  Created by Amit Attias on 2/2/15.
//  Copyright (c) 2015 Deeplink. All rights reserved.
//

#import <Foundation/Foundation.h>

    /**
     * `NSError` domain for the Deeplinkme SDK.
     *
     * @description All `NSError` instances returned from the SDK are in this domain.
     */
extern NSString *const DLMEErrorDomain;

    /**
     * Deeplinkme `NSError` error codes.
     *
     * @description All `NSError` instances returned from the SDK use codes from this enumeration.
     */
typedef enum : NSUInteger {
        /// No Error
    DLMEErrorNone = 0,
        /// Error not known to the Deeplinkme SDK.
    DLMEErrorUnknownError,
        /// One or more of the parameters passed to the API is invalid.
    DLMEErrorBadParameters,
        /// User has enabled limited ad tracking.
    DLMEErrorLimitedAdTracking,
        /// The user has not installed any Marketplace apps.
    DLMEErrorNoMarketplaceAppsInstalled,
        /// AppWordsSDK initialization has not yet completed successfully.
    DLMEErrorNotInitalized,
        /// The Deeplinkme SDK is busy handling a prior request.
    DLMEErrorBusy,
        /// Problem communicating with the Deeplinkme server.
    DLMEErrorUnableToCommunicateWithServer,
        /// Nothing to return that matches the request.
    DLMEErrorNotFound,
} DLMEError;

    /**
     * A DLMELink encapsulates an AppWordsSDK deeplink.
     * @discussion Returned in the completion handler of `getLinkWithKeywords:completion:`
     */
@interface DLMELink : NSObject

    /// Title of a page in a Marketplace app.
@property (nonatomic, readonly) NSString *title;
    /// Description text of a page in a Marketplace app.
@property (nonatomic, readonly) NSString *text;
    /// url host of a page in a Marketplace app’s website.
@property (nonatomic, readonly) NSString *host;

    /**
     * Asynchronously open the deeplink in the target app.
     * @param completionHandler The block to be called on completion, successful or otherwise, of the method. Can be nil.
     * @discussion If successful, the user will now be in the target app.
     * @note The completion block is always called on the main thread.
     */
-(void)open:(void(^)(BOOL succeeded))completionHandler;

@end

    /**
     * AppWordsSDK provides access to the Deeplinkme Marketplace.
     * @discussion Use `+sharedInstance` to obtain the singleton.
     */
@interface AppWordsSDK : NSObject

    /**
     * Handles tracking and stripping tracking information from incoming Marketplace deeplinks
     *
     * @param url       The URL passed to the `UIAppDelegate` subclass, representing an incoming deeplink.
     * @param apiKey    The unique developer ID, assigned to you on registering for a Deeplinkme account.
     * @return The input URL stripped of any Marketplace tracking information, if any was found. Otherwise,
     * the original URL is returned.
     * @discussion  When your app is opened through a deeplink, one of `application:handleOpenURL:` or the
     * preferable `application:openURL:sourceApplication:annotation:` is called, passing in the deeplink
     * as a URL.
     *
     * Before handling the URL, call this method to ensure accurate tracking of incoming deeplinks.
     *
     * Replace the original URL with the return value for a clean URL stripped of Marketplace tracking information.
     */
+(NSURL *)handleOpenURL:(NSURL *)url apiKey:(NSString *)apiKey;

    /**
     * Returns the AppWordsSDK singleton.
     */
+(AppWordsSDK *)sharedInstance;

    /**
     * Returns the DLMEError description for an error.
     *
     * @param error     The error to pretty-print
     * @return  The custom error description for an error in the `DLMEErrorDomain` error domain. Otherwise, the standard `NSError#description` is returned.
     */
+(NSString *)descriptionForError:(NSError *)error;

    /// `YES` if AppWordsSDK initialization has completed successfully.
@property (nonatomic, readonly) BOOL isInitialized;

    /**
     * Initializes the AppWordsSDK singleton.
     *
     * @param apiKey        The unique developer ID, assigned to you on registering for a Deeplinkme account.
     * @param appID         The unique app ID, assigned to the app by Deeplinkme on creation in the portal.
     * @param completion    The block to be called on initialization completion, successful or otherwise.
     * @discussion  Initialization involves scaning your device for installed Marketplace apps.
     *
     * An `NSError` object describes the reason for failure, if any; a nil error signifies success.
     *
     * @note The completion block is always called on the main thread.
     * @warning Do not call `getLinkWithKeywords:completion:` before initialization is successfully completed.
     */
-(void)initializeWithApiKey:(NSString *)apiKey andAppID:(NSString *)appID completion:(void(^)(NSError *error))completionHandler;

    /**
     * Asynchronously fetch a deeplink to an installed Marketplace app.
     *
     * @param keywords          A space-separated list of keywords for filtering the search.
     * @param completionHandler The block to be called on completion, successful or otherwise, of the method.
     * @discussion  If successful, the deeplink information is returned encapsulated in a DLMELink object.
     *
     * Otherwise, an `NSError` object describes the reason for failure.
     * @note The completion block is always called on the main thread.
     */
-(void)getLinkWithKeywords:(NSString *)keywords completion:(void(^)(NSError *error, DLMELink *deeplink))completionHandler;

@end
