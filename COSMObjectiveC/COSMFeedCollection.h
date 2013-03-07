#import <Foundation/Foundation.h>
#import "COSMRequestable.h"
#import "COSMFeedCollectionDelegate.h"
#import "COSMAPI.h"

/** COSMFeedCollection contains a mutable array of COSMFeedModels. It can also be used to fetch mutliple feeds in a single request. Feed filter or search parameters may be added via COSMRequestable */

@interface COSMFeedCollection : COSMRequestable

///---------------------------------------------------------------------------------------
/// @name Data
///---------------------------------------------------------------------------------------

/** Mutable dictionary of information, if any, about the collection.
 
 The info dictionary contains an NSDictionary representation of the collection minus the feeds themselves. The feeds will have been parsed into the datapoints property. */
@property (nonatomic, strong) NSMutableDictionary *info;

///---------------------------------------------------------------------------------------
/// @name Feeds
///---------------------------------------------------------------------------------------

/** Mutable array of COSMFeedModel. */
@property (nonatomic, strong) NSMutableArray *feeds;

///---------------------------------------------------------------------------------------
/// @name Synchronisation
///---------------------------------------------------------------------------------------

/** The model's reference to a COSMAPI object containing an API key to be used for any request operations.
 
 If a COSMAPI object is not provided directy the model will use COSMAPI's defaultAPI object. */
@property (nonatomic, strong) COSMAPI *api;

/** Delegate object conforming to the COSMFeedCollectionDelegate protocol which will be notified with the result of any fetch requests. */
@property (weak) id<COSMFeedCollectionDelegate> delegate;

/** Fetches feeds from Cosm. Parameters for the fetch can be set using the `useParameter:withValue:` The result of the operation will be notified to the collections delegate using the COSMDatapointCollectionDelegate protocol. 
 
 @see COSMFeedCollectionDelegate */
- (void)fetch;

/** Convenience method to remove COSMFeedModels deleted on Cosm from the collection  */ 
- (void)removeDeleted;

/* Given a JSOn response it will convert any JSON representation of COSMFeedModel into the feeds array and place other content into the info dictionary
 
 Should not need to be called directly. Used internally to parse responces from fetch, save, delete and subscribe requests. */
- (void)parse:(id)JSON;

@end
