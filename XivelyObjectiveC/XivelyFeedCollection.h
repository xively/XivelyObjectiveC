#import <Foundation/Foundation.h>
#import "XivelyRequestable.h"
#import "XivelyFeedCollectionDelegate.h"
#import "XivelyAPI.h"

/** XivelyFeedCollection contains a mutable array of XivelyFeedModels. It can also be used to fetch mutliple feeds in a single request. Feed filters may be added via XivelyRequestable's `useParameter:withValue` */

@interface XivelyFeedCollection : XivelyRequestable

///---------------------------------------------------------------------------------------
/// @name Data
///---------------------------------------------------------------------------------------

/** Mutable dictionary of information about the collection.

 The info dictionary contains an NSDictionary representation of the collection minus the feeds themselves. The feeds will have been parsed into the datapoints property. */
@property (nonatomic, strong) NSMutableDictionary *info;

///---------------------------------------------------------------------------------------
/// @name Feeds
///---------------------------------------------------------------------------------------

/** Mutable array of XivelyFeedModel. */
@property (nonatomic, strong) NSMutableArray *feeds;

///---------------------------------------------------------------------------------------
/// @name Synchronisation
///---------------------------------------------------------------------------------------

/** The model's reference to a XivelyAPI object containing an API key to be used for any request operations.

 If a XivelyAPI object is not provided directy the model will use XivelyAPI's defaultAPI object. */
@property (nonatomic, strong) XivelyAPI *api;

/** Delegate object conforming to the XivelyFeedCollectionDelegate protocol which will be notified with the result of any fetch requests. */
@property (weak) id<XivelyFeedCollectionDelegate> delegate;

/** Fetches feeds from Xively. Parameters for the fetch can be set using the `useParameter:withValue:` The result of the operation will be notified to the collections delegate using the XivelyDatapointCollectionDelegate protocol.

 @see XivelyFeedCollectionDelegate */
- (void)fetch;

/** Convenience method to remove XivelyFeedModels deleted on Xively from the collection  */
- (void)removeDeleted;

/* Given a JSOn response it will convert any JSON representation of XivelyFeedModel into the feeds array and place other content into the info dictionary

 Should not need to be called directly. Used internally to parse responces from fetch, save, delete and subscribe requests. */
- (void)parse:(id)JSON;

@end
