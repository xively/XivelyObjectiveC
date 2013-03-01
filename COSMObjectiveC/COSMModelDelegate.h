#import <Foundation/Foundation.h>

@class COSMModel;

@protocol COSMModelDelegate <NSObject>

@optional
///---------------------------------------------------------------------------------------
/// @name Fetching
///---------------------------------------------------------------------------------------
- (void)modelDidFetch:(COSMModel *)model;
- (void)modelFailedToFetch:(COSMModel *)model withError:(NSError*)error json:(id)JSON;

///---------------------------------------------------------------------------------------
/// @name Saving
///---------------------------------------------------------------------------------------
- (void)modelDidSave:(COSMModel *)model;
- (void)modelFailedToSave:(COSMModel *)model withError:(NSError*)error json:(id)JSON;

///---------------------------------------------------------------------------------------
/// @name Deleting
///---------------------------------------------------------------------------------------
- (void)modelDidDeleteFromCOSM:(COSMModel *)model;
- (void)modelFailedToDeleteFromCOSM:(COSMModel *)model withError:(NSError*)error json:(id)JSON;
@end
