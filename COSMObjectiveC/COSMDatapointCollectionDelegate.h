#import <Foundation/Foundation.h>
@class COSMDatapointCollection;

@protocol COSMDatapointCollectionDelegate <NSObject>
@optional
///---------------------------------------------------------------------------------------
/// @name Saving
///---------------------------------------------------------------------------------------

/** Tells the delegate that the save was successful.
 @param collection Reference to the collection which was saved */
- (void)datapointCollectionDidSaveAll:(COSMDatapointCollection *)collection;

/** Tells the delegate that the save failed.
 @param collection Reference to the collection which attempted to saved
 @param error An error or `nil`
 @param json The JSON representation of the error, a JSON response from Cosm or `nil` */
- (void)datapointCollectionFailedToSaveAll:(COSMDatapointCollection *)collection withError:(NSError *)error json:(id)JSON;
@end
