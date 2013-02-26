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
@end
