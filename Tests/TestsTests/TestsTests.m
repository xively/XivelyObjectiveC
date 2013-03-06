#import "TestsTests.h"

@implementation TestsTests

#pragma mark - Setup up / Tear down

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

#pragma mark - Feed Collection

@synthesize feedCollection;

- (void)testFeedCollection {
    
    /////
    //// Test without api key
    ///
    
    self.semaphore = dispatch_semaphore_create(0);
    
    [[COSMAPI defaultAPI] setApiKey:nil];
    self.feedCollection = [[COSMFeedCollection alloc] init];
    self.feedCollection.delegate = self;
    [self.feedCollection fetch];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }

    STAssertTrue(self.errorObj || self.errorJSON, @"Errors returned fetching feeds without api key");
    [self reset];
    
    /////
    //// Test with default api key
    ///
    
    self.semaphore = dispatch_semaphore_create(0);
    [[COSMAPI defaultAPI] setApiKey:kAPI_KEY];

    self.feedCollection = [[COSMFeedCollection alloc] init];
    self.feedCollection.delegate = self;
    [self.feedCollection fetch];

    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }

    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned fetching feeds with api key");
    STAssertTrue(self.feedCollection.feeds.count > 0, @"Feed collection has feeds");

    [self reset];
    
    /////
    //// Test with custom api key
    ///
    
    self.semaphore = dispatch_semaphore_create(0);
    [[COSMAPI defaultAPI] setApiKey:nil];
    COSMAPI *customAPI = [[COSMAPI alloc] init];
    customAPI.apiKey = kAPI_KEY;

    self.feedCollection = [[COSMFeedCollection alloc] init];
    self.feedCollection.delegate = self;
    self.feedCollection.api = customAPI;
    [self.feedCollection fetch];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned fetching feeds with custom api key");
    STAssertTrue(feedCollection.feeds.count > 0, @"Feed collection has feeds");
    
    [self reset];
    
    /////
    //// Test with param
    ///
    
    self.semaphore = dispatch_semaphore_create(0);
    [[COSMAPI defaultAPI] setApiKey:kAPI_KEY];
    
    self.feedCollection = [[COSMFeedCollection alloc] init];
    self.feedCollection.delegate = self;
    [self.feedCollection useParameter:@"per_page" withValue:@"9"];
    [feedCollection fetch];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned when fetching feeds with parameters");
    STAssertEquals(feedCollection.feeds.count, 9u, @"Feed collection has 9 feeds");
    
    /////
    ////  Test remove deleted from cosm 
    ///
    
    [[self.feedCollection.feeds objectAtIndex:0] setIsDeletedFromCosm:YES];
    [self.feedCollection removeDeleted];
    STAssertEquals(feedCollection.feeds.count, 8u, @"Has deleted feed marked (manually) as deleted");
    
    [self reset];
}

#pragma mark - Feed Model

@synthesize feedModel;

- (void)testFeedModel {
    
    self.semaphore = dispatch_semaphore_create(0);
    
    /////
    //// Test for error on missing info
    ///
    
    self.feedModel = [[COSMFeedModel alloc] init];
    self.feedModel.delegate = self;
    [self.feedModel fetch];
    STAssertTrue(self.errorObj || self.errorJSON, @"Error returned for no feed id on fetch");
    [self reset];
    
    self.feedModel = [[COSMFeedModel alloc] init];
    self.feedModel.delegate = self;
    [self.feedModel deleteFromCOSM];
    STAssertTrue(self.errorObj || self.errorJSON, @"Error returned for no feed id on delete");
    [self reset];
    
    NSString *feedId = nil;
    NSString *feedTitle = @"My test feed";
    NSString *feedTitle2 = @"My alternative feed";
    
    /////
    //// Test create feed model
    ///
    
    self.semaphore = dispatch_semaphore_create(0);
    [[COSMAPI defaultAPI] setApiKey:kAPI_KEY];
    
    self.feedModel = [[COSMFeedModel alloc] init];
    [self.feedModel.info setValue:feedTitle forKey:@"title"];
    self.feedModel.delegate = self;
    STAssertTrue(self.feedModel.isNew, @"Feed marked as new after alloc");
    STAssertFalse(self.feedModel.isDeletedFromCosm, @"Not marked as deleted from Cosm");
    [self.feedModel save];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned");
    feedId = [self.feedModel.info valueForKeyPath:@"id"];
    STAssertFalse(self.feedModel.isNew, @"Feed marked as not new after create");
    STAssertTrue((feedId != nil), @"Has an id");
    
    [self reset];
    
    /////
    //// Test fetch feed model
    ///
    
    self.feedModel = [[COSMFeedModel alloc] init];
    [self.feedModel.info setValue:feedId forKey:@"id"];
    self.feedModel.delegate = self;
    [self.feedModel fetch];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned");
    feedId = [self.feedModel.info valueForKeyPath:@"id"];
    STAssertTrue((feedId != nil), @"Has an id");
    STAssertTrue([[self.feedModel.info valueForKeyPath:@"title"] isEqualToString:feedTitle], @"Has the correct title");
    STAssertFalse(self.feedModel.isNew, @"Feed marked as not new after fetch");
    
    /////
    //// Test update feed model
    ///
    
    [self.feedModel.info setValue:feedTitle2 forKey:@"title"];
    [self.feedModel save];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned");
    STAssertTrue([[self.feedModel.info valueForKeyPath:@"title"] isEqualToString:feedTitle2], @"Has the correct title");
    
    /////
    //// Test delete feed model
    ///
    
    [self.feedModel deleteFromCOSM];
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned");
    STAssertTrue(self.feedModel.isDeletedFromCosm, @"Marked as deleted from Cosm");
    
    
    [self reset];
    
}

#pragma mark - Datastream Collection

@synthesize datastreamCollection;

- (void)testDatastreamCollection {
    // ?
}

#pragma mark - Datastream Model

@synthesize datastreamModel;

- (void)testDatastreamModel {
    
    //// Create a feed
    ///
    
    self.semaphore = dispatch_semaphore_create(0);
    [[COSMAPI defaultAPI] setApiKey:kAPI_KEY];
    
    COSMFeedModel *temporaryFeed = [[COSMFeedModel alloc] init];
    [temporaryFeed.info setValue:@"Temporary feed" forKey:@"title"];
    temporaryFeed.delegate = self;
    [temporaryFeed save];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned when creating temporary feed");

    /////
    //// Test for error on missing info
    ///
    
    self.datastreamModel = [[COSMDatastreamModel alloc] init];
    self.datastreamModel.delegate = self;
    [self.datastreamModel save];
    STAssertTrue(self.errorObj || self.errorJSON, @"Error returned for no feed id on save when new");
    [self reset];
    
    self.datastreamModel = [[COSMDatastreamModel alloc] init];
    self.datastreamModel.delegate = self;
    self.datastreamModel.isNew = NO;
    [self.datastreamModel save];
    STAssertTrue(self.errorObj || self.errorJSON, @"Error returned for no feed id on save when not new");
    [self reset];
    
    self.datastreamModel = [[COSMDatastreamModel alloc] init];
    self.datastreamModel.delegate = self;
    [self.datastreamModel fetch];
    STAssertTrue(self.errorObj || self.errorJSON, @"Error returned for no feed id on fetch");
    [self reset];
    
    self.datastreamModel = [[COSMDatastreamModel alloc] init];
    self.datastreamModel.delegate = self;
    [self.datastreamModel deleteFromCosm];
    STAssertTrue(self.errorObj || self.errorJSON, @"Error returned for no feed id on delete");
    [self reset];
    
    /////
    //// Test create datastream
    ///
    
    self.semaphore = dispatch_semaphore_create(0);
    
    self.datastreamModel = [[COSMDatastreamModel alloc] init];
    
    self.datastreamModel.feedId = [[temporaryFeed.info valueForKeyPath:@"id"] integerValue];
    [self.datastreamModel.info setValue:@"test_datastream" forKey:@"id"];
    self.datastreamModel.delegate = self;
    STAssertTrue(self.datastreamModel.isNew, @"Datastream marked as new");
    STAssertFalse(self.datastreamModel.isDeletedFromCosm, @"Not marked as deleted from Cosm");
    [self.datastreamModel save];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned when creating new datastream");
    STAssertFalse(self.datastreamModel.isNew, @"Datastream marked as not new after create");
    [self reset];
    
    /////
    //// Test fetch datastream 
    ///
    
    self.datastreamModel = [[COSMDatastreamModel alloc] init];
    self.datastreamModel.feedId = [[temporaryFeed.info valueForKeyPath:@"id"] integerValue];
    [self.datastreamModel.info setValue:@"test_datastream" forKey:@"id"];
    self.datastreamModel.delegate = self;
    [self.datastreamModel fetch];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned fetching datasteam");
    STAssertFalse(self.datastreamModel.isNew, @"Datastream marked as not new after fetch");
    
    /////
    //// Test update datastream
    ///
    
    [self.datastreamModel.info setValue:@[@"tag1", @"tag2"] forKey:@"tags"];
    [self.datastreamModel save];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned when updating datastream");
    
    /////
    //// Test delete datastream
    ///
    
    [self.datastreamModel deleteFromCosm];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned when deleting datastream");
    STAssertTrue(self.datastreamModel.isDeletedFromCosm, @"Marked as deleted from Cosm");
    
    //// Delete feed
    ///
    self.semaphore = dispatch_semaphore_create(0);
    [temporaryFeed deleteFromCOSM];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned when deleting temporary feed");
    
}

#pragma mark - Datapoint Collection

@synthesize datapointCollection;


- (void)testDatapointCollection {
    
    // Test set of datapoints
    NSArray *datapointsRaw = @[
    @{@"at":@"2010-07-02T10:16:19.270708Z",@"value":@"294"},
    @{@"at":@"2010-07-02T10:17:19.270708Z",@"value":@"295"},
    @{@"at":@"2010-07-02T10:18:19.270708Z",@"value":@"296"},
    @{@"at":@"2010-07-02T10:19:19.270708Z",@"value":@"297"}
    ];
    NSMutableArray *datapoints = [[NSMutableArray alloc] initWithCapacity:datapointsRaw.count];
    [datapointsRaw enumerateObjectsUsingBlock:^(NSDictionary *raw, NSUInteger idx, BOOL *stop) {
        COSMDatapointModel *model = [[COSMDatapointModel alloc] init];
        model.info = [raw mutableCopy];
        [datapoints addObject:model];
    }];
    
    //// Create a feed and datastream for testing
    ///
    
    self.semaphore = dispatch_semaphore_create(0);
    [[COSMAPI defaultAPI] setApiKey:kAPI_KEY];
    
    COSMFeedModel *temporaryFeed = [[COSMFeedModel alloc] init];
    [temporaryFeed.info setValue:@"Temporary feed" forKey:@"title"];
    temporaryFeed.delegate = self;
    [temporaryFeed save];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned when creating temporary feed");
    
    self.semaphore = dispatch_semaphore_create(0);
    
    COSMDatastreamModel *temporaryDatastream = [[COSMDatastreamModel alloc] init];
    [temporaryDatastream.info setValue:@"test" forKey:@"id"];
    temporaryDatastream.feedId = [[temporaryFeed.info valueForKeyPath:@"id"] integerValue];
    temporaryDatastream.delegate = self;
    [temporaryDatastream save];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned when creating temporary datastream");
    
    /////
    //// Test creating mutliple datapoints
    ///
    
    self.semaphore = dispatch_semaphore_create(0);
    self.datapointCollection = [[COSMDatapointCollection alloc] init];
    self.datapointCollection.delegate = self;
    [self.datapointCollection saveAll];
    STAssertTrue(self.errorObj || self.errorJSON, @"Error returned for no feed id on save all");
    self.errorObj = nil;
    self.errorJSON = nil;
    
    self.semaphore = dispatch_semaphore_create(0);
    self.datapointCollection.feedId = [[temporaryFeed.info valueForKeyPath:@"id"] integerValue];
    [self.datapointCollection saveAll];
    STAssertTrue(self.errorObj || self.errorJSON, @"Error returned for no datastreamId id on save all");
    self.errorObj = nil;
    self.errorJSON = nil;
    
    self.semaphore = dispatch_semaphore_create(0);
    self.datapointCollection.datastreamId = [temporaryDatastream.info valueForKeyPath:@"id"];
    [self.datapointCollection saveAll];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned when saving all");
    self.errorObj = nil;
    self.errorJSON = nil;
    
    //// Delete feed and datastream
    ///
    
    // only need to delete the feed! 
    self.semaphore = dispatch_semaphore_create(0);
    [temporaryFeed deleteFromCOSM];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned");
    
    [self reset];
}

#pragma mark - Datastream Model

@synthesize datapointModel;

- (void)testDatapointModel {
    
    NSString *timestamp = @"2010-05-20T11:01:46.000000Z";
    
    //// Create a feed and datastream for testing
    ///
    
    self.semaphore = dispatch_semaphore_create(0);
    [[COSMAPI defaultAPI] setApiKey:kAPI_KEY];
    
    COSMFeedModel *temporaryFeed = [[COSMFeedModel alloc] init];
    [temporaryFeed.info setValue:@"Temporary feed" forKey:@"title"];
    temporaryFeed.delegate = self;
    [temporaryFeed save];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned when creating temporary feed");
    
    self.semaphore = dispatch_semaphore_create(0);
    
    COSMDatastreamModel *temporaryDatastream = [[COSMDatastreamModel alloc] init];
    [temporaryDatastream.info setValue:@"test" forKey:@"id"];
    temporaryDatastream.feedId = [[temporaryFeed.info valueForKeyPath:@"id"] integerValue];
    temporaryDatastream.delegate = self;
    [temporaryDatastream save];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned when creating temporary datastream");
    
    /////
    //// Test create datapoint model
    ///
    
    self.semaphore = dispatch_semaphore_create(0);
    
    self.datapointModel = [[COSMDatapointModel alloc] init];
    STAssertTrue(self.datapointModel.isNew, @"Datapoint marked as new");
    STAssertFalse(self.datapointModel.isDeletedFromCosm, @"Not marked as deleted from Cosm");
    self.datapointModel.feedId = [[temporaryFeed.info valueForKeyPath:@"id"] integerValue];
    self.datapointModel.datastreamId = [temporaryDatastream.info valueForKeyPath:@"id"];
    [self.datapointModel.info setValue:timestamp forKey:@"at"];
    [self.datapointModel.info setValue:@"1" forKey:@"value"];
    self.datapointModel.delegate = self;
    [self.datapointModel save];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned when save datapoint");
    STAssertFalse(self.datapointModel.isNew, @"Datapoint not marked as new");
    
    /////
    //// Test update datapoint model
    ///
    
    [self.datapointModel.info setValue:@"2" forKey:@"value"];
    [self.datapointModel save];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned when updating datapoint");
    STAssertFalse(self.datapointModel.isNew, @"Datapoint not marked as new");

    /////
    //// Test fetch datapoint model
    ///
    self.datapointModel = [[COSMDatapointModel alloc] init];
    self.datapointModel.feedId = [[temporaryFeed.info valueForKeyPath:@"id"] integerValue];
    self.datapointModel.datastreamId = [temporaryDatastream.info valueForKeyPath:@"id"];
    self.datapointModel.delegate = self;
    [self.datapointModel.info setValue:timestamp forKey:@"at"];
    [self.datapointModel fetch];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned when save datapoint");
    STAssertFalse(self.datapointModel.isNew, @"Datapoint not marked as new after fetch");
    STAssertTrue([[self.datapointModel.info valueForKeyPath:@"value"] isEqualToString:@"2"], @"Datapoint value is has the correct value (2)");
    
    /////
    //// Test delete datapoint model
    ///
    [self.datapointModel deleteFromCosm];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned when save datapoint");
    STAssertTrue(self.datapointModel.isDeletedFromCosm, @"Datapoint marked as deleted from Cosm");
    
    //// Delete feed and datastream
    ///
    
    // only need to delete the feed!
    self.semaphore = dispatch_semaphore_create(0);
    [temporaryFeed deleteFromCOSM];
    
    while (dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    STAssertTrue(!self.errorObj && !self.errorJSON, @"No errors returned");
                
}


#pragma mark - Locking

@synthesize semaphore, errorObj, errorJSON;

- (void)reset {
    self.errorObj = nil;
    self.errorJSON = nil;
    self.feedCollection = nil;
    self.feedModel = nil;
    self.datastreamCollection = nil;
    self.datastreamModel = nil;
    self.datapointCollection = nil;
    self.datapointModel = nil;
}

#pragma mark - Feed Collection Delegate

- (void)feedCollectionDidFetch:(COSMFeedCollection *)feedCollection {
    dispatch_semaphore_signal(self.semaphore);
}

- (void)feedCollectionFailedToFetch:(COSMFeedCollection *)feedCollection withError:(NSError*)error json:(id)JSON {
    self.errorObj = error;
    self.errorJSON = JSON;
    dispatch_semaphore_signal(self.semaphore);
}

#pragma mark - Model Delegate

- (void)modelDidFetch:(COSMModel *)model {
    dispatch_semaphore_signal(self.semaphore);
}

- (void)modelFailedToFetch:(COSMModel *)model withError:(NSError*)error json:(id)JSON {
    self.errorObj = error;
    self.errorJSON = JSON;
    dispatch_semaphore_signal(self.semaphore);
}

- (void)modelDidSave:(COSMModel *)model {
    dispatch_semaphore_signal(self.semaphore);
}

- (void)modelFailedToSave:(COSMModel *)model withError:(NSError*)error json:(id)JSON {
    self.errorObj = error;
    self.errorJSON = JSON;
    dispatch_semaphore_signal(self.semaphore);
}

- (void)modelDidDeleteFromCOSM:(COSMModel *)model {
    dispatch_semaphore_signal(self.semaphore);
}

- (void)modelFailedToDeleteFromCOSM:(COSMModel *)model withError:(NSError*)error json:(id)JSON {
    self.errorObj = error;
    self.errorJSON = JSON;
    dispatch_semaphore_signal(self.semaphore);
}

#pragma mark - Datapoint Collection Delegate

- (void)datapointCollectionDidSaveAll:(COSMDatapointCollection *)collection {
    dispatch_semaphore_signal(self.semaphore);
}

- (void)datapointCollectionFailedToSaveAll:(COSMDatapointCollection *)collection withError:(NSError *)error json:(id)JSON {
    self.errorObj = error;
    self.errorJSON = JSON;
    dispatch_semaphore_signal(self.semaphore);
}

@end
