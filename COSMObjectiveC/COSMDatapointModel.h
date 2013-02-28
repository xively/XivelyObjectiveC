#import "COSMModel.h"

@interface COSMDatapointModel : COSMModel {
    
}

// Data
@property NSUInteger feedId;

// Synchronization
- (void)parse:(id)JSON;

@end