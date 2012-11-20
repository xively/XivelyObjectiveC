#import "COSMFeedModel.h"
#import "COSMDatastreamModel.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

@implementation COSMFeedModel

#pragma mark - Data

@synthesize datastreamCollection;

#pragma mark - Life cycle

-(id)init {
    if (self = [super init]) {
		self.api = [COSMAPI defaultAPI];
        self.datastreamCollection = [[COSMDatastreamCollection alloc] init];
        required = @[
            @"title"
        ];
    }
    return self;
}

#pragma mark - Synchronization

- (void)fetch {
    [self useParameter:@"show_user" withValue:@"true"];
    NSURL *url = [self.api urlForRoute:[NSString stringWithFormat:@"feeds/%@", [self.info valueForKeyPath:@"id"]] withParameters:self.parameters];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"Data: %@", JSON);
        [self parse:JSON];
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelDidFetch:)]) {
            [self.delegate modelDidFetch:self];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error %@", error);
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToFetch:withError:json:)]) {
            [self.delegate modelFailedToFetch:self withError:error json:JSON];
        }
    }];
    [operation start];
}

- (void)save {
    if (self.isNew) {
        // PUT
        NSURL *url = [self.api urlForRoute:@"feeds.json"];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        httpClient.parameterEncoding = AFJSONParameterEncoding;
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:nil parameters:self.info];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                NSLog(@"COSMModelFeed did return a json responce. Unexpected. This might not work as not tested");
                if ([response valueForKeyPath:@"allHeaderFields.Location"]) {
                    NSString *feedId = [COSMAPI feedIDFromURLString:[response valueForKeyPath:@"allHeaderFields.Location"]];
                    [self.info setObject:feedId forKey:@"id"];
                    
                    NSLog(@"COSMFeedModel save: should be adding feed id to children");
                }
                self.isNew = NO;
                self.isUpdated = NO;
                if (self.delegate && [self.delegate respondsToSelector:@selector(modelDidSave:)]) {
                    [self.delegate modelDidSave:self];
                }
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                NSLog(@"COSMModelFeed save did not return a json responce");
                // cosm is returing a header of type text/html
                // so we are going to check it is type 201 (Created) and
                // pass on the nil JSON object and not parse
                if ([response statusCode] == 201) {
                    if ([response valueForKeyPath:@"allHeaderFields.Location"]) {
                        NSString *feedId = [COSMAPI feedIDFromURLString:[response valueForKeyPath:@"allHeaderFields.Location"]];
                        [self.info setObject:feedId forKey:@"id"];
                    }
                    self.isNew = NO;
                    self.isUpdated = NO;
                    if (self.delegate && [self.delegate respondsToSelector:@selector(modelDidSave:)]) {
                        [self.delegate modelDidSave:self];
                    }
                } else {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToSave:withError:json:)]) {
                        [self.delegate modelFailedToSave:self withError:error json:JSON];
                    }
                }
            }];
            [operation start];
    } else {
        // POST
    }
}

- (void)deleteFromCOSM {
    NSString *feedId = [self.info valueForKeyPath:@"id"];
    if (!feedId) {
        NSLog(@"COSMFeedController `deleteFromCOSM` cannot delete feed. Feed has no `id` in info dictionary");
        return;
    }
    NSURL *url = [self.api urlForRoute:[NSString stringWithFormat:@"feeds/%@", feedId]];
    AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL:url];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"DELETE" path:nil parameters:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    AFHTTPRequestOperation *operation = [httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.isDeletedFromCOSM = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelDidDeleteFromCOSM:)]) {
            [self.delegate modelDidDeleteFromCOSM:self];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToDeleteFromCOSM:withError:json:)]) {
            id JSON = [NSJSONSerialization JSONObjectWithData:[[[error userInfo] valueForKeyPath:NSLocalizedRecoverySuggestionErrorKey]  dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            [self.delegate modelFailedToDeleteFromCOSM:self withError:error json:JSON];
        }
    }];
    [operation start];
}

- (void)parse:(id)JSON {
    NSMutableDictionary * mutableJSON = [NSMutableDictionary dictionaryWithDictionary:JSON];
    self.datastreamCollection.feedId = [[mutableJSON valueForKeyPath:@"id"] integerValue];
    [self.datastreamCollection parse:[mutableJSON valueForKeyPath:@"datastreams"]];
    [mutableJSON removeObjectForKey:@"datastreams"];
    self.info = mutableJSON;
    self.isNew = NO;
}

@end
