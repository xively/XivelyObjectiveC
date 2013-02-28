#import <Foundation/Foundation.h>
#import "COSMRequestable.h"
#import "COSMFeedCollectionDelegate.h"
#import "COSMAPI.h"

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
@property (nonatomic, strong) COSMAPI *api;
@property (weak) id<COSMFeedCollectionDelegate> delegate;
- (void)fetch;

/** Removed any of the COSMFeedModels contained in this collection which have been deleted from Cosm.
 
 After sucessfully deleting a feed from collections feeds this should be called to remove the deleted feed from the collection. */ 
- (void)removeDeletedFromCOSM;

/** Given responce JSON, will convert any JSON representation of COSMFeedModel into the feeds array and place other content into the info dictionary
 
 Should not need to be called directly. Used internally to parse responces from fetch, save, delete and subscribe requests. */
- (void)parse:(id)JSON;

@end
