#import <Foundation/Foundation.h>

@interface COSMDatapointCollection : NSObject

////
/// data

@property NSUInteger feedId;
// datapoints
@property (nonatomic, strong) NSMutableArray *datapoints;
// everything else
@property (nonatomic, strong) NSMutableDictionary *info;

////
/// Synchronisation
- (void)parse:(id)JSON;


@end
