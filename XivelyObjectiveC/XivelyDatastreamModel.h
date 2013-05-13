#import "XivelySubscribable.h"
@class XivelyDatapointCollection;

/** XivelyDatastreamModel is the representation of a datastream on Xively. It can fetched, saved, deleted, subscribed and unsubscribed to/from Xively. */

@interface XivelyDatastreamModel : XivelySubscribable

///---------------------------------------------------------------------------------------
/// @name Data
///---------------------------------------------------------------------------------------

/** Xively's id for this datastream's parent feed.

 When initalising a XivelyDatastreamModel directly the feedId is required to access the correct resource on Xively's web service.  Using save, fetch or deleteFromXively without the feedId will notify the model's delegate of failure via the XivelyModelDelegate protocol. */
@property NSUInteger feedId;

///---------------------------------------------------------------------------------------
/// @name Datapoints
///---------------------------------------------------------------------------------------

/** Container for the datastream's datapoint */
@property (nonatomic, strong) XivelyDatapointCollection *datapointCollection;

///---------------------------------------------------------------------------------------
/// @name Synchronisation
///---------------------------------------------------------------------------------------

/** Fetches the datastream from Xively. It must have an `id` key in its info dictionary and have its feedId set before fetching the datastream. The result of the operation will be notified to the model's delegate using the XivelyodelDelegate protocol.

 @see XivelyModelDelegate */
- (void)fetch;

/** Saves the datastream to Xively. The result of the operation will be notified to the model's delegate using the XivelyodelDelegate protocol.

 @see XivelyModelDelegate */
- (void)save;

/** Deletes the datastream from Xively. It must have an `id` key in it's info dictionary and have it's feedId set before deleting the datastream. The result of the operation will be notified to the model's delegate using the XivelyodelDelegate protocol and the model's flag isDeletedFromXively will be set to true.

 @see XivelyModelDelegate */
- (void)deleteFromXively;

- (void)parse:(id)JSON;
@property BOOL isNew;
/* returns the info dictionary without any references
 to any datapoints, so that the XivelyDatastreamModel
 and XivelyFeedModel cannot make edits to any datapoints */
- (NSMutableDictionary *)saveableInfo;

@end
