#import <SenTestingKit/SenTestingKit.h>
#import "Xively.h"

#define kAPI_KEY @"LwH31lva9MX0YG84cy3_XKv9z4OSAKx5NDdDYzAzejBHUT0g"

@interface CrudTests : SenTestCase<XivelyFeedCollectionDelegate, XivelySubscribableDelegate, XivelyDatapointCollectionDelegate>

// Feed Collection
@property (nonatomic, strong) XivelyFeedCollection *feedCollection;

// Feed Model
@property (nonatomic, strong) XivelyFeedModel *feedModel;
- (void)testFeedModel;

// Datastream Collection
@property (nonatomic, strong) XivelyDatastreamCollection *datastreamCollection;
- (void)testDatastreamCollection;

// Datastream Model
@property (nonatomic, strong) XivelyDatastreamModel *datastreamModel;
- (void)testDatastreamModel;

// Datapoint Collection
@property (nonatomic, strong) XivelyDatapointCollection *datapointCollection;
- (void)testDatapointCollection;

// Datapoint
@property (nonatomic, strong) XivelyDatapointModel *datapointModel;
- (void)testDatapointModel;

// Locking
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) NSError *errorObj;
@property (nonatomic, strong) id errorJSON;
- (void)reset;

// Feed Collection Delegate
- (void)feedCollectionDidFetch:(XivelyFeedCollection *)feedCollection;
- (void)feedCollectionFailedToFetch:(XivelyFeedCollection *)feedCollection withError:(NSError*)error json:(id)JSON;

// Feed Model Delegate
- (void)modelDidFetch:(XivelyModel *)model;
- (void)modelFailedToFetch:(XivelyModel *)model withError:(NSError*)error json:(id)JSON;

- (void)modelDidSave:(XivelyModel *)model;
- (void)modelFailedToSave:(XivelyModel *)model withError:(NSError*)error json:(id)JSON;

- (void)modelDidDeleteFromXively:(XivelyModel *)model;
- (void)modelFailedToDeleteFromXively:(XivelyModel *)model withError:(NSError*)error json:(id)JSON;

// Datastream Collection Delegate
- (void)datapointCollectionDidSaveAll:(XivelyDatapointCollection *)collection;
- (void)datapointCollectionFailedToSaveAll:(XivelyDatapointCollection *)collection withError:(NSError *)error json:(id)JSON;

@end
