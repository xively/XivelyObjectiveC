#import <Foundation/Foundation.h>

/** COSMDatastreamCollection contains a mutable array of COSMDatapointModels.*/

@interface COSMDatastreamCollection : NSObject

///---------------------------------------------------------------------------------------
/// @name Data
///---------------------------------------------------------------------------------------

/** Mutable dictionary of information (if present) about the collection. 
 
 The info dictionary contains an NSDictionary representation of the collection minus the datastreams. The datapoints will have be parsed  into the datastreams property. */
@property (nonatomic, strong) NSMutableDictionary *info;

/** Cosm's id for the parent feed of this datastreams collection.
 
 When initalising a COSMDatastreamCollection directly the feedId is required in order for the COSMDatapointCollection to access the correct resource for Cosm's web service. */
@property NSUInteger feedId;

///---------------------------------------------------------------------------------------
/// @name Datastreams
///---------------------------------------------------------------------------------------

/** Mutable array of COSMDatastreamModel. */
@property (nonatomic, strong) NSMutableArray *datastreams;

///---------------------------------------------------------------------------------------
/// @name Synchronisation
///---------------------------------------------------------------------------------------

/* Given responce JSON, will convert any JSON representation of Cosm datastream into the datastream array and parse other JSON content into the info dictionary as a NSMutableDictionary.
 
Should not need to be called directly. Used internally to parse responces from fetch, save and delete requests. */
- (void)parse:(id)JSON;

@end
