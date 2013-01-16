#import <Foundation/Foundation.h>

@interface COSMDatastreamCollection : NSObject

////
/// data

@property NSUInteger feedId;
// datastreams
@property (nonatomic, strong) NSMutableArray *datastreams;
// everything else
@property (nonatomic, strong) NSMutableDictionary *info;

////
/// Synchronisation
- (void)fetch;
- (void)parse:(id)JSON;


@end
