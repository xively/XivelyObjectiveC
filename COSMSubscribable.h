#import <Foundation/Foundation.h>
#import "COSMModel.h"
#import "SRWebSocket.h"

// delegate protocol for subscribing
@protocol COSMSubscribableDelegate <COSMModelDelegate, NSObject> 
@optional
- (void)modelDidSubscribe:(COSMModel *)model;
- (void)modelDidUnsubscribe:(COSMModel *)model;
- (void)modelFailedToSubscribe:(COSMModel *)model withError:(NSError *)error;
- (void)modelFailedToUnsubscribe:(COSMModel *)model withError:(NSError *)error;
- (void)modelUpdatedViaSubscription:(COSMModel *)model;
@end

@interface COSMSubscribable : COSMModel<SRWebSocketDelegate>

@property (nonatomic, weak) id<COSMSubscribableDelegate, COSMModelDelegate> delegate;

// socket connection
@property (readonly) BOOL isSubscribed;
- (void)subscribe;
- (void)unsubscribe;

@end
