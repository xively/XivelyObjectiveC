#import "COSMSubscribable.h"
@class COSMDatapointCollection;

@interface COSMDatastreamModel : COSMSubscribable

// data
@property NSUInteger feedId;
@property (nonatomic, strong) COSMDatapointCollection *datapointCollection;
// returns the info dictionary without any references
// to any datapoints, so that the COSMDatastreamModel
// and COSMFeedModel cannot make edits to any datapoints
- (NSMutableDictionary *)saveableInfo;

// synchronization
- (void)fetch;
- (void)save;
- (void)parse:(id)JSON;
@end
