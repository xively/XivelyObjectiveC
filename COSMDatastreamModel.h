#import "COSMModel.h"
@class COSMDatapointCollection;
// socket
#import "SRWebSocket.h"

@interface COSMDatastreamModel : COSMModel<SRWebSocketDelegate>

// data
@property NSUInteger feedId;
@property (nonatomic, retain) COSMDatapointCollection *datapointCollection;
// returns the info dictionary without any references
// to any datapoints, so that the COSMDatastreamModel
// and COSMFeedModel cannot make edits to any datapoints
- (NSMutableDictionary *)saveableInfo;

// synchronization
- (void)fetch;
- (void)save;
- (void)parse:(id)JSON;
// socket connection
@property (readonly) BOOL isSubscribed;
- (void)subscribe;
- (void)unsubscribe;

@end
