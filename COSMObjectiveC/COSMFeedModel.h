#import "COSMSubscribable.h"
#import "COSMDatastreamCollection.h"

/** COSMFeedModel is the representation of a feed on Cosm. It can fetched, saved, be deleted, subscribed and unsubscribed from Cosm. */
@interface COSMFeedModel : COSMSubscribable

///---------------------------------------------------------------------------------------
/// @name Data
///---------------------------------------------------------------------------------------

/** Container for the feeds datastreams */
@property (nonatomic, strong) COSMDatastreamCollection *datastreamCollection;

///---------------------------------------------------------------------------------------
/// @name Synchronisation
///---------------------------------------------------------------------------------------

/** Fetches the feed from Cosm. Before fetching it must have an `id` key in it's info dictionary. The result of the operation will be notified to the model's delegate using the COSModelDelegate protocol. 
 
 @see COSMModelDelegate */
- (void)fetch;

/** Saves the feed to Cosm. The result of the operation will be notified to the model's delegate using the COSModelDelegate protocol. 
 
 @see COSMModelDelegate */
- (void)save;

/** Deletes the feed from Cosm. Before deleting the datastream must have an `id` key in it's info dictionary and have it's feedId set.The result of the operation will be notified to the model's delegate using the COSModelDelegate protocol and the models flag isDeletedFromCosm will be set to true. 
 
 @see COSMModelDelegate */
- (void)deleteFromCOSM;

- (void)parse:(id)JSON;
/* returns the info dictionary without any references
 to any datastream that are not mark with `isNew==true`
 this is to prevent the model saving any datastreams which
 have not been created (and may have been updated post-fetch online) */
- (NSMutableDictionary *)saveableInfoWithNewDatastreamsOnly:(BOOL)newOnly;

@end
