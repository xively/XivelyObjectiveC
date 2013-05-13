#import <Foundation/Foundation.h>

@class COSMModel;

@protocol COSMModelDelegate <NSObject>

@optional
///---------------------------------------------------------------------------------------
/// @name Fetching
///---------------------------------------------------------------------------------------

/** Tells the delegate that the fetch was successful.
    @param model Reference to the model which was fetch */
- (void)modelDidFetch:(COSMModel *)model;

/** Tells the delegate that the fetch failed.
 @param model Reference to the model which attempted to fetch 
 @param error An error or `nil`
 @param json JSON representation of the error, or a JSON response from Cosm, or `nil` */
- (void)modelFailedToFetch:(COSMModel *)model withError:(NSError*)error json:(id)JSON;

///---------------------------------------------------------------------------------------
/// @name Saving
///---------------------------------------------------------------------------------------

/** Tells the delegate that the save was successful. 
 @param model Reference to the model which was saved */
- (void)modelDidSave:(COSMModel *)model;

/** Tells the delegate that the save failed.
 @param model Reference to the model which attempted to saved 
 @param error An error or `nil`
 @param json JSON representation of the error, or a JSON response from Cosm, or `nil` */
- (void)modelFailedToSave:(COSMModel *)model withError:(NSError*)error json:(id)JSON;

///---------------------------------------------------------------------------------------
/// @name Deleting
///---------------------------------------------------------------------------------------

/** Tells the delegate that the delete was successful.
 @param model Reference to the model which was deleted from Cosm 
 @param error An error or `nil`
 @param json JSON representation of the error, or a JSON response from Cosm, or `nil` */
- (void)modelDidDeleteFromCOSM:(COSMModel *)model;

/** Tells the delegate that the delete was failed.
 @param model Reference to the model which attempted to delete from Cosm 
 @param error An error or `nil`
 @param json JSON representation of the error, or a JSON response from Cosm, or `nil` */
- (void)modelFailedToDeleteFromCOSM:(COSMModel *)model withError:(NSError*)error json:(id)JSON;
@end
