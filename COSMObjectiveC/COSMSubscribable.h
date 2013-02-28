#import <Foundation/Foundation.h>
#import "COSMModel.h"
#import "SRWebSocket.h"

// delegate protocol for subscribing
@protocol COSMSubscribableDelegate <COSMModelDelegate, NSObject> 
@optional
- (void)modelDidSubscribe:(COSMModel *)model;
/// called when the model is unsubscribed. This can happen immeditatly
/// after a request to subscribe, if/when the socket connection drops
/// or if a unsubscribe requst is successful or unsucessful. If the
/// unsubcribe is unitentional it should have an error otherwise the
/// error should be nil.
///
/// worth noting that many mobile operator do not allow web sockets
- (void)modelDidUnsubscribe:(COSMModel *)model withError:(NSError *)error;
- (void)modelUpdatedViaSubscription:(COSMModel *)model;
@end

@interface COSMSubscribable : COSMModel<SRWebSocketDelegate>

// delegate
@property (nonatomic, weak) id<COSMSubscribableDelegate, COSMModelDelegate> delegate;

// socket connection
@property (readonly) BOOL isSubscribed;
- (void)subscribe;
- (void)unsubscribe;

@end
