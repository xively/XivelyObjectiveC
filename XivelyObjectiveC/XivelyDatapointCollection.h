#import <Foundation/Foundation.h>
#import "XivelyDatapointCollectionDelegate.h"
#import "XivelyAPI.h"

/** The XivelyDatapointCollection contains a mutable array of XivelyDatapointModels. It can also be used to save multiple datapoints to Xively in one request. */

@interface XivelyDatapointCollection : NSObject

///---------------------------------------------------------------------------------------
/// @name Data
///---------------------------------------------------------------------------------------

/** Xively's id for this datapoints parent feed.

 When initalising a XivelyDatapointCollection directly the feedId is required to access the correct resource on Xively's web service.  Using saveAll without the feedId details will cause the delegate method `datapointCollectionDidFailToFetch:withError:json` to fire. */
@property NSUInteger feedId;

/** Xively's id for this datapoints parent datastream.

 When initalising a XivelyDatapointCollection directly the datastreamId is required to access the correct resource on Xively's web service. Using saveAll without the datastreamId details will cause the delegate method `datapointCollectionDidFailToFetch:withError:json` to fire. */
@property (nonatomic, strong) NSString *datastreamId;

///---------------------------------------------------------------------------------------
/// @name Datapoints
///---------------------------------------------------------------------------------------

/** Mutable array of XivelyDatapointModels. */
@property (nonatomic, strong) NSMutableArray *datapoints;

///---------------------------------------------------------------------------------------
/// @name Synchronisation
///---------------------------------------------------------------------------------------

/** The model's reference to a XivelyAPI object. The referenced XivelyAPI object should contain the API key to be used for any request operations.

 If a XivelyAPI object is not provided directy the model will use XivelyAPI's defaultAPI object. */
@property (nonatomic, strong) XivelyAPI *api;

/** Delegate object conforming to the XivelyDatapointCollectionDelegate protocol which will be notified with the result of any saveAll request. */
@property (nonatomic, weak) id<XivelyDatapointCollectionDelegate> delegate;

/** Saves all new datapoints contained in the collection to Xively. The result of the operation will be notified to the collections delegate using the XivelyDatapointCollectionDelegate protocol.

 @see XivelyDatapointCollectionDelegate */
- (void)save;

/* Given a JSON response will convert any JSON representation of XivelyDatapointModels into the datapoints array and place other content into the info dictionary.

 Should not need to be called directly. Used internally to parse responces from fetch, save, delete and subscribe requests. */
- (void)parse:(id)JSON;

@end
