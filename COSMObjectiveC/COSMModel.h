#import <Foundation/Foundation.h>
#import "COSMRequestable.h"
#import "COSMModelDelegate.h"
#import "COSMAPI.h"

@interface COSMModel : COSMRequestable

///---------------------------------------------------------------------------------------
/// @name Data
///---------------------------------------------------------------------------------------

/** Mutable dictionary of information, if any, about the model.
 
 The info dictionary contains an NSDictionary representation of model minus any child Cosm models. For example a COSMFeedModel's info object will not contain any COSMDatastreamModels and COSMDatapointModel's info object will not contain any COSMDatapointModels */
@property (nonatomic, strong) NSMutableDictionary *info;

///---------------------------------------------------------------------------------------
/// @name State
///---------------------------------------------------------------------------------------

/** Determins if the model exsits on Cosm. Normally by identifiying if it has an id.
 
 Used internally to decide on POST or PUT request when save is called. */
- (BOOL)isNew;

/** Flags a model is deleted so that it may be removed from a parent collection by called `removeDeletedFromCOSM` on any containing collection  */
@property BOOL isDeletedFromCosm;

///---------------------------------------------------------------------------------------
/// @name Synchronisation
///---------------------------------------------------------------------------------------

/** Delegate object which will be notified with the result of any fetch, save or delete requests. */
@property (nonatomic, weak) id<COSMModelDelegate> delegate;

/** The model's reference to a COSMAPI object which should contain an API key to be used for any request operations. 
 
 If an COSMAPI object is not provided directy, the model will use COSMAPI's defaultAPI object. */
@property (nonatomic, strong) COSMAPI *api;

/** Returns the model's resource URL path.
 
 Should not need to be called directly. Used internally to create the request URL string for any fetch, save, delete and subscribe requests. */
- (NSString *)resourceURLString;

/** Parses any responce JSON into models info object and or any collection the model has. 
 
 Should not need to be called directly. Used internally to parse responces from fetch, save, delete and subscribe requests. */
- (void)parse:(id)JSON;

@end
