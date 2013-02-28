#import <Foundation/Foundation.h>

@interface COSMDatapointCollection : NSObject

// data
@property NSUInteger feedId;
@property (nonatomic, strong) NSMutableDictionary *info;

// datapoints
@property (nonatomic, strong) NSMutableArray *datapoints;

/// Synchronisation
- (void)parse:(id)JSON;

@end
