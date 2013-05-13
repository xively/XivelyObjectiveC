#import "XivelyAPI.h"

@implementation XivelyAPI

#pragma mark - Default Instance

static XivelyAPI *defaultAPI = nil;
+ (XivelyAPI *)defaultAPI {
    if (!defaultAPI) {
        defaultAPI = [[XivelyAPI alloc] init];
    }
    return defaultAPI;
}

#pragma mark - Sync settings

@synthesize apiKey, apiURLString, socketApiURLString, versionString;

#pragma mark - Helpers

- (NSURL*)urlForRoute:(NSString*)route {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?key=%@", apiURLString, route, apiKey]];
    //NSLog(@"XivelyAPI `urlForRoute:` is %@", url);
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
    if (self.apiKey) {
        [url appendFormat:@"key=%@&", apiKey];
    }
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

#pragma mark - Life Cycle

- (id)init {
    if (self=[super init]) {
        self.apiURLString = @"http://api.xively.com/v2";
        self.socketApiURLString = @"http://api.xively.com:8080";
        self.versionString = @"Xively-ObjectiveC-Lib/1.0";
    }
    return self;
}

@end
