#import "COSMSubscribable.h"

@interface COSMSubscribable() {}
// Socket Connection
@property (nonatomic, strong) SRWebSocket *socketConnection;
@property (nonatomic, strong) NSString *subscribeToken;
@property (nonatomic, strong) NSString *unsubscribeToken;
// Virtual Methods
@end

@implementation COSMSubscribable

#pragma mark - Lifecycle

- (void)dealloc {
    self.delegate = nil;
    self.socketConnection.delegate = nil;
    self.socketConnection = nil;
    if (isSubscribed) {
        [self unsubscribe];
    }
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
        return;
    }
    
    // get a token to later identify our request
    // for unsubscription
    self.unsubscribeToken = [NSString stringWithFormat:@"%d", arc4random()];
    
    // create our request for subscription
    NSDictionary *subscribeRequest = @{
    @"method" : @"unsubscribe",
    @"resource" : [NSString stringWithFormat:@"/%@", self.resourceURLString],
    @"headers" : @{@"X-ApiKey" : self.api.apiKey},
    @"token" : self.unsubscribeToken
    };
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:subscribeRequest
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Could not recreate internal unsubscribe request data. Error %@", error);
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelDidUnsubscribe:withError:)]) {
            NSError *unsubscribeError = [NSError errorWithDomain:@"com.cosm" code:9 userInfo:nil];
            [self.delegate modelDidUnsubscribe:self withError:unsubscribeError];
        }
        [self.socketConnection close];
        return;
    }
    
    //NSLog(@"Sending %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
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
                if (self.delegate && [self.delegate respondsToSelector:@selector(modelDidUnsubscribe:withError:)]) {
                    NSError *subscribeError = [NSError errorWithDomain:@"com.cosm" code:statusCode userInfo:json];
                    [self.delegate modelDidUnsubscribe:self withError:subscribeError];
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
                if (self.delegate && [self.delegate respondsToSelector:@selector(modelDidUnsubscribe:withError:)]) {
                    NSError *unsubscribeError = [NSError errorWithDomain:@"com.cosm" code:statusCode userInfo:json];
                    [self.delegate modelDidUnsubscribe:self withError:unsubscribeError];
                }
                self.delegate = nil;
                [self.socketConnection close];
                return;
            } else {
                NSLog(@"Expecting to close socket");
                [self.socketConnection close];
                return;
            }
        } else {
            NSLog(@"Recieved something to do with unsubsribing, but don't know what it is. Will still unsubscribe");
            NSLog(@"%@", json);
            [self.socketConnection close];
            return;
        }
    } 
    
    NSLog(@"Recived message, don't know what to do with it");
    NSLog(@"Message %@", message);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    
    // get a token to later identify our request
    // for subscription
    self.subscribeToken = [NSString stringWithFormat:@"%d", arc4random()];
    
    // create our request for subscription
    NSDictionary *subscribeRequest = @{
    @"method" : @"subscribe",
    @"resource" : [NSString stringWithFormat:@"/%@", self.resourceURLString],
    @"headers" : @{@"X-ApiKey" : self.api.apiKey},
    @"token" : self.subscribeToken
    };
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:subscribeRequest
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Could not recreate internal subscribe request data. Error %@", error);
        if (self.delegate && [self.delegate respondsToSelector:@selector(modelDidUnsubscribe:withError:)]) {
            NSError *unsubscribeError = [NSError errorWithDomain:@"com.cosm" code:9 userInfo:nil];
            [self.delegate modelDidUnsubscribe:self withError:unsubscribeError];
        }
        [self.socketConnection close];
        return;
    }
    
    // send request for subscription
    [self.socketConnection send:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    //NSLog(@"COSMSubscribable websocket connection failed with error %@", error);
    self.subscribeToken = nil;
    self.unsubscribeToken = nil;
    self.socketConnection.delegate = nil;
    self.socketConnection = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(modelDidUnsubscribe:withError:)]) {
        [self.delegate modelDidUnsubscribe:self withError:error];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    isSubscribed = NO;
    self.subscribeToken = nil;
    self.unsubscribeToken = nil;
    self.socketConnection.delegate = nil;
    self.socketConnection = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(modelDidUnsubscribe:withError:)]) {
        NSError *error = nil;
        if (code != 1000 && code != 0) {
            NSDictionary *dict = @{ NSLocalizedDescriptionKey : reason };
            error = [NSError errorWithDomain:@"com.cosm" code:code userInfo:dict];
        }
        [self.delegate modelDidUnsubscribe:self withError:error];
    }
}


@end
