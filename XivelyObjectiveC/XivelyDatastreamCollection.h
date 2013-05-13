#import <Foundation/Foundation.h>

/** XivelyDatastreamCollection contains a mutable array of XivelyDatapointModels.*/

@interface XivelyDatastreamCollection : NSObject

///---------------------------------------------------------------------------------------
/// @name Data
///---------------------------------------------------------------------------------------

/** Mutable dictionary of information about the collection.

 The info dictionary contains an NSDictionary representation of the collection minus the datastreams. The datapoints will have be parsed  into the datastreams property. */
@property (nonatomic, strong) NSMutableDictionary *info;

/** Xively's id for the parent feed of this datastreams collection.

 When initalising a XivelyDatastreamCollection directly the feedId is required in order for the XivelyDatapointCollection to access the correct resource for Xively's web service. */
@property NSUInteger feedId;

///---------------------------------------------------------------------------------------
/// @name Datastreams
///---------------------------------------------------------------------------------------

/** Mutable array of XivelyDatastreamModel. */
@property (nonatomic, strong) NSMutableArray *datastreams;

///---------------------------------------------------------------------------------------
/// @name Synchronisation
///---------------------------------------------------------------------------------------

/* Given responce JSON, will convert any JSON representation of Xively datastream into the datastream array and parse other JSON content into the info dictionary as a NSMutableDictionary.

Should not need to be called directly. Used internally to parse responces from fetch, save and delete requests. */
- (void)parse:(id)JSON;

@end
