#import <Foundation/Foundation.h>
#import "XivelyModelDelegate.h"
#import "XivelyModel.h"

@protocol XivelySubscribableDelegate <XivelyModelDelegate, NSObject>
@optional

///---------------------------------------------------------------------------------------
/// @name Subscribing and unsubscribing
///---------------------------------------------------------------------------------------

/** Tells the delegate that the subscribe was successful.
 @param model Reference to the model which was subscribed */
- (void)modelDidSubscribe:(XivelyModel *)model;

/** Tells the delegate the the model was unsubscribed
 @param model Reference to the model which was subscribed
 @param error An error or `nil`
 @warning Many mobile operator do not allow web sockets. *
 */
- (void)modelDidUnsubscribe:(XivelyModel *)model withError:(NSError *)error;

///---------------------------------------------------------------------------------------
/// @name Updates
///---------------------------------------------------------------------------------------

/** Tells the delegate that an update was made to the model via the subscription.
 @param model Reference to the model which was subscribed
 @warning New datastreams and/or datapoints will be created when the model is updated. Therefore any previous info and/or feeds and datastreams will be dereferenced by the model. *
 */
- (void)modelUpdatedViaSubscription:(XivelyModel *)model;
@end
