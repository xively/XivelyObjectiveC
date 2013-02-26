#import "COSMDatastreamModel.h"
#import "COSMDatapointCollection.h"
#import "COSMDatapointModel.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

@interface COSMDatastreamModel () {}
// Socket Connection
@property (nonatomic, strong) SRWebSocket *socketConnection;
@property (nonatomic, strong) NSString *subscribeToken;
@property (nonatomic, strong) NSString *unsubscribeToken;
@end

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

#pragma mark - Socket Connection

// private
@synthesize socketConnection;

// public
@synthesize isSubscribed, subscribeToken, unsubscribeToken;

- (void)subscribe {
    if (self.isNew) {
        NSLog(@"Datastream is new (not synced with server) so cannot subscribe");
    }
    
    if (isSubscribed) {
        NSLog(@"Socket connection is already subscribed");
        return;
    }
    
    self.socketConnection.delegate = nil;
    self.socketConnection = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:self.api.socketApiURLString]];
    self.socketConnection.delegate = self;
    [self.socketConnection open];
}

- (void)unsubscribe {
    if (!isSubscribed) {
        NSLog(@"No socket connection to unsubscribe from");
        return;
    }
    
    // get a token to later identify our request
    // for unsubscription
    self.unsubscribeToken = [NSString stringWithFormat:@"%d", arc4random()];
    
    // create our request for subscription
    NSDictionary *subscribeRequest = @{
        @"method" : @"unsubscribe",
        @"resource" : [NSString stringWithFormat:@"/feeds/%d/datastreams/%@", self.feedId, [self.info valueForKeyPath:@"id"]],
        @"headers" : @{@"X-ApiKey" : self.api.apiKey},
        @"token" : self.unsubscribeToken
    };
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:subscribeRequest
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Could not recreate internal unsubscribe request data. Error %@", error);
        [self.socketConnection close];
        return;
    }
    
    // send request for subscription
    [self.socketConnection send:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
}

#pragma mark - Socket Delegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    
    // sanity check, unlikely not to be a string
    if (![message isKindOfClass:[NSString class]]) { return; }
    
    // parse the message as JSON, or bail
    NSError *error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments
                                                            error:&error];
    if (error) {
        NSLog(@"Message could not be converted to JSON");
        return;
    }
    
    // check if this to do with our subscribe request
    if ([[json valueForKeyPath:@"token"] isEqualToString:self.subscribeToken]) {
        
        // see if there is a status request (therefore this responce has been triggered by out subscribe request)
        if ([json valueForKeyPath:@"status"] && [[json valueForKeyPath:@"status"] isKindOfClass:[NSNumber class]]) {
            
            // let the delegate know of success or fail to subscribe
            NSInteger statusCode = [[json valueForKeyPath:@"status"] integerValue];
            if (statusCode != 200) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToSubscribe:withError:)]) {
                    NSError *subscribeError = [NSError errorWithDomain:@"com.cosm" code:statusCode userInfo:json];
                    [self.delegate modelFailedToSubscribe:self withError:subscribeError];
                }
                [self.socketConnection close];
                return;
            }
            isSubscribed = YES;
            if (self.delegate && [self.delegate respondsToSelector:@selector(modelDidSubscribe:)]) {
                [self.delegate modelDidSubscribe:self];
            }
            return;
        }
        
        // if we are this far, the message relates to an update
        // so parse and let the delegate know
        if ([json valueForKeyPath:@"body"]) {
            [self parse:[json valueForKeyPath:@"body"]];
            if (self.delegate && [self.delegate respondsToSelector:@selector(modelUpdatedViaSubscription:)]) {
                [self.delegate modelUpdatedViaSubscription:self];
            }
        }
        
    }
    // check if this to do with our unsubscribe request
    else if ([[json valueForKeyPath:@"token"] isEqualToString:self.unsubscribeToken]) {
        // see if there is a status request (therefore this responce has been triggered by out subscribe request)
        if ([json valueForKeyPath:@"status"] && [[json valueForKeyPath:@"status"] isKindOfClass:[NSNumber class]]) {
            // let the delegate know of success or fail to subscribe
            NSInteger statusCode = [[json valueForKeyPath:@"status"] integerValue];
            if (statusCode != 200) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToUnsubscribe:withError:)]) {
                    NSError *unsubscribeError = [NSError errorWithDomain:@"com.cosm" code:statusCode userInfo:json];
                    [self.delegate modelFailedToUnsubscribe:self withError:unsubscribeError];
                }
                return;
            }
            [self.socketConnection close];
            return;
        } else {
            NSLog(@"Recieved something to do with unsubsribing, but don't know what it is");
            NSLog(@"%@", json);
        }
    } else {
        NSLog(@"Recieved responce but is nothing to do with subscribe");
        return;
    }    
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    
    // get a token to later identify our request
    // for subscription
    self.subscribeToken = [NSString stringWithFormat:@"%d", arc4random()];
    
    // create our request for subscription
    NSDictionary *subscribeRequest = @{
        @"method" : @"subscribe",
        @"resource" : [NSString stringWithFormat:@"/feeds/%d/datastreams/%@", self.feedId, [self.info valueForKeyPath:@"id"]],
        @"headers" : @{@"X-ApiKey" : self.api.apiKey},
        @"token" : self.subscribeToken
    };
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:subscribeRequest
                                                       options:NSJSONWritingPrettyPrinted 
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Could not recreate internal subscribe request data. Error %@", error);
        [self.socketConnection close];
        return;
    }
    
    // send request for subscription
    [self.socketConnection send:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    self.subscribeToken = nil;
    self.unsubscribeToken = nil;
    self.socketConnection.delegate = nil;
    self.socketConnection = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToUnsubscribe:withError:)]) {
        [self.delegate modelFailedToUnsubscribe:self withError:error];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    isSubscribed = NO;
    self.subscribeToken = nil;
    self.unsubscribeToken = nil;
    self.socketConnection.delegate = nil;
    self.socketConnection = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(modelDidUnsubscribe:)]) {
        [self.delegate modelDidUnsubscribe:self];
    }
}


@end
