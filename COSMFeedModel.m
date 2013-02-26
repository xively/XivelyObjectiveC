#import "COSMFeedModel.h"
#import "COSMDatastreamModel.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

@interface COSMFeedModel ()

@end

@implementation COSMFeedModel

#pragma mark - Data

@synthesize datastreamCollection;

- (NSMutableDictionary *)saveableInfoWithNewDatastreamsOnly:(BOOL)newOnly {
    NSMutableDictionary *copiedDictionary = [NSMutableDictionary dictionaryWithDictionary:self.info];
    NSMutableArray *datastreams = [[NSMutableArray alloc] init];
    [copiedDictionary removeObjectForKey:@"datastreams"];
    [datastreamCollection.datastreams enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[COSMDatastreamModel class]]) {
            COSMDatastreamModel *datastream = obj;
            if (!newOnly || datastream.isNew) {
                [datastreams addObject:[datastream saveableInfo]];
            }
        }
    }];
    [copiedDictionary setObject:datastreams forKey:@"datastreams"];
    return copiedDictionary;
}

#pragma mark - Life cycle

-(id)init {
    if (self = [super init]) {
		self.api = [COSMAPI defaultAPI];
        self.datastreamCollection = [[COSMDatastreamCollection alloc] init];
    }
    return self;
}

#pragma mark - Synchronization

- (void)fetch {
    [self useParameter:@"show_user" withValue:@"true"];
    NSURL *url = [self.api urlForRoute:[NSString stringWithFormat:@"feeds/%@", [self.info valueForKeyPath:@"id"]] withParameters:self.parameters];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:40.0];
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
    NSMutableDictionary *saveableInfoDictionary = [self saveableInfoWithNewDatastreamsOnly:YES];
    
    if (self.isNew) {
        // POST
        NSURL *url = [self.api urlForRoute:@"feeds/"];
        AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL:url];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:nil parameters:nil];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSData *data  = [NSJSONSerialization dataWithJSONObject:saveableInfoDictionary options:NSJSONWritingPrettyPrinted error:nil];
        NSLog(@"JSON %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        [request setHTTPBody:data];
        AFHTTPRequestOperation *operation = [httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"recieved response! %@", [operation.response valueForKeyPath:@"allHeaderFields.Location"]);
            if ([operation.response valueForKeyPath:@"allHeaderFields.Location"]) {
                NSString *feedId = [COSMAPI feedIDFromURLString:[operation.response valueForKeyPath:@"allHeaderFields.Location"]];
                [self.info setObject:feedId forKey:@"id"];
                NSLog(@"My ID is %@", feedId);
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
            if ([[error userInfo] valueForKeyPath:NSLocalizedRecoverySuggestionErrorKey]) {
                id JSON = [NSJSONSerialization JSONObjectWithData:[[[error userInfo] valueForKeyPath:NSLocalizedRecoverySuggestionErrorKey]  dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                [self.delegate modelFailedToDeleteFromCOSM:self withError:error json:JSON];
            } else {
                [self.delegate modelFailedToDeleteFromCOSM:self withError:error json:NULL];
            }
        }
    }];
    [operation start];
}

- (void)parse:(id)JSON {
    // create a deep mutable copy
    NSMutableDictionary * mutableJSON  = (__bridge NSMutableDictionary *)CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)JSON, kCFPropertyListMutableContainers);
    self.datastreamCollection.feedId = [[mutableJSON valueForKeyPath:@"id"] integerValue];
    [self.datastreamCollection parse:[mutableJSON valueForKeyPath:@"datastreams"]];
    [self.datastreamCollection.datastreams enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        COSMDatastreamModel *datastream = obj;
        datastream.feedId = [[self.info valueForKeyPath:@"id"] integerValue];
    }];
    [mutableJSON removeObjectForKey:@"datastreams"];
    self.info = mutableJSON;
    self.isNew = NO;
}

@end
