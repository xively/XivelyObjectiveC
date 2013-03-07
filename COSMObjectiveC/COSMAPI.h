#import <Foundation/Foundation.h>

/**
 Holds an API key to be used by models and collections when interacting with Cosm's web services.
 
 You can set a default API key for all models and collection by adding it to the defaultAPI object. Alternatively, a new COSMAPI can be added to any model or collection on a case by case basis.
 
 If your application only requires one API key, add it to the default COSMAPI object in your application delegate. For example in ` AppDelegate.h`:
 
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
 
/** The default COSMAPI used by all models & collections if no other is provided. May be accessed at any point with `[COSMAPI defaultAPI]`. */
+ (COSMAPI *)defaultAPI;

///---------------------------------------------------------------------------------------
/// @name Sync Settings
///---------------------------------------------------------------------------------------

/** An API to be used when interacting with Cosm's web services. */
@property (nonatomic, strong) NSString *apiKey;
/** The URL string to be used for Cosm's rest services. By default this is set to http://api.cosm.com/v2. */
@property (nonatomic, strong) NSString *apiURLString;
/** The URL string of be used for Cosm's web socket services. By default this is set to http://api.cosm.com:8080. */
@property (nonatomic, strong) NSString *socketApiURLString;

///---------------------------------------------------------------------------------------
/// @name Helpers
///---------------------------------------------------------------------------------------

/* Creates a URL with the Cosm's api URL string, the resource string and API key.
 
 @param NSString resource path.
 @return Returns NSURL a resource
 
 Should not need to be called directly. Used internally by models and collections. 
 */
- (NSURL*)urlForRoute:(NSString*)route;

/* Creates a URL with the Cosm's api URL string, the resource string, request parameters and API key.

  Should not need to be called directly. Used internally by models and collections. */
- (NSURL*)urlForRoute:(NSString*)route withParameters:(NSDictionary *)parameters;
/* Returns the ID of a feed.
 
 Should not need to be called directly. Used internally by new feed models to extract the feed id from the location header of a response. */
+ (NSString *)feedIDFromURLString:(NSString *)urlString;

@end
