#import <Foundation/Foundation.h>

@class COSMModel;

@protocol COSMModelDelegate <NSObject>

@optional
- (void)modelDidFetch:(COSMModel *)model;
- (void)modelFailedToFetch:(COSMModel *)model withError:(NSError*)error json:(id)JSON;

- (void)modelDidSave:(COSMModel *)model;
- (void)modelFailedToSave:(COSMModel *)model withError:(NSError*)error json:(id)JSON;

- (void)modelDidDeleteFromCOSM:(COSMModel *)model;
- (void)modelFailedToDeleteFromCOSM:(COSMModel *)model withError:(NSError*)error json:(id)JSON;

- (void)modelDidSubscribe:(COSMModel *)model;
- (void)modelDidUnsubscribe:(COSMModel *)model;
- (void)modelFailedToSubscribe:(COSMModel *)model withError:(NSError *)error;
- (void)modelFailedToUnsubscribe:(COSMModel *)model withError:(NSError *)error;
- (void)modelUpdatedViaSubscription:(COSMModel *)model;
@end
