#import <Foundation/Foundation.h>

@interface COSMDatastreamCollection : NSObject

// data
@property NSUInteger feedId;
@property (nonatomic, strong) NSMutableDictionary *info;

// datastreams
@property (nonatomic, strong) NSMutableArray *datastreams;

// Synchronisation
- (void)fetch;
- (void)parse:(id)JSON;

@end
