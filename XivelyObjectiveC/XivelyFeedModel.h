#import "XivelySubscribable.h"
#import "XivelyDatastreamCollection.h"

/** XivelyFeedModel is the representation of a feed on Xively. It can be fetched, saved, deleted, subscribed and unsubscribed to/from Xively. */
@interface XivelyFeedModel : XivelySubscribable

///---------------------------------------------------------------------------------------
/// @name Data
///---------------------------------------------------------------------------------------

/** Container for the feeds datastreams */
@property (nonatomic, strong) XivelyDatastreamCollection *datastreamCollection;

///---------------------------------------------------------------------------------------
/// @name Synchronisation
///---------------------------------------------------------------------------------------

/** Fetches the feed from Xively. It must have an `id` key in its info dictionary before fetching. The result of the operation will be notified to the model's delegate using the XivelyodelDelegate protocol.

 @see XivelyModelDelegate */
- (void)fetch;

/** Saves the feed to Xively. The result of the operation will be notified to the model's delegate using the XivelyodelDelegate protocol.

 @see XivelyModelDelegate */
- (void)save;

/** Deletes the feed from Xively. It must have an `id` key in its info dictionary and have its feedId set. The result of the operation will be notified to the model's delegate using the XivelyodelDelegate protocol and the model's flag isDeletedFromXively will be set to true.

 @see XivelyModelDelegate */
- (void)deleteFromXively;

- (void)parse:(id)JSON;
/* returns the info dictionary without any references
 to any datastream that are not mark with `isNew==true`
 this is to prevent the model saving any datastreams which
 have not been created (and may have been updated post-fetch online) */
- (NSMutableDictionary *)saveableInfoWithNewDatastreamsOnly:(BOOL)newOnly;

@end
