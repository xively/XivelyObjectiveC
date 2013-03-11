#import <Foundation/Foundation.h>
#import "COSMRequestable.h"
#import "COSMModelDelegate.h"
#import "COSMAPI.h"

/** COSMModel is the base class for individual feeds, datastreams and datapoints. */

@interface COSMModel : COSMRequestable

///---------------------------------------------------------------------------------------
/// @name Data
///---------------------------------------------------------------------------------------

/** Mutable dictionary of information about the model.
 
 The info dictionary contains an NSDictionary representation of model minus any child Cosm models. For example a COSMFeedModel's info object will not contain any COSMDatastreamModels and a COSMDatapointModel's info object will not contain any COSMDatapointModels */
@property (nonatomic, strong) NSMutableDictionary *info;

///---------------------------------------------------------------------------------------
/// @name State
///---------------------------------------------------------------------------------------

/** Determines or indicates if the model exists on Cosm. 
 
 Also used internally to decide whether to use a POST or PUT request when save is called for feeds and datastreams. */
- (BOOL)isNew;

/** Flags a model as deleted so that it may be removed from a parent collection by called `removeDeletedFromCOSM` on any containing collection. */
@property BOOL isDeletedFromCosm;

///---------------------------------------------------------------------------------------
/// @name Synchronisation
///---------------------------------------------------------------------------------------

/** Delegate object which will be notified with the result of any fetch, save or delete requests. */
@property (nonatomic, weak) id<COSMModelDelegate> delegate;

/** The model's reference to a COSMAPI object. It should contain an API key to be used for any request operations.
 
 If a COSMAPI object is not provided directy the model will use COSMAPI's defaultAPI object. */
@property (nonatomic, strong) COSMAPI *api;

/* Returns the model's resource URL path.
 
 Should not need to be called directly. Used internally to create the request URL string for any fetch, save, delete and subscribe requests. */
- (NSString *)resourceURLString;

/* Parses any response JSON into the model's info object and that of any collection the model has.
 
 Should not need to be called directly. Used internally to parse responses from fetch, save, delete and subscribe requests. */
- (void)parse:(id)JSON;

@end
