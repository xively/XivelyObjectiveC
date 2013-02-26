#import "COSMModel.h"

@interface COSMDatapointModel : COSMModel {
    
}

@property NSUInteger feedId;

// socket connection
- (void)subscribe;
- (void)unsubscribe;

// synchronization
- (void)parse:(id)JSON;

@end