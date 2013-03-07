#import "COSMSubscribable.h"
#import "COSMDatastreamCollection.h"

/** COSMFeedModel is the representation of a feed on Cosm. It can fetched, saved, deleted, subscribed and unsubscribed to/from Cosm. */
@interface COSMFeedModel : COSMSubscribable

///---------------------------------------------------------------------------------------
/// @name Data
///---------------------------------------------------------------------------------------

/** Container for the feeds datastreams */
@property (nonatomic, strong) COSMDatastreamCollection *datastreamCollection;

///---------------------------------------------------------------------------------------
/// @name Synchronisation
///---------------------------------------------------------------------------------------

/** Fetches the feed from Cosm. It must have an `id` key in its info dictionary before fetching. The result of the operation will be notified to the model's delegate using the COSModelDelegate protocol.
 
 @see COSMModelDelegate */
- (void)fetch;

/** Saves the feed to Cosm. The result of the operation will be notified to the model's delegate using the COSModelDelegate protocol.
 
 @see COSMModelDelegate */
- (void)save;

/** Deletes the feed from Cosm. It must have an `id` key in its info dictionary and have its feedId set. The result of the operation will be notified to the model's delegate using the COSModelDelegate protocol and the model's flag isDeletedFromCosm will be set to true. 
 
 @see COSMModelDelegate */
- (void)deleteFromCOSM;

- (void)parse:(id)JSON;
/* returns the info dictionary without any references
 to any datastream that are not mark with `isNew==true`
 this is to prevent the model saving any datastreams which
 have not been created (and may have been updated post-fetch online) */
- (NSMutableDictionary *)saveableInfoWithNewDatastreamsOnly:(BOOL)newOnly;

@end
