#import "COSMSubscribable.h"
@class COSMDatapointCollection;

/** COSMDatastreamModel is the representation of a datastream on Cosm. It can fetched, saved, deleted, subscribed and unsubscribed to/from Cosm. */

@interface COSMDatastreamModel : COSMSubscribable

///---------------------------------------------------------------------------------------
/// @name Data
///---------------------------------------------------------------------------------------

/** Cosm's id for this datastream's parent feed.
 
 When initalising a COSMDatastreamModel directly the feedId is required to access the correct resource on Cosm's web service.  Using save, fetch or deleteFromCosm without the feedId will notify the model's delegate of failure via the COSMModelDelegate protocol. */
@property NSUInteger feedId;

///---------------------------------------------------------------------------------------
/// @name Datapoints
///---------------------------------------------------------------------------------------

/** Container for the datastreams datapoint */
@property (nonatomic, strong) COSMDatapointCollection *datapointCollection;

///---------------------------------------------------------------------------------------
/// @name Synchronisation
///---------------------------------------------------------------------------------------

/** Fetches the datastream from Cosm. It must have an `id` key in its info dictionary and have its feedId set before fetching the datastream. The result of the operation will be notified to the model's delegate using the COSModelDelegate protocol.
 
 @see COSMModelDelegate */
- (void)fetch;

/** Saves the datastream to Cosm. The result of the operation will be notified to the model's delegate using the COSModelDelegate protocol.
 
 @see COSMModelDelegate */
- (void)save;

/** Deletes the datastream from Cosm. It must have an `id` key in it's info dictionary and have it's feedId set before deleting the datastream. The result of the operation will be notified to the model's delegate using the COSModelDelegate protocol and the model's flag isDeletedFromCosm will be set to true.
 
 @see COSMModelDelegate */
- (void)deleteFromCosm;

- (void)parse:(id)JSON;
@property BOOL isNew;
/* returns the info dictionary without any references
 to any datapoints, so that the COSMDatastreamModel
 and COSMFeedModel cannot make edits to any datapoints */
- (NSMutableDictionary *)saveableInfo;

@end
