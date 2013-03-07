#import <Foundation/Foundation.h>
#import "COSMDatapointCollectionDelegate.h"
#import "COSMAPI.h"

/** COSMDatapointCollection collection contains a mutable array of COSMDatapointModels. It can also be used to save multiple datapoints to Cosm in one request. */

@interface COSMDatapointCollection : NSObject

///---------------------------------------------------------------------------------------
/// @name Data
///---------------------------------------------------------------------------------------

/** Cosm's id for this datapoints parent feed.
 
 When initalising a COSMDatapointCollection directly the feedId is required to access the correct resource on Cosm's web service.  Using saveAll without the feedId details will cause the delegate method `datapointCollectionDidFailToFetch:withError:json` to fire. */
@property NSUInteger feedId;

/** Cosm's id for this datapoints parent datastream.
 
 When initalising a COSMDatapointCollection directly the datastreamId is required to access the correct resource on Cosm's web service. Using saveAll without the datastreamId details will cause the delegate method `datapointCollectionDidFailToFetch:withError:json` to fire.*/
@property (nonatomic, strong) NSString *datastreamId;

///---------------------------------------------------------------------------------------
/// @name Datapoints
///---------------------------------------------------------------------------------------

/** Mutable array of COSMDatapointModels. */
@property (nonatomic, strong) NSMutableArray *datapoints;

///---------------------------------------------------------------------------------------
/// @name Synchronisation
///---------------------------------------------------------------------------------------

/** The model's reference to a COSMAPI object which should contain an API key to be used for any request operations.
 
 If an COSMAPI object is not provided directy, the model will use COSMAPI's defaultAPI object. */
@property (nonatomic, strong) COSMAPI *api;

/** Delegate object conforming to the COSMDatapointCollectionDelegate protocol which will be notified with the result of any saveAll request. */
@property (nonatomic, weak) id<COSMDatapointCollectionDelegate> delegate;

/** Saves all datapoints contained in the collection to Cosm. The result of the operation will be notified collections delegate using the COSMDatapointCollectionDelegate protocol. 
 
 @see COSMDatapointCollectionDelegate */
- (void)saveAll;

/* Given responce JSON, will convert any JSON representation of COSMDatapointModels into the datapoints array and place other content into the info dictionary 
 
 Should not need to be called directly. Used internally to parse responces from fetch, save, delete and subscribe requests. */
- (void)parse:(id)JSON;

@end
