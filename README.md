# LibCOSM (Alpha Release)

An iOS and OSX Objective-C Library for [COSM](http://cosm.com/) similar in design to [backbone.js](http://backbonejs.org). Requires [AFNetworking](https://github.com/AFNetworking/AFNetworking).

## Setting the API Key

This should be done early as possible if only API Key is used.

    [[COSMAPI defaultAPI] setApiKey:@"<API Key>"];

By default all new `COSMModel`s and `COSMCollection`s will use this API Key when communicating with the server. 

A different API Key may be used by creating new COSMAPI object. This new COSMAPI object can be added to all COSMModels and COSMCollections on a case by case basis. For example

    COSMFeedModel *feed = [[COSMFeedModel alloc] init];
    COSMAPI *alternativeAPI = [[COSMApi alloc] init];
    [feed setApi:alternativeAPI]; 


The COSM API URL can also be changed

    [[COSMAPI defaultAPI] setApiURLString:@"https://proxiedapi.com/v2/"];

## Getting a list of all feeds

For example, in a table view controller

    -(void)viewWillAppear:(BOOL)animated {
    
        // create the a new feed collection
        if (!self.feedCollection) {
            self.feedCollection = [[COSMFeedCollection alloc] init]
        }
        
        // set this feed collection to only fetch 100 feeds
        [self.feedCollection useParameter:@"per_page" withValue:@"100"];
        
        // set it to only fetch feeds from the user "joebloggs"
        [self.feedCollection useParameter:@"user" withValue:@"joebloggs"];
        
        // become the delegate so we know when the feedCollection has fetched
        self.feedCollection.delegate = self;
        
        // fetch the feeds
        [self.feedCollection fetch];
    
To know when the collection has fetched, implement the COSMFeedCollectionDelegate methods

     - (void)feedCollectionDidFetch:(COSMFeedCollection *)feedCollection {
        
        // feeds were fetch so reload the table view
        [self.tableView reload];
     }
     
     - (void)feedCollectionFailedToFetch:(COSMFeedCollection *)feedCollection withError:(NSError*)error json:(id)JSON {
        
        // feeds failed to fetch
        NSLog(@"The feed collection failed to fetch.")
        NSLog(@"The error is %@", error)

        // and is we spoke to the COSM server, there is a good 
        // chance we will have JSON that describe the error
        NSLog(@"COSM said %@", JSON);
     }
     
The feed collection will now have an array of feed models which can be use to populate the table cells

    - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
        // get the COSMFeedModel
        COSMFeedModel *feed = [self.feedsCollection.feeds objectAtIndex:indexPath.row];
        
        // we can query things about this feed
        NSString *title = [feed valueForKeyPath:@"info.title"];
        
        // the feeds also has a datastream collection with all the datastreams
        COSMDatastreamCollection *datastreamCollection = feed.datastreamCollection;
        
        // this contains an array of COSMDatastreamModels and we can get the last one as it is an array
        COSMDatastreamModel *datastream = [datastreamCollection.datastreams lastObject];
        
        // then we can get information about the datastream
        NSString *datastreamID  = [feed valueForKeyPath:@"info.id"];
        NSString *unitLabel     = [feed valueForKeyPath:@"info.unit.label"];
        float currentValue      = [[feed valueForKeyPath:@"info.current_value"] floatValue];
        
        // or, we could just log all the information about the stream
        NSLog(@"%@", feed.info);
        
## Creating a feed

Feeds can be created and saved

    // create the feed model
    COSMFeedModel *feedModel = [[COSMFeedModel alloc] init];
    
    // add a title
    [feedModel.info setObject:@"Example Feed" forKey:@"title"];
    
    [feedModel save];
    
After this it would be an idea to set the delegate and respond to both 

   - (void)modelDidSave:(COSMModel *)model;
   - (void)modelFailedToSave:(COSMModel *)model withError:(NSError*)error json:(id)JSON;
   
## Creating a Datastream

A datastream can be created at the same time as feed

    // create the datastream
    COSMDatastream *datastream = [[COSMDatastream alloc] init];
    
    // add some information
    [datastream.info setObject:@"id" forKey:@"Room"];
    [datastream.info setObject:@"id" forKey:@"current_value"];
    
    // add the datastream  to the feed's datastream collection
    [feedModel.datastreamCollection.datastreams addObject:datastream];
    
    [feedModel save];
    
Or on its own by giving a new datastream it's feed id

    // create the datastream
    COSMDatastream *datastream = [[COSMDatastream alloc] init]; 
    
    // give it the feed id
    datastream.feedId = 101;
    
    [datastream save];

If you have a feed model which has been previously saved or fetched, a new datastream can be add to that feed model then the new datastream saved.




    