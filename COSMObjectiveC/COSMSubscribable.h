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


/**
  COSMSubscribable is used by COSMFeedModels and COSMDatastreamModels so they may subscribe to live updates from Cosm via web socket connection. 
 
 When a COSMFeedModels or COSMDatastreamModels is subscribed Cosm its own data and child collections we be repopulated with data whenever they are change on Cosm. When a model recieves an update triggered by Cosm its delegate will be notified by the `modelUpdatedViaSubscription:` method.  
 
 @warning *Important:* Web socket connection are not allow on many mobile networks providers. If the device is running on a mobile connection and attempts to subscribe, the `modelDidUnsubscribe:withError:` may be called imeditaly or after a few seconds. */
@interface COSMSubscribable : COSMModel<SRWebSocketDelegate>

///---------------------------------------------------------------------------------------
/// @name Delegate
///---------------------------------------------------------------------------------------
@property (nonatomic, weak) id<COSMSubscribableDelegate, COSMModelDelegate> delegate;

///---------------------------------------------------------------------------------------
/// @name Socket Connection
///---------------------------------------------------------------------------------------
@property (readonly) BOOL isSubscribed;
- (void)subscribe;
- (void)unsubscribe;

@end
