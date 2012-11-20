#import "COSMModel.h"

@interface COSMDatapointModel : COSMModel {
    
}

@property NSUInteger feedId;

// synchronization
- (void)parse:(id)JSON;

@end
