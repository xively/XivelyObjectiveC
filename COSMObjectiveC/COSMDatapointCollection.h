#import <Foundation/Foundation.h>
#import "COSMDatapointCollectionDelegate.h"
#import "COSMAPI.h"

@interface COSMDatapointCollection : NSObject

///---------------------------------------------------------------------------------------
/// @name Data
///---------------------------------------------------------------------------------------

/** Mutable dictionary of information, if any, about the collection.   
 
 The info dictionary contains an NSDictionary representation of collection minus the datapoints themself. The datapoints will have been parsed into the datapoints property. */
@property (nonatomic, strong) NSMutableDictionary *info;

/** Cosm's id for this datapoints parent feed.
 
 When initalising a COSMDatapointCollection directly the feedId is require inorder for the COSMDatapointCollection access the correct resource for Cosm's webservice. */
@property NSUInteger feedId;

@property (nonatomic, strong) NSString *datastreamId;
///---------------------------------------------------------------------------------------
/// @name Datapoints
///---------------------------------------------------------------------------------------

/** Mutable array of COSMDatapointModel. */
@property (nonatomic, strong) NSMutableArray *datapoints;

///---------------------------------------------------------------------------------------
/// @name Synchronization
///---------------------------------------------------------------------------------------
@property (nonatomic, strong) COSMAPI *api;
@property (nonatomic, weak) id<COSMDatapointCollectionDelegate> delegate;
- (void)saveAll;

/** Given responce JSON, will convert any JSON representation of COSMDatapointModels into the datapoints array and place other content into the info dictionary 
 
 Should not need to be called directly. Used internally to parse responces from fetch, save, delete and subscribe requests. */
- (void)parse:(id)JSON;

@end
