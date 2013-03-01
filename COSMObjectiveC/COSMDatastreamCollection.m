#import "COSMDatastreamCollection.h"
#import "COSMDatastreamModel.h"

@implementation COSMDatastreamCollection

#pragma mark - Data

@synthesize feedId, info;

#pragma mark - Datastreams

@synthesize datastreams;

#pragma mark - Synchronisation

- (void)parse:(id)JSON {
    
    if (JSON == NULL) {
        
    } else if ([JSON isKindOfClass:[NSDictionary class]])  {
        NSLog(@"@stub: COSMDatastreamCollection::parse with JSON of NSDictionary. Not adding and data streams to collection.");
    } else if ([JSON isKindOfClass:[NSArray class]]) {
        // clear all the previous data
        [self.datastreams removeAllObjects];
        [info removeAllObjects];
        // add the data streams
        NSEnumerator *enumerator = [JSON objectEnumerator];
        NSDictionary *datastreamData;
        while (datastreamData = [enumerator nextObject]) {
            COSMDatastreamModel *datastream = [[COSMDatastreamModel alloc] init];
            datastream.feedId = self.feedId;
            [datastream parse:datastreamData];
            [self.datastreams addObject:datastream];
        }
    } else {
        NSLog(@"COSMDatastreamCollection::parse: don't know what kind JSON is. Not adding and datastreams to collection.");
        NSLog(@"COSMDatastreamCollection::parse %@", [JSON class]);
        NSLog(@"%@", JSON);
    }
}

#pragma mark - Life Cycle

- (id)init {
    if (self=[super init]) {
        self.datastreams = [[NSMutableArray alloc] init];
        self.info = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end
