#import <Foundation/Foundation.h>

/**
 Holds an API key to be used by models and collectionss when interacting with Cosm's web services.
 
 You may set a default API key for all models and collection by adding it to the defaultAPI object in your application delegate.
 A new COSMAPI can be added to any model or collection on a case by case basis to override the defaultAPI.

 The following is an example of how you would add the key to the default COSMAPI object in `AppDelegate.h`:
 
     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
         // set the default api
         [[COSMAPI defaultAPI] apiKey:@"<Your Api Key Here>"];
         return YES;
     }
 */

@interface COSMAPI : NSObject

///---------------------------------------------------------------------------------------
/// @name Shared API
///---------------------------------------------------------------------------------------
 
/** The default COSMAPI is used by all models & collections if no other is provided and may be accessed at any point with `[COSMAPI defaultAPI]`. */
+ (COSMAPI *)defaultAPI;

///---------------------------------------------------------------------------------------
/// @name Sync Settings
///---------------------------------------------------------------------------------------

/** An API key to be used when interacting with Cosm's web services. */
@property (nonatomic, strong) NSString *apiKey;
/** The URL string to be used for Cosm's rest services. The default value is http://api.cosm.com/v2 */
@property (nonatomic, strong) NSString *apiURLString;
/** The URL string to be used for Cosm's web socket services. The default value is http://api.cosm.com:8080 */
@property (nonatomic, strong) NSString *socketApiURLString;
/** The version of this library */
@property (nonatomic, strong) NSString *versionString;

///---------------------------------------------------------------------------------------
/// @name Helpers
///---------------------------------------------------------------------------------------

/* Creates a URL with the Cosm API URL string, the resource string and API key.
 
 @param NSString resource path.
 @return Returns NSURL a resource.
 
 Should not need to be called directly. Used internally by models and collections. 
 */
- (NSURL*)urlForRoute:(NSString*)route;

/* Creates a URL with the Cosm's API URL string, the resource string, request parameters and API key.

  Should not need to be called directly. Used internally by models and collections. */
- (NSURL*)urlForRoute:(NSString*)route withParameters:(NSDictionary *)parameters;
/* Returns the ID of a feed.
 
 Should not need to be called directly. Used internally by new feed models to extract the feed id from the location header of a response. */
+ (NSString *)feedIDFromURLString:(NSString *)urlString;

@end
