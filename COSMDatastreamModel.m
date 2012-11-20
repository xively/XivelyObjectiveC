#import "COSMDatastreamModel.h"
#import "COSMDatapointCollection.h"
#import "COSMDatapointModel.h"
#import "AFJSONRequestOperation.h"

@implementation COSMDatastreamModel

@synthesize datapointCollection, feedId;

#pragma mark - Life cycle

-(id)init {
    if (self = [super init]) {
		self.api = [COSMAPI defaultAPI];
        self.datapointCollection = [[COSMDatapointCollection alloc] init];
        required = @[
            @"id",
            @"current_value"
        ];
    }
    return self;
}

#pragma mark - Synchronization

- (void)fetch {
    NSURL *url = [self.api urlForRoute:[NSString stringWithFormat:@"feeds/%d/datastreams/%@", self.feedId, [self.info valueForKeyPath:@"id"]] withParameters:self.parameters];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                            [self parse:JSON];
                            if (self.delegate && [self.delegate respondsToSelector:@selector(modelDidFetch:)]) {
                                [self.delegate modelDidFetch:self];
                            }
                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                            NSLog(@"Error %@", error);
                            if (self.delegate && [self.delegate respondsToSelector:@selector(modelFailedToFetch:withError:json:)]) {
                                [self.delegate modelFailedToFetch:self withError:error json:JSON];
                            }
                        }];
    [operation start];
}

- (void)parse:(id)JSON {
    NSMutableDictionary * mutableJSON = [NSMutableDictionary dictionaryWithDictionary:JSON];
    [self.datapointCollection.datapoints removeAllObjects];
    NSArray *returnedDatastreams = [mutableJSON valueForKeyPath:@"datapoints"];
    [self.datapointCollection parse:returnedDatastreams];
    [mutableJSON removeObjectForKey:@"datastreams"];
    self.info = mutableJSON;
    self.isNew = NO;
}

@end
