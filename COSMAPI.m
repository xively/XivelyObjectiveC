#import "COSMAPI.h"

@implementation COSMAPI

#pragma mark - Lifecycle

- (id)init {
    if (self=[super init]) {
        apiURLString = @"http://api.cosm.com/v2";
        useGzip = YES;
    }
    return self;
}

#pragma mark - Default instance

static COSMAPI *defaultAPI = nil;
+ (COSMAPI *)defaultAPI {
    if (!defaultAPI) {
        defaultAPI = [[COSMAPI alloc] init];
    }
    return defaultAPI;
}

#pragma mark - Sync settings

@synthesize apiKey, apiURLString, useGzip;

#pragma mark - Helpers

- (NSURL*)urlForRoute:(NSString*)route {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?key=%@", apiURLString, route, apiKey]];
    NSLog(@"COSMAPI `urlForRoute:` is %@", url);
    return url;
}

- (NSURL*)urlForRoute:(NSString*)route withParameters:(NSDictionary *)parameters {
    NSMutableString *url = [[NSMutableString alloc] initWithCapacity:2000];
    [url appendFormat:(@"%@/%@?"), apiURLString, route];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *parameter = obj;
        if ([parameter compare:@""] != NSOrderedSame) {
            [url appendFormat:@"%@=%@&", key, parameter];
        }
    }];
    [url appendFormat:@"key=%@&", apiKey];
    NSLog(@"COSMAPI `urlForRoute:` is %@", url);    
    return [NSURL URLWithString:url];
}

+ (NSString *)feedIDFromURLString:(NSString *)urlString {
    NSString *feedId = NULL;
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"feeds/([0-9]*)" options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators | NSRegularExpressionAnchorsMatchLines | NSRegularExpressionAllowCommentsAndWhitespace error:&error];
    if (!error) {
        NSArray *matches = [regex matchesInString:urlString
                                          options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators | NSRegularExpressionAnchorsMatchLines | NSRegularExpressionAllowCommentsAndWhitespace
                                            range:NSMakeRange(0, [urlString length])];
        if ([matches count]>0) {
            NSTextCheckingResult *match = [matches objectAtIndex:0];
            feedId = [urlString substringWithRange:[match rangeAtIndex:1]];
        }
    } else {
        NSLog(@"Error in regex %@", error);
    }
    return feedId;
}

@end
