#import "COSMModel.h"
#import "COSMDatastreamCollection.h"

@interface COSMFeedModel : COSMModel {
    
}

// data
@property (nonatomic, retain) COSMDatastreamCollection *datastreamCollection;

// synchronization
- (void)fetch;
- (void)save;
- (void)deleteFromCOSM;
- (void)parse:(id)JSON;

@end
