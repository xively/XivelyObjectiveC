#import "COSMDatapointCollection.h"
#import "COSMDatapointModel.h"

@implementation COSMDatapointCollection

#pragma mark - Data

@synthesize feedId, info;

#pragma mark - Datapoints

@synthesize datapoints;

#pragma mark - Synchronisation

- (void)fetch {
    
}

- (void)parse:(id)JSON {
    if ([JSON isKindOfClass:[NSDictionary class]])  {
        NSLog(@"@stub: COSMDatapointCollection::parse with JSON of NSDictionary. Not adding any datapoints to collection.");
    } else if ([JSON isKindOfClass:[NSArray class]]) {
        // clear all the previous data
        [self.datapoints removeAllObjects];        // add the data streams
        NSEnumerator *enumerator = [JSON objectEnumerator];
        NSDictionary *datapointData;
        while (datapointData = [enumerator nextObject]) {
            COSMDatapointModel *datapoint = [[COSMDatapointModel alloc] init];
            datapoint.feedId = self.feedId;
            [datapoint parse:datapointData];
            [self.datapoints addObject:datapoint];
        }
    } else {
        //NSLog(@"COSMDatapointCollection::parse: don't know what kind JSON is. Not adding any datapoint to collection.");
    }
}

#pragma mark - Life Cycle

- (id)init {
    if (self=[super init]) {
        self.datapoints = [[NSMutableArray alloc] init];
        self.info = [[NSMutableDictionary alloc] init];
    }
    return self;
}



@end
