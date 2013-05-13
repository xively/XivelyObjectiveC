#import <Foundation/Foundation.h>
#import "XivelyModel.h"
#import "SRWebSocket.h"
#import "XivelySubscribableDelegate.h"

/**
 XivelySubscribable, used by XivelyFeedModel and XivelyDatastreamModel, is a base class which allows the model to subscribe to live updates from Xively via a web socket connection.

 When a XivelyFeedModel or XivelyDatastreamModel is subscribed Xively its own data and child collections we be repopulated with data whenever this data changes on Xively. When a model receives an update triggered by Xively its delegate will be notified by the `modelUpdatedViaSubscription:` method.

 @warning *Important:* Web socket connections are not allowed on many mobile networks providers. If the device is running on a mobile connection and attempts to subscribe, the `modelDidUnsubscribe:withError:` may be called immediaely or after a few seconds. */
@interface XivelySubscribable : XivelyModel<SRWebSocketDelegate>

///---------------------------------------------------------------------------------------
/// @name Delegate
///---------------------------------------------------------------------------------------

/** Delegate object which will be notified of subscription, unsubscription and updates to a model which happened via a web socket connection to Xively. */
@property (nonatomic, weak) id<XivelySubscribableDelegate, XivelyModelDelegate> delegate;

///---------------------------------------------------------------------------------------
/// @name Socket Connection
///---------------------------------------------------------------------------------------
@property (readonly) BOOL isSubscribed;

/** Subscribes the model to Xively. If an attempt to subscribe fails a delegate will be notified via the `modelDidUnsubscribe:withError:` method of the XivelySubscribableDelegate protocol. Once a model is subscribed it will be updated automatically when the relevant feed or datastream is updated on Xively.

  @see XivelySubscribableDelegate */
- (void)subscribe;

/** Unsubscribes the model to Xively. If an attempt to unsubscribe was intentional and happened without error then the delegate will be notified via the `modelDidUnsubscribe:withError:` method of the XivelySubscribableDelegate protocol but the error object will be `nil`.

  @see XivelySubscribableDelegate */
- (void)unsubscribe;

@end
