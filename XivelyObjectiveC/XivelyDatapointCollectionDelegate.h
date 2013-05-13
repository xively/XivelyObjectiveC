#import <Foundation/Foundation.h>
@class XivelyDatapointCollection;

@protocol XivelyDatapointCollectionDelegate <NSObject>
@optional
///---------------------------------------------------------------------------------------
/// @name Saving
///---------------------------------------------------------------------------------------

/** Tells the delegate that the save was successful.
 @param collection Reference to the collection which was saved */
- (void)datapointCollectionDidSaveAll:(XivelyDatapointCollection *)collection;

/** Tells the delegate that the save failed.
 @param collection Reference to the collection which attempted to saved
 @param error An error or `nil`
 @param json The JSON representation of the error, a JSON response from Xively or `nil` */
- (void)datapointCollectionFailedToSaveAll:(XivelyDatapointCollection *)collection withError:(NSError *)error json:(id)JSON;
@end
