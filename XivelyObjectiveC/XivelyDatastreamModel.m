#import "XivelyDatastreamModel.h"
#import "XivelyDatapointCollection.h"
#import "XivelyDatapointModel.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

@implementation XivelyDatastreamModel

#pragma marl - Data

@synthesize feedId;

- (BOOL)checkIdAndNotifyOnFailure {

    return YES;
}

#pragma mark - Datapoints

@synthesize datapointCollection;

#pragma mark - Synchronisation

@synthesize isNew;

- (NSString *)resourceURLString {
    return [NSString stringWithFormat:@"feeds/%lu/datastreams/%@", (unsigned long)self.feedId, [self.info valueForKeyPath:@"id"]];
}

- (void)fetch {
    if (!self.feedId) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToFetch:withError:json:)]) {
            [self.delegate modelFailedToFetch:self withError:nil json:@{ @"Error" : @"Datastream has no feed id" }];
        }
        return;
    }
    NSString *datastreamId = [self.info valueForKeyPath:@"id"];
    if (!datastreamId) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToFetch:withError:json:)]) {
            [self.delegate modelFailedToFetch:self withError:nil json:@{ @"Error" : @"Datastream has no id" }];
        }
        return;
    }

    NSURL *url = [self.api urlForRoute:self.resourceURLString withParameters:self.parameters];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:40.0];
    [request setValue:self.api.versionString forHTTPHeaderField:@"User-Agent"];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                            [self parse:JSON];
                            if (self.delegate && [self.delegate respondsToSelector:@selector(modelDidFetch:)]) {
                                [self.delegate modelDidFetch:self];
                            }
                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                            //NSLog(@"Error %@", error);
                            if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToFetch:withError:json:)]) {
                                [self.delegate modelFailedToFetch:self withError:error json:JSON];
                            }
                        }];
    [operation start];
}

- (void)save {
    NSMutableDictionary *saveableInfoDictionary = [self saveableInfo];

    if (self.isNew) {
        if (!self.feedId) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToSave:withError:json:)]) {
                [self.delegate modelFailedToSave:self withError:nil json:@{ @"Error" : @"Datastream has no feed id" }];
            }
            return;
        }

        // POST
        // using the feed api as the datastream api is returning an error?
        NSURL *url = [self.api urlForRoute:[NSString stringWithFormat:@"feeds/%lu", (unsigned long)self.feedId]];
        AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL:url];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"PUT" path:nil parameters:nil];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:self.api.versionString forHTTPHeaderField:@"User-Agent"];
        // wrapping the saveable info so this looks like an update to a feed
        NSMutableDictionary *wrappedInfo = [NSMutableDictionary dictionaryWithObjects:@[@[saveableInfoDictionary]] forKeys:@[@"datastreams"]];
        NSData *data  = [NSJSONSerialization dataWithJSONObject:wrappedInfo options:NSJSONWritingPrettyPrinted error:nil];
        [request setHTTPBody:data];
        AFHTTPRequestOperation *operation = [httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.isNew = NO;
            if (self.delegate && [self.delegate respondsToSelector:@selector(modelDidSave:)]) {
                [self.delegate modelDidSave:self];
            }
            self.datapointCollection.feedId = self.feedId;
            self.datapointCollection.datastreamId = [self.info valueForKeyPath:@"id"];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToSave:withError:json:)]) {
                id JSON = [NSJSONSerialization JSONObjectWithData:[[[error userInfo] valueForKeyPath:NSLocalizedRecoverySuggestionErrorKey]  dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                [self.delegate modelFailedToSave:self withError:error json:JSON];
            }
        }];
        [operation start];
    } else {
        if (!self.feedId) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToSave:withError:json:)]) {
                [self.delegate modelFailedToSave:self withError:nil json:@{ @"Error" : @"Datastream has no feed id" }];
            }
            return;
        }
        NSString *datastreamId = [self.info valueForKeyPath:@"id"];
        if (!datastreamId) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToSave:withError:json:)]) {
                [self.delegate modelFailedToSave:self withError:nil json:@{ @"Error" : @"Datastream has no id" }];
            }
            return;
        }
        NSURL *url = [self.api urlForRoute:[NSString stringWithFormat:self.resourceURLString, self.feedId, [self.info valueForKeyPath:@"id"]]];
        AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL:url];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"PUT" path:nil parameters:nil];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:self.api.versionString forHTTPHeaderField:@"User-Agent"];
        NSData *data  = [NSJSONSerialization dataWithJSONObject:saveableInfoDictionary options:NSJSONWritingPrettyPrinted error:nil];
        [request setHTTPBody:data];
        AFHTTPRequestOperation *operation = [httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                // make something similar to Xively Api error
                // with the error information we have extracted.
                if ([NSJSONSerialization isValidJSONObject:dataToJsonify]) {
                    JSON = [NSJSONSerialization JSONObjectWithData:[dataToJsonify dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&jsonError];
                    //if (jsonError) {
                        //NSLog(@"JSON error %@", jsonError);
                    //}
                } else {
                    JSON = @{@"title" : @"Failed to save", @"errors" : dataToJsonify};
                }
                [self.delegate modelFailedToSave:self withError:error json:JSON];
            }
        }];
        [operation start];
    }
}

- (void)deleteFromXively {
    if (!self.feedId) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToDeleteFromXively:withError:json:)]) {
            [self.delegate modelFailedToDeleteFromXively:self withError:nil json:@{ @"Error" : @"Datastream has no feed id" }];
        }
        return;
    }
    NSString *datastreamId = [self.info valueForKeyPath:@"id"];
    if (!datastreamId) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToDeleteFromXively:withError:json:)]) {
            [self.delegate modelFailedToDeleteFromXively:self withError:nil json:@{ @"Error" : @"Datastream has no id" }];
        }
        return;
    }
    NSURL *url = [self.api urlForRoute:[NSString stringWithFormat:@"feeds/%lu/datastreams/%@", (unsigned long)feedId, datastreamId]];
    AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL:url];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"DELETE" path:nil parameters:nil];
    [request setValue:self.api.versionString forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    AFHTTPRequestOperation *operation = [httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.isDeletedFromXively = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelDidDeleteFromXively:)]) {
            [self.delegate modelDidDeleteFromXively:self];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToDeleteFromXively:withError:json:)]) {
            if ([[error userInfo] valueForKeyPath:NSLocalizedRecoverySuggestionErrorKey]) {
                id JSON = [NSJSONSerialization JSONObjectWithData:[[[error userInfo] valueForKeyPath:NSLocalizedRecoverySuggestionErrorKey]  dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                [self.delegate modelFailedToDeleteFromXively:self withError:error json:JSON];
            } else {
                [self.delegate modelFailedToDeleteFromXively:self withError:error json:NULL];
            }
        }
    }];
    [operation start];
}

- (void)parse:(id)JSON {
    CFPropertyListRef mutableJSONRef  = CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)JSON, kCFPropertyListMutableContainers);
    NSMutableDictionary *mutableJSON = (__bridge NSMutableDictionary *)mutableJSONRef;
    if (!mutableJSON) { return; }
    self.isNew = ([mutableJSON valueForKeyPath:@"id"] == nil);
    [self.datapointCollection.datapoints removeAllObjects];
    self.datapointCollection.feedId = self.feedId;
    self.datapointCollection.datastreamId = [mutableJSON valueForKeyPath:@"id"];
    NSArray *returnedDatastreams = [mutableJSON valueForKeyPath:@"datapoints"];
    [self.datapointCollection parse:returnedDatastreams];
    [mutableJSON removeObjectForKey:@"datastreams"];
    self.info = mutableJSON;
    CFRelease(mutableJSONRef);
}

- (NSMutableDictionary *)saveableInfo {
    NSMutableDictionary *copiedDictionary = [NSMutableDictionary dictionaryWithDictionary:self.info];
    [copiedDictionary removeObjectForKey:@"datapoints"];
    return copiedDictionary;
}

#pragma mark - Life cycle

-(id)init {
    if (self = [super init]) {
		self.api = [XivelyAPI defaultAPI];
        self.datapointCollection = [[XivelyDatapointCollection alloc] init];
        [self.info setValue:[[NSMutableDictionary alloc] init] forKey:@"unit"];
        self.isNew = YES;
    }
    return self;
}

@end
