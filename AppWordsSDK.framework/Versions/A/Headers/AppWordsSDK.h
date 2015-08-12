//
//  AppWordsSDK.h
//  AppWordsSDK
//
//  Created by Amit Attias on 2/2/15.
//  Copyright (c) 2015 Deeplink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSSearchableItem;

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
        /// One or more of the arguments passed to the API is invalid.
    DLMEErrorBadParameters,
        /// User has enabled limited ad tracking.
    DLMEErrorLimitedAdTracking,
        /// The user has not installed any AppWords apps.
    DLMEErrorNoAppWordsAppsInstalled,
        /// AppWordsSDK initialization has not yet completed successfully.
    DLMEErrorNotInitalized,
        /// The Deeplinkme SDK is busy handling a prior request.
    DLMEErrorBusy,
        /// Problem communicating with the Deeplinkme server.
    DLMEErrorUnableToCommunicateWithServer,
        /// Nothing to return that matches the request.
    DLMEErrorNotFound,
        /// The operation requested is not supported.
    DLMEErrorNotSupported,
        /// The SDK is not ready to handle the request.
    DLMEErrorNotReady,
} DLMEError;

    /**
     * A DLMELink encapsulates an AppWordsSDK deeplink.
     * @discussion Returned in the completion handler of `getLinkWithKeywords:completion:`
     */
@interface DLMELink : NSObject

    /// Title of a page in a AppWords app.
@property (nonatomic, readonly) NSString *title;
    /// Description text of a page in a AppWords app.
@property (nonatomic, readonly) NSString *text;
    /// url host of a page in a AppWords app’s website.
@property (nonatomic, readonly) NSString *host;

    /**
     * Asynchronously open the deeplink in the target app.
     *
     * @param completionHandler The block to be called on completion, successful or otherwise, of the asynchronous request. Can be nil.
     * @discussion If successful, the user is now in the target app.
     * @note The completion block is always called on the main thread.
     */
-(void)open:(void(^)(BOOL succeeded))completionHandler;

@end

    /**
     * AppWordsSDK provides access to Deeplinkme AppWords.
     *
     * @discussion Use `+sharedInstance` to obtain the singleton.
     */
@interface AppWordsSDK : NSObject

    /**
     * Handles tracking and stripping tracking information from incoming AppWords deeplinks
     *
     * @param url       The URL passed to the `UIAppDelegate` subclass, representing an incoming deeplink.
     * @param apiKey    The unique developer ID, assigned to you on registering for a Deeplinkme account.
     * @return The input URL stripped of any AppWords tracking information, if any was found. Otherwise,
     * the original URL is returned.
     * @discussion  When your app is opened through a deeplink, one of `application:handleOpenURL:` or the
     * preferable `application:openURL:sourceApplication:annotation:` is called, passing in the deeplink
     * as a URL.
     *
     * Before handling the URL, call this method to ensure accurate tracking of incoming deeplinks.
     *
     * Replace the original URL with the return value for a clean URL stripped of AppWords tracking information.
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
     * @discussion  Initialization involves scaning your device for installed AppWords apps.
     *
     * An `NSError` object describes the reason for failure, if any; a nil error signifies success.
     *
     * @note The completion block is always called on the main thread.
     * @warning Do not call `getLinkWithKeywords:completion:` before initialization is successfully completed.
     */
-(void)initializeWithApiKey:(NSString *)apiKey andAppID:(NSString *)appID completion:(void(^)(NSError *error))completionHandler;

    /**
     * Asynchronously fetch a deeplink to an installed AppWords app.
     *
     * @param keywords          A space-separated list of keywords for filtering the search.
     * @param completionHandler The block to be called on completion, successful or otherwise, of the asynchronous request.
     * @discussion  If successful, the deeplink information is returned encapsulated in a DLMELink object.
     *
     * Otherwise, an `NSError` object describes the reason for failure.
     * @note The completion block is always called on the main thread.
     */
-(void)getLinkWithKeywords:(NSString *)keywords completion:(void(^)(NSError *error, DLMELink *deeplink))completionHandler;

    /**
     * Asynchronously send structured search data, encapsulated in a `CSSearchableItem`, to the AppWords server for indexing.
     *
     * @param item              A `CSSearchableItem` ready to send to Core Spotlight for indexing.
     * @param webpageURL        Webpage to which the user should be sent to if the app were not available to handle user selecting this searchable item. Corresponds to the `webpageURL` property in `NSUserActivity`.
     * @param keywords          An optional set of keywords that can help users find the activity in search results. Corresponds to the `keywords` property in `NSUserActivity`. This argument can be nil.
     * @param imageURL          An optional web address of an image suitable to be displayed with this item in search results. This argument can be nil.
     * @param completionHandler An optional block to be called on completion, successful or otherwise, of the asynchronous request. This argument can be nil.
     * @discussion  Sends elements of the item's `attributeSet`, plus the `webpageURL`, `keywords`,
     * and `imageURL` arguments. See full documentation for details.
     *
     * If successful, `error` is nil. Otherwise, the `NSError` object describes the reason for failure.
     * @note The `webpageURL` is used as a unique identifier, don't use a generic front page for all search items. It must also belong to your host, as declared on the portal.
     * @note The completion block is always called on the main thread.
     * @warning Any contained data might be revealed to other users, so please do not include private user data.

     */
-(void)addPublicallySearchableItem:(CSSearchableItem *)item
                        webpageURL:(NSString *)webpageURL
                          keywords:(NSSet *)keywords
                          imageURL:(NSString *)imageURL
                        completion:(void(^)(NSError *error))completionHandler;

    /**
     * Asynchronously send structured search data, encapsulated in an `NSUserActivity`, to the AppWords server for indexing.
     *
     * @param activity          An `NSUserActivity`, with added attributes for indexing.
     * @param imageURL          An optional web address of an image suitable to be displayed with this item in search results. This argument can be nil.
     * @param completionHandler An optional block to be called on completion, successful or otherwise, of the asynchronous request. This argument can be nil.
     * @discussion  Sends elements of the item's `contentAttributeSet`, the `webpageURL` and
     * `keywords` properties, and the `imageURL` argument. See full documentation for details.
     *
     * If successful, `error` is nil. Otherwise, the `NSError` object describes the reason for failure.
     * @note The `activity` will not be indexed unless it is both `eligibleForSearch`  and `eligibleForPublicIndexing`. Otherwise, the `error` code is set to DLMEErrorNone, with a message of "Not publically searchable".
     * @note The `webpageURL` property is used as a unique identifier, don't use a generic front page for all search items. It must also belong to your host, as declared on the portal.
     * @note The completion block is always called on the main thread.
     * @warning Be aware that marking an `NSUserActivity` as `eligibleForSearch`  and `eligibleForPublicIndexing` means that any contained data might be revealed to other users - by Apple, if not by AppWords - so please do not include private user data.
     */
-(void)addUserActivity:(NSUserActivity *)activity imageURL:(NSString *)imageURL completion:(void(^)(NSError *error))completionHandler;

@end
