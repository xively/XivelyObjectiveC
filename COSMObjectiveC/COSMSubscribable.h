#import <Foundation/Foundation.h>
#import "COSMModel.h"
#import "SRWebSocket.h"
#import "COSMSubscribableDelegate.h"

/**
 COSMSubscribable, used by COSMFeedModel and COSMDatastreamModel, is a base class which allows the model to subscribe to live updates from Cosm via a web socket connection. 
 
 When a COSMFeedModel or COSMDatastreamModel is subscribed Cosm its own data and child collections we be repopulated with data whenever this data changes on Cosm. When a model receives an update triggered by Cosm its delegate will be notified by the `modelUpdatedViaSubscription:` method.
 
 @warning *Important:* WebSocket connections are not allowed on many mobile networks providers. If the device is running on a mobile connection and attempts to subscribe, the `modelDidUnsubscribe:withError:` may be called immediaely or after a few seconds. */
@interface COSMSubscribable : COSMModel<SRWebSocketDelegate>

///---------------------------------------------------------------------------------------
/// @name Delegate
///---------------------------------------------------------------------------------------

/** Delegate object which will be notified of subscription, unsubscription and updates to a model which happened via a WebSocket connection to Cosm. */
@property (nonatomic, weak) id<COSMSubscribableDelegate, COSMModelDelegate> delegate;

///---------------------------------------------------------------------------------------
/// @name Socket Connection
///---------------------------------------------------------------------------------------
@property (readonly) BOOL isSubscribed;

/** Subscribes the model to Cosm. If an attempt to subscribe fails a delegate will be notified via the `modelDidUnsubscribe:withError:` method of the COSMSubscribableDelegate protocol. Once a model is subscribed it will be updated automatically when the relevant feed or datastream is updated on Cosm.
 
  @see COSMSubscribableDelegate */
- (void)subscribe;

/** Unsubscribes the model to Cosm. If an attempt to unsubscribe was intentional and happened without error then the delegate will be notified via the `modelDidUnsubscribe:withError:` method of the COSMSubscribableDelegate protocol but the error object will be `nil`. 
 
  @see COSMSubscribableDelegate */
- (void)unsubscribe;

@end
