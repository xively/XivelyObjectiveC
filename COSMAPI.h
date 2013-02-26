#import <Foundation/Foundation.h>

@class COSMAPI;

@interface COSMAPI : NSObject {
    
}

// defaut COSMSync used by all models & collections
+ (COSMAPI *)defaultAPI;

// Sync settings
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *apiURLString;
@property BOOL useGzip;

// Helpers
- (NSURL*)urlForRoute:(NSString*)route;
- (NSURL*)urlForRoute:(NSString*)route withParameters:(NSDictionary *)parameters;
+ (NSString *)feedIDFromURLString:(NSString *)urlString;

@end
