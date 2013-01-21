#import "COSMFeedCollection.h"
#import "COSMFeedModel.h"
#import "AFJSONRequestOperation.h"

@implementation COSMFeedCollection

#pragma mark - Lifecycle

- (id)init {
    if (self=[super init]) {
        feeds = [[NSMutableArray alloc] init];
        info = [[NSMutableDictionary alloc] init];
		api = [COSMAPI defaultAPI];
	}
    return self;
}

#pragma mark - Data

@synthesize feeds, info;

- (void)removeDeletedFromCOSM {
    NSMutableArray *deletedItems = [NSMutableArray array];
    COSMFeedModel *feed;
    
    for (feed in feeds) {
        if ([feed isDeletedFromCOSM]) {
            [deletedItems addObject:feed];
        }
    }
    
    [feeds removeObjectsInArray:deletedItems];
}

#pragma mark - Synchronisation

@synthesize api, delegate;

- (void)fetch {
    NSURL *url = [self.api urlForRoute:@"feeds/" withParameters:self.parameters];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:40.0];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            [self parse:JSON];
            if (self.delegate && [self.delegate respondsToSelector:@selector(feedCollectionDidFetch:)]) {
                [self.delegate feedCollectionDidFetch:self];
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            NSLog(@"Error %@", error);
            if (self.delegate && [self.delegate respondsToSelector:@selector(feedCollectionFailedToFetch:withError:json:)]) {
                [self.delegate feedCollectionFailedToFetch:self withError:error json:JSON];
            }
        }];
    [operation start];
}

- (void)parse:(id)JSON {
    // create a deep mutable copy
    NSMutableDictionary * mutableJSON  = (__bridge NSMutableDictionary *)CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)JSON, kCFPropertyListMutableContainers);
    
    [self.feeds removeAllObjects];
    
    NSArray *returnedFeeds = [mutableJSON valueForKeyPath:@"results"];
    NSEnumerator *feedsEnumerator = [returnedFeeds objectEnumerator];
    NSDictionary *feedData;
    while (feedData = [feedsEnumerator nextObject]) {
        COSMFeedModel *feed = [[COSMFeedModel alloc] init];
        [feed parse:feedData];
        [self.feeds addObject:feed];
    }
    
    [mutableJSON removeObjectForKey:@"results"];
    
    self.info = mutableJSON;
}

@end

