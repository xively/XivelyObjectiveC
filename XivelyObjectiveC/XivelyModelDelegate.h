#import <Foundation/Foundation.h>

@class XivelyModel;

@protocol XivelyModelDelegate <NSObject>

@optional
///---------------------------------------------------------------------------------------
/// @name Fetching
///---------------------------------------------------------------------------------------

/** Tells the delegate that the fetch was successful.
    @param model Reference to the model which was fetch */
- (void)modelDidFetch:(XivelyModel *)model;

/** Tells the delegate that the fetch failed.
 @param model Reference to the model which attempted to fetch
 @param error An error or `nil`
 @param json JSON representation of the error, or a JSON response from Xively, or `nil` */
- (void)modelFailedToFetch:(XivelyModel *)model withError:(NSError*)error json:(id)JSON;

///---------------------------------------------------------------------------------------
/// @name Saving
///---------------------------------------------------------------------------------------

/** Tells the delegate that the save was successful.
 @param model Reference to the model which was saved */
- (void)modelDidSave:(XivelyModel *)model;

/** Tells the delegate that the save failed.
 @param model Reference to the model which attempted to saved
 @param error An error or `nil`
 @param json JSON representation of the error, or a JSON response from Xively, or `nil` */
- (void)modelFailedToSave:(XivelyModel *)model withError:(NSError*)error json:(id)JSON;

///---------------------------------------------------------------------------------------
/// @name Deleting
///---------------------------------------------------------------------------------------

/** Tells the delegate that the delete was successful.
 @param model Reference to the model which was deleted from Xively
 @param error An error or `nil`
 @param json JSON representation of the error, or a JSON response from Xively, or `nil` */
- (void)modelDidDeleteFromXively:(XivelyModel *)model;

/** Tells the delegate that the delete was failed.
 @param model Reference to the model which attempted to delete from Xively
 @param error An error or `nil`
 @param json JSON representation of the error, or a JSON response from Xively, or `nil` */
- (void)modelFailedToDeleteFromXively:(XivelyModel *)model withError:(NSError*)error json:(id)JSON;
@end
