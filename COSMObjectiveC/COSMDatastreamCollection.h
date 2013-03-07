#import <Foundation/Foundation.h>

/** COSMDatastreamCollection collection contains a mutable array of COSMDatapointModels.*/

@interface COSMDatastreamCollection : NSObject

///---------------------------------------------------------------------------------------
/// @name Data
///---------------------------------------------------------------------------------------

/** Mutable dictionary of information, if any, about the collection. 
 
 The info dictionary contains an NSDictionary representation of collection minus the datastreams themself. The datapoints will have be parsed  into the datastreams property. */
@property (nonatomic, strong) NSMutableDictionary *info;

/** Cosm's id for this collection of datastream's parent feed.
 
 When initalising a COSMDatastreamCollection directly the feedId is require inorder for the COSMDatapointCollection to access the correct resource for Cosm's webservice. */
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
