#import "COSMSubscribable.h"
@class COSMDatapointCollection;

@interface COSMDatastreamModel : COSMSubscribable

// data
@property NSUInteger feedId;

// datapoints
@property (nonatomic, strong) COSMDatapointCollection *datapointCollection;

// synchronization
- (void)fetch;
- (void)save;
- (void)parse:(id)JSON;
/// returns the info dictionary without any references
/// to any datapoints, so that the COSMDatastreamModel
/// and COSMFeedModel cannot make edits to any datapoints
- (NSMutableDictionary *)saveableInfo;

@end
