#import "COSMDatastreamModel.h"
#import "COSMDatapointCollection.h"
#import "COSMDatapointModel.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

@implementation COSMDatastreamModel

#pragma marl - Data

@synthesize datapointCollection, feedId;

- (NSMutableDictionary *)saveableInfo {
    NSMutableDictionary *copiedDictionary = [NSMutableDictionary dictionaryWithDictionary:self.info];
    [copiedDictionary removeObjectForKey:@"datapoints"];
    return copiedDictionary;
}

#pragma mark - Life cycle

-(id)init {
    if (self = [super init]) {
		self.api = [COSMAPI defaultAPI];
        self.datapointCollection = [[COSMDatapointCollection alloc] init];
        required = @[
            @"id",
            @"current_value"
        ];
        [self.info setValue:[[NSMutableDictionary alloc] init] forKey:@"unit"];
    }
    return self;
}

#pragma mark - Synchronization

- (void)fetch {
    NSURL *url = [self.api urlForRoute:[NSString stringWithFormat:@"feeds/%d/datastreams/%@", self.feedId, [self.info valueForKeyPath:@"id"]] withParameters:self.parameters];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:40.0];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
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
    NSMutableDictionary *saveableInfoDictionary = [self saveableInfo];
    
    if (self.isNew) {
        // POST
        #warning TODO: COSMDatastreamModel should be checking for a feed id
        // this is not what the docs say. this is not createing feed
        // the the api says to "POST" a new feed, but this is not
        // possible, api repied methong must be get, put or post
        // therefore using the datastream feed api
        NSURL *url = [self.api urlForRoute:[NSString stringWithFormat:@"feeds/%d", self.feedId]];
        AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL:url];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"PUT" path:nil parameters:nil];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        // wrapping the saveable info so this looks like an update to a feed
        NSMutableDictionary *wrappedInfo = [NSMutableDictionary dictionaryWithObjects:@[@[saveableInfoDictionary]] forKeys:@[@"datastreams"]];
        NSLog(@"sending %@", wrappedInfo);
        NSData *data  = [NSJSONSerialization dataWithJSONObject:wrappedInfo options:NSJSONWritingPrettyPrinted error:nil];
        [request setHTTPBody:data];
        AFHTTPRequestOperation *operation = [httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"response %d", operation.response.statusCode);
            NSLog(@"response string %@", operation.responseString);
            NSLog(@"%@: %@, %@", [responseObject class], responseObject, [[NSString alloc] initWithData:responseObject
                                                                                                encoding:NSUTF8StringEncoding]);
            self.isNew = NO;
            if (self.delegate && [self.delegate respondsToSelector:@selector(modelDidSave:)]) {
                [self.delegate modelDidSave:self];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToSave:withError:json:)]) {
                id JSON = [NSJSONSerialization JSONObjectWithData:[[[error userInfo] valueForKeyPath:NSLocalizedRecoverySuggestionErrorKey]  dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                [self.delegate modelFailedToSave:self withError:error json:JSON];
            }
        }];
        [operation start];
    } else {
        NSURL *url = [self.api urlForRoute:[NSString stringWithFormat:@"feeds/%d/datastreams/%@", self.feedId, [self.info valueForKeyPath:@"id"]]];
        AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL:url];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"PUT" path:nil parameters:nil];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSData *data  = [NSJSONSerialization dataWithJSONObject:saveableInfoDictionary options:NSJSONWritingPrettyPrinted error:nil];
        [request setHTTPBody:data];
        AFHTTPRequestOperation *operation = [httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.isNew = NO;
            if (self.delegate && [self.delegate respondsToSelector:@selector(modelDidSave:)]) {
                [self.delegate modelDidSave:self];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToSave:withError:json:)]) {
                // get some data to use as JSON from the error
                id dataToJsonify = [[error userInfo] valueForKeyPath:NSLocalizedRecoverySuggestionErrorKey];
                if (!dataToJsonify) {
                    dataToJsonify = [[error userInfo] valueForKeyPath:NSLocalizedDescriptionKey];
                }
                if (!dataToJsonify) {
                    dataToJsonify = @"Save failed with unknown error.";
                }
                NSError *jsonError = NULL;
                id JSON;
                // see if the data can be made into data, if not
                // make something similar to COSM Api error
                // with the error information we have extracted.
                if ([NSJSONSerialization isValidJSONObject:dataToJsonify]) {
                    JSON = [NSJSONSerialization JSONObjectWithData:[dataToJsonify dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&jsonError];
                    if (jsonError) {
                        NSLog(@"JSON error %@", jsonError);
                    }
                } else {
                    JSON = @{@"title" : @"Failed to save", @"errors" : dataToJsonify};
                }
                [self.delegate modelFailedToSave:self withError:error json:JSON];
            }
        }];
        [operation start];
    }
    
    /*
    NSMutableDictionary *saveableInfoDictionary = [self saveableInfo];
    
    if (self.isNew) {
        // POST
        NSURL *url = [self.api urlForRoute:@"feeds/"];
        AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL:url];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:nil parameters:nil];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSData *data  = [NSJSONSerialization dataWithJSONObject:saveableInfoDictionary options:NSJSONWritingPrettyPrinted error:nil];
        [request setHTTPBody:data];
        AFHTTPRequestOperation *operation = [httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([operation.response valueForKeyPath:@"allHeaderFields.Location"]) {
                NSString *feedId = [COSMAPI feedIDFromURLString:[operation.response valueForKeyPath:@"allHeaderFields.Location"]];
                [self.info setObject:feedId forKey:@"id"];
            }
            self.isNew = NO;
            NSMutableArray *savedDatastreams = [saveableInfoDictionary objectForKey:@"datastreams"];
            [savedDatastreams enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                COSMDatastreamModel *savedDatastream = obj;
                [self.datastreamCollection.datastreams enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    COSMDatastreamModel *storedDatastream = obj;
                    if([[savedDatastream valueForKeyPath:@"id"] isKindOfClass:[NSString class]] && [[savedDatastream valueForKeyPath:@"id"] isEqualToString:[storedDatastream.info valueForKeyPath:@"id"]]) {
                        storedDatastream.isNew = NO;
                    }
                }];
            }];
            if (self.delegate && [self.delegate respondsToSelector:@selector(modelDidSave:)]) {
                [self.delegate modelDidSave:self];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToSave:withError:json:)]) {
                id JSON = [NSJSONSerialization JSONObjectWithData:[[[error userInfo] valueForKeyPath:NSLocalizedRecoverySuggestionErrorKey]  dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                [self.delegate modelFailedToSave:self withError:error json:JSON];
            }
        }];
        [operation start];
    } else {
        NSURL *url = [self.api urlForRoute:[NSString stringWithFormat:@"feeds/%@", [self.info valueForKeyPath:@"id"]]];
        AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL:url];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"PUT" path:nil parameters:nil];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSData *data  = [NSJSONSerialization dataWithJSONObject:saveableInfoDictionary options:NSJSONWritingPrettyPrinted error:nil];
        [request setHTTPBody:data];
        AFHTTPRequestOperation *operation = [httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.isNew = NO;
            NSMutableArray *savedDatastreams = [saveableInfoDictionary objectForKey:@"datastreams"];
            [savedDatastreams enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                COSMDatastreamModel *savedDatastream = obj;
                [self.datastreamCollection.datastreams enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    COSMDatastreamModel *storedDatastream = obj;
                    if([[savedDatastream valueForKeyPath:@"id"] isKindOfClass:[NSString class]] && [[savedDatastream valueForKeyPath:@"id"] isEqualToString:[storedDatastream.info valueForKeyPath:@"id"]]) {
                        storedDatastream.isNew = NO;
                    }
                }];
            }];
            if (self.delegate && [self.delegate respondsToSelector:@selector(modelDidSave:)]) {
                [self.delegate modelDidSave:self];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToSave:withError:json:)]) {
                id JSON = [NSJSONSerialization JSONObjectWithData:[[[error userInfo] valueForKeyPath:NSLocalizedRecoverySuggestionErrorKey]  dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                [self.delegate modelFailedToSave:self withError:error json:JSON];
            }
        }];
        [operation start];
    }
     */
}

- (void)parse:(id)JSON {
    NSMutableDictionary * mutableJSON  = (__bridge NSMutableDictionary *)CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)JSON, kCFPropertyListMutableContainers);
    [self.datapointCollection.datapoints removeAllObjects];
    NSArray *returnedDatastreams = [mutableJSON valueForKeyPath:@"datapoints"];
    [self.datapointCollection parse:returnedDatastreams];
    [mutableJSON removeObjectForKey:@"datastreams"];
    self.info = mutableJSON;
    self.isNew = NO;
}

@end
