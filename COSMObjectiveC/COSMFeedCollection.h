#import <Foundation/Foundation.h>
#import "COSMRequestable.h"
#import "COSMFeedCollectionDelegate.h"
#import "COSMAPI.h"

/** COSMFeedCollection collection contains a mutable array of COSMFeedModels. It can also be used to fetch mutliple feeds in one request. It can also have parameters added to it (via COSMRequestable) so it may filter / search the feeds requested. */

@interface COSMFeedCollection : COSMRequestable

///---------------------------------------------------------------------------------------
/// @name Data
///---------------------------------------------------------------------------------------

/** Mutable dictionary of information, if any, about the collection.
 
 The info dictionary contains an NSDictionary representation of collection minus the feeds themself. The feeds will have been parsed into the datapoints property. */
@property (nonatomic, strong) NSMutableDictionary *info;

///---------------------------------------------------------------------------------------
/// @name Feeds
///---------------------------------------------------------------------------------------

/** Mutable array of COSMFeedModel. */
@property (nonatomic, strong) NSMutableArray *feeds;

///---------------------------------------------------------------------------------------
/// @name Synchronisation
///---------------------------------------------------------------------------------------

/** The model's reference to a COSMAPI object which should contain an API key to be used for any request operations.
 
 If an COSMAPI object is not provided directy, the model will use COSMAPI's defaultAPI object. */
@property (nonatomic, strong) COSMAPI *api;

/** Delegate object conforming to the COSMFeedCollectionDelegate protocol which will be notified with the result of any fetch requests. */
@property (weak) id<COSMFeedCollectionDelegate> delegate;

/** Fetchs feeds Cosm. Parameters for the fetch can be set using the `useParameter:withValue:` The result of the operation will be notified collections delegate using the COSMDatapointCollectionDelegate protocol. 
 
 @see COSMFeedCollectionDelegate */
- (void)fetch;

/** Convience method for removing any COSMFeedModels which have been deleted from Cosm from the collection.*/ 
- (void)removeDeleted;

/* Given responce JSON, will convert any JSON representation of COSMFeedModel into the feeds array and place other content into the info dictionary
 
 Should not need to be called directly. Used internally to parse responces from fetch, save, delete and subscribe requests. */
- (void)parse:(id)JSON;

@end
