#import <SenTestingKit/SenTestingKit.h>
#import "COSM.h"

#define kAPI_KEY @"LwH31lva9MX0YG84cy3_XKv9z4OSAKx5NDdDYzAzejBHUT0g"

@interface CrudTests : SenTestCase<COSMFeedCollectionDelegate, COSMSubscribableDelegate, COSMDatapointCollectionDelegate>

// Feed Collection
@property (nonatomic, strong) COSMFeedCollection *feedCollection;

// Feed Model
@property (nonatomic, strong) COSMFeedModel *feedModel;
- (void)testFeedModel;

// Datastream Collection
@property (nonatomic, strong) COSMDatastreamCollection *datastreamCollection;
- (void)testDatastreamCollection;

// Datastream Model
@property (nonatomic, strong) COSMDatastreamModel *datastreamModel;
- (void)testDatastreamModel;

// Datapoint Collection
@property (nonatomic, strong) COSMDatapointCollection *datapointCollection;
- (void)testDatapointCollection;

// Datapoint
@property (nonatomic, strong) COSMDatapointModel *datapointModel;
- (void)testDatapointModel;

// Locking
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) NSError *errorObj;
@property (nonatomic, strong) id errorJSON;
- (void)reset;

// Feed Collection Delegate
- (void)feedCollectionDidFetch:(COSMFeedCollection *)feedCollection;
- (void)feedCollectionFailedToFetch:(COSMFeedCollection *)feedCollection withError:(NSError*)error json:(id)JSON;

// Feed Model Delegate
- (void)modelDidFetch:(COSMModel *)model;
- (void)modelFailedToFetch:(COSMModel *)model withError:(NSError*)error json:(id)JSON;

- (void)modelDidSave:(COSMModel *)model;
- (void)modelFailedToSave:(COSMModel *)model withError:(NSError*)error json:(id)JSON;

- (void)modelDidDeleteFromCOSM:(COSMModel *)model;
- (void)modelFailedToDeleteFromCOSM:(COSMModel *)model withError:(NSError*)error json:(id)JSON;

// Datastream Collection Delegate
- (void)datapointCollectionDidSaveAll:(COSMDatapointCollection *)collection;
- (void)datapointCollectionFailedToSaveAll:(COSMDatapointCollection *)collection withError:(NSError *)error json:(id)JSON;

@end
