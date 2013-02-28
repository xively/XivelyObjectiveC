#import "COSMSubscribable.h"
#import "COSMDatastreamCollection.h"

@interface COSMFeedModel : COSMSubscribable {
    
}

// data
@property (nonatomic, strong) COSMDatastreamCollection *datastreamCollection;
// returns the info dictionary without any references
// to any datastream that are not mark with `isNew==true`
// this is to prevent the model saving any datastreams which
// have not been created (and may have been updated post-fetch online)
- (NSMutableDictionary *)saveableInfoWithNewDatastreamsOnly:(BOOL)newOnly;

// synchronization
- (void)fetch;
- (void)save;
- (void)deleteFromCOSM;
- (void)parse:(id)JSON;

@end
