#import "XivelyModel.h"

/** XivelyDatapointModel is the representation of a Xively datastream. It can fetched, saved and deleted from Xively. */

@interface XivelyDatapointModel : XivelyModel

///---------------------------------------------------------------------------------------
/// @name Data
///---------------------------------------------------------------------------------------

/** Xively's id for the parent feed of this datapoint.

 When initalising a XivelyDatapointModel directly the feedId is required to access the correct resource on Xively's web service.  Using save, fetch or deleteFromXively without the feedId will notify the model's delegate of failure via the XivelyModelDelegate protocol. */
@property NSUInteger feedId;

/** Xively's id for the parent datastream of this datapoint.

 When initalising a XivelyDatapointModel directly the datastreamId is required to access the correct resource on Xively's web service.  Using save, fetch or deleteFromXively without the feedId will notify the model's delegate of failure via the XivelyModelDelegate protocol. */
@property (nonatomic, strong) NSString *datastreamId;

///---------------------------------------------------------------------------------------
/// @name Synchronisation
///---------------------------------------------------------------------------------------

/** Saves the datapoint to Xively. The result of the operation will be notified to the model's delegate using the XivelyodelDelegate protocol.

 @see XivelyModelDelegate */
- (void)save;
/** Fetches the datapoint from Xively. The datapoint's info dictionary must have an "at" key with a timestamp value. The result of the operation will be notified to the model's delegate using the XivelyodelDelegate protocol.

 @see XivelyModelDelegate */
- (void)fetch;
/** Deletes the datapoint from Xively. The result of the operation will be notified to the model's delegate using the XivelyodelDelegate protocol and the models flag isDeletedFromXively will be set to true.

 @see XivelyModelDelegate */
- (void)deleteFromXively;

@property BOOL isNew;

/* Given a JSON response, will convert it into the XivelyDatapointModel's info as a NSMutableDictionary.

 Should not need to be called directly. Used internally to parse responces from fetch, save and delete requests. */
- (void)parse:(id)JSON;

@end
