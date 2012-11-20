#import "COSMModel.h"
@class COSMDatapointCollection;

@interface COSMDatastreamModel : COSMModel {
    
}

// data
@property NSUInteger feedId;
@property (nonatomic, retain) COSMDatapointCollection *datapointCollection;

// synchronization
- (void)fetch;
- (void)parse:(id)JSON;

@end
