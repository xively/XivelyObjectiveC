#import "COSMModel.h"

@interface COSMDatapointModel : COSMModel 

///---------------------------------------------------------------------------------------
/// @name Data
///---------------------------------------------------------------------------------------

/** Cosm's id for this datapoints parent feed. */
@property NSUInteger feedId;
@property (nonatomic, strong) NSString *datastreamId;

///---------------------------------------------------------------------------------------
/// @name Synchronization
///---------------------------------------------------------------------------------------
@property BOOL isNew;
- (void)save;
- (void)fetch;
- (void)deleteFromCosm;
/** Given responce JSON, will convert the JSON responce into the COSMDatapointModel's info as a NSMutableDictionary. 
 
 Should not need to be called directly. Used internally to parse responces from fetch, save and delete requests. */
- (void)parse:(id)JSON;

@end