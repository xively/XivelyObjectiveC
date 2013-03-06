#import "COSMDatapointModel.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

@implementation COSMDatapointModel

#pragma mark - Data

@synthesize feedId;
@synthesize datastreamId;

#pragma mark - Synchronization

@synthesize isNew;

- (void)save {
    if (self.feedId == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToSave:withError:json:)]) {
            [self.delegate modelFailedToSave:self withError:nil json:@{ @"Error" : @"Datapoint has no feed id" }];
        }
        return;
    }
    if (self.datastreamId == nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToSave:withError:json:)]) {
            [self.delegate modelFailedToSave:self withError:nil json:@{ @"Error" : @"Datapoint has no datastream id" }];
        }
        return;
    }
    NSURL *url = [self.api urlForRoute:[NSString stringWithFormat:@"feeds/%d/datastreams/%@/datapoints", self.feedId, self.datastreamId]];
    AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL:url];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:nil parameters:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSData *data  = [NSJSONSerialization dataWithJSONObject:@{@"datapoints":@[self.info]} options:NSJSONWritingPrettyPrinted error:nil];
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
            } else {
                JSON = @{@"title" : @"Failed to save", @"errors" : dataToJsonify};
            }
            [self.delegate modelFailedToSave:self withError:error json:JSON];
        }
    }];
    [operation start];
}

- (void)fetch {
    if (self.feedId == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToFetch:withError:json:)]) {
            [self.delegate modelFailedToFetch:self withError:nil json:@{ @"Error" : @"Datapoint has no feed id" }];
        }
        return;
    }
    if (self.datastreamId == nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToFetch:withError:json:)]) {
            [self.delegate modelFailedToFetch:self withError:nil json:@{ @"Error" : @"Datapoint has no datastream id" }];
        }
        return;
    }
    if ([self.info objectForKey:@"at"] == nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToFetch:withError:json:)]) {
            [self.delegate modelFailedToFetch:self withError:nil json:@{ @"Error" : @"Datapoint has no `at` value" }];
        }
        return;
    }
    NSURL *url = [self.api urlForRoute:[NSString stringWithFormat:@"feeds/%d/datastreams/%@/datapoints/%@", self.feedId, self.datastreamId, [self.info objectForKey:@"at"]] withParameters:self.parameters];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:40.0];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            [self parse:JSON];
            if (self.delegate && [self.delegate respondsToSelector:@selector(modelDidFetch:)]) {
                [self.delegate modelDidFetch:self];
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToFetch:withError:json:)]) {
                [self.delegate modelFailedToFetch:self withError:error json:JSON];
            }
        }];
    [operation start];
    
}

- (void)deleteFromCosm {
    if (self.feedId == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToDeleteFromCOSM:withError:json:)]) {
            [self.delegate modelFailedToDeleteFromCOSM:self withError:nil json:@{ @"Error" : @"Datapoint has no feed id" }];
        }
        return;
    }
    if (self.datastreamId == nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToDeleteFromCOSM:withError:json:)]) {
            [self.delegate modelFailedToDeleteFromCOSM:self withError:nil json:@{ @"Error" : @"Datapoint has no datastream id" }];
        }
        return;
    }
    if ([self.info objectForKey:@"at"] == nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToDeleteFromCOSM:withError:json:)]) {
            [self.delegate modelFailedToDeleteFromCOSM:self withError:nil json:@{ @"Error" : @"Datapoint has no `at` value" }];
        }
        return;
    }
    NSURL *url = [self.api urlForRoute:[NSString stringWithFormat:@"feeds/%d/datastreams/%@/datapoints/%@", self.feedId, self.datastreamId, [self.info objectForKey:@"at"]]];
    AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL:url];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"DELETE" path:nil parameters:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    AFHTTPRequestOperation *operation = [httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.isDeletedFromCosm = YES;
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
    self.info = [NSMutableDictionary dictionaryWithDictionary:JSON];
    if ([self.info valueForKeyPath:@"at"] != nil) {
        self.isNew = NO;
    }
}

#pragma mark - Life Cycle

- (id)init {
    self = [super init];
    if (self) {
        self.isNew = YES;
    }
    return self;
}
@end
