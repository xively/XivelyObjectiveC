#import "COSMModel.h"

/** COSMDatapointModel is the representation of a Cosm datastream. It can fetched, saved and deleted from Cosm. */

@interface COSMDatapointModel : COSMModel 

///---------------------------------------------------------------------------------------
/// @name Data
///---------------------------------------------------------------------------------------

/** Cosm's id for the parent feed of this datapoint.
 
 When initalising a COSMDatapointModel directly the feedId is required to access the correct resource on Cosm's web service.  Using save, fetch or deleteFromCosm without the feedId will notify the model's delegate of failure via the COSMModelDelegate protocol. */
@property NSUInteger feedId;

/** Cosm's id for the parent datastream of this datapoint.
 
 When initalising a COSMDatapointModel directly the datastreamId is required to access the correct resource on Cosm's web service.  Using save, fetch or deleteFromCosm without the feedId will notify the model's delegate of failure via the COSMModelDelegate protocol. */
@property (nonatomic, strong) NSString *datastreamId;

///---------------------------------------------------------------------------------------
/// @name Synchronisation
///---------------------------------------------------------------------------------------

/** Saves the datapoint to Cosm. The result of the operation will be notified to the model's delegate using the COSModelDelegate protocol.
 
 @see COSMModelDelegate */
- (void)save;
/** Fetches the datapoint from Cosm. The datapoint's info dictionary must have an "at" key with a timestamp value. The result of the operation will be notified to the model's delegate using the COSModelDelegate protocol.
 
 @see COSMModelDelegate */
- (void)fetch;
/** Deletes the datapoint from Cosm. The result of the operation will be notified to the model's delegate using the COSModelDelegate protocol and the models flag isDeletedFromCosm will be set to true. 
 
 @see COSMModelDelegate */
- (void)deleteFromCosm;

@property BOOL isNew;

/* Given a JSON response, will convert it into the COSMDatapointModel's info as a NSMutableDictionary.
 
 Should not need to be called directly. Used internally to parse responces from fetch, save and delete requests. */
- (void)parse:(id)JSON;

@end