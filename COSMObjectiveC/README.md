# LibCOSM (Alpha Release)

An iOS and OSX Objective-C Library for [COSM](http://cosm.com/) similar in design to [backbone.js](http://backbonejs.org).

## Requirements

Requires [AFNetworking](https://github.com/AFNetworking/AFNetworking) and [SocketRocket](https://github.com/square/SocketRocket).

## Adding to your project

After adding [AFNetworking](https://github.com/AFNetworking/AFNetworking) and [SocketRocket](https://github.com/square/SocketRocket) to your project, simply add the files within the COSMObjectiveC to you project.

## Documentation

Documentation is online at [http://cosm.github.com/COSMObjective-C](http://cosm.github.com/COSMObjective-C).

## Core Concepts

### Models

COSMFeedModel, COSMDatastreamModel and COSMDatapointModel are represntations of a single entity on Cosm: a feed, a datastream or a datapoint. Information about the entity its self (such the `id`, `current_value`, `tags`, `title`, `at`)  is stored in a mutable dictionary of the model called `info`.

A model can `fetch` from Cosm which will load it's info Cosm; it can `save` to Cosm which will create or update it on Cosm; and `deleteFromCosm` which will remove it from Cosm.
    
COSMFeedModel and COSMDatastreamModel can also `subscribe` and `unsubscribe` from Cosm. A subscribed feed  or datastream model will automatially be updated with any changes which happen to the model on Cosm.

Information about the model's child entities (a feed's datastreams or a datastream's datapoints) are stored in a collection.

### Collections

COSMFeedCollection, COSMDatastreamCollection and COSMDatapoints are container classes for multiple models. COSMFeedCollection can also `fetch` feeds from Cosm and specifiy parameters so that the fetch returns a filtered set of feed, or feeds based on a historical query. 

### Setting the API Key

This should be done early as possible if only one API Key is used.

``` objective-c
[[COSMAPI defaultAPI] setApiKey:@"<API Key>"];
```

By default all new models and collections will use this API Key when communicating with the server. 

A different API Key may be used by creating new COSMAPI object and adding to other COSMModels and COSMCollections on a case by case basis. For example

``` objective-c
COSMFeedModel *feed = [[COSMFeedModel alloc] init];
COSMAPI *alternativeAPI = [[COSMApi alloc] init];
[feed setApi:alternativeAPI]; 
```

## Examples

### Basic example

Add a new datapoint to  Cosm

``` objective-c
// set your API key
[[COSMAPI defaultAPI] setApiKey:@"somekey"];

// create and & setup datapoint
COSMDatapointModel *datapoint = [[COSMDatapointModel alloc] init];
// set the id of the feed the datapoint belongs to
datapoint.feedId = 100;
// set the id of the datastream the datapoint belongs to
datapoint.datastreamId = @"miles";

// set the value of the datapoint
[datapoint.info setValue:@"2399" forKey:@"value"];

// save it to cosm
[datapoint save];
```
    
### Adding multiple new datapoints to Cosm

Multiple datapoint can be saved to Cosm in one go by using a datapoint collection

``` objective-c
// create & setup a new datapoint collection
self.datapointCollection = [[COSMDatapointCollection alloc] init];
self.datapointCollection.feedId = 100;
self.datapointCollection.datastreamId = @"miles";

// ..
// later add a datapoint to the collection
COSMDatapointModel *datapoint = [[COSMDatapointModel alloc] init];
[datapoint.info setValue:@"13234" forKey:@"value"];
[datapoint.info setValue:@"2010-05-20T11:01:43Z" forKey:@"at"];
[self.datapointCollection.datapoints addObject:datapoint];
```

### Fetching a list of all feeds from Cosm

For example, in a table view controller

``` objective-c
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
```
    
To know when the collection has fetched, implement the methods of the COSMFeedCollectionDelegate protocol.

``` objective-c
- (void)feedCollectionDidFetch:(COSMFeedCollection *)feedCollection {
    // feeds were fetch so reload the table view
    [self.tableView reload];
}
 
- (void)feedCollectionFailedToFetch:(COSMFeedCollection *)feedCollection withError:(NSError*)error json:(id)JSON {
    // feeds failed to fetch
    NSLog(@"The feed collection failed to fetch.")
    NSLog(@"The error is %@", error)

    // and if we spoke to the COSM server, there is a good 
    // chance we will have JSON that describe the error
    NSLog(@"COSM said %@", JSON);
```

The feed collection will now have an array of feed models which can be use to populate the table cells

``` objective-c
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // get the feed model
    COSMFeedModel *feed = [self.feedsCollection.feeds objectAtIndex:indexPath.row];
    
    // we can query things about this feed
    NSString *title = [feed.info valueForKeyPath:@"title"];
    
    // the feeds also has a datastream collection with all the datastreams
    COSMDatastreamCollection *datastreamCollection = feed.datastreamCollection;
    
    // this contains an array of COSMDatastreamModels and we can get the last one as it is an array
    COSMDatastreamModel *datastream = [datastreamCollection.datastreams lastObject];
    
    // then we can get information about the datastream
    NSString *datastreamID  = [feed.info valueForKeyPath:@"id"];
    NSString *unitLabel     = [feed.info valueForKeyPath:@"unit.label"];
    float currentValue      = [[feed.info valueForKeyPath:@"current_value"] floatValue];
    
    // or, we could just log all the info about the stream
    NSLog(@"%@", feed.info);
```

### Creating a new feed on Cosm

Feeds can be created and saved

``` objective-c
// create the feed model
COSMFeedModel *feedModel = [[COSMFeedModel alloc] init];

// add a title
[feedModel.info setObject:@"Example Feed" forKey:@"title"];

[feedModel save];
```

After this a delegate will be notified via either of these methods

``` objective-c
- (void)modelDidSave:(COSMModel *)model;
- (void)modelFailedToSave:(COSMModel *)model withError:(NSError*)error json:(id)JSON;
```

### Fetching a feed from Cosm

A feed on Cosm can be retrieved from Cosm by

``` objective-c
// create a feed model
COSMFeedModel *feedModel = [[COSMFeedModel alloc] init];

// set the feed's id
[feedModel.info setValue:@"100" forKey:@"id"];

[feedModel.info fetch];
```

After this a delegate will be notified via either of these methods

``` objective-c
- (void)modelDidFetch:(COSMModel *)model;
- (void)modelFailedToFetch:(COSMModel *)model withError:(NSError*)error json:(id)JSON;
```

### Creating a new datastream via a feed on Cosm

A datastream can be created at the same time as feed

``` objective-c
// create the datastream model
COSMDatastream *datastream = [[COSMDatastream alloc] init];

// add some information
[datastream.info setObject:@"id" forKey:@"Room"];
[datastream.info setObject:@"id" forKey:@"current_value"];

// add the datastream  to the feed's datastream collection
[feedModel.datastreamCollection.datastreams addObject:datastream];

[feedModel save];
```

### Creating a new datastream on Cosm

A new datastream may be made directly

``` objective-c
// create the datastream model
COSMDatastream *datastream = [[COSMDatastream alloc] init];

// provide its feed's id
datastream.feedId = 101;

// give the datastream a new id
[datastream.info setValue:@"Temperature"];

[datastream.feedId save];
```

### Retreving a datastream from Cosm
 
A datastream can retreieved by providing a `feedId` and the datastreams 'id' key to the info dictionary and calling `fetch`
 
``` objective-c
// Create a new datastream model
COSMDatastreamModel *myDatastream = [[COSMDatastreamModel alloc] init];

// Set the datastream's id
[myDatastream setValue:@"Temperture" forKey:@"id"];

// Also add the datastream parent feed id
myDatastream.feedId = 100;

// Finally, fetch the datastream from Cosm
[myDatastream fetch];

// ...
// Later, after feed has called `modelDidFetch:` on its delegate
NSString *currentValue = [myDatastream.info valueForKeyPath:@"current_value"];
```

### Retreving live updates of a datastream from Cosm.
 
A datastream may be updated with live updates from Cosm by subscribing a COSMDatastreamModel to Cosm. 
 
 _*It is not nessicary to fetch the COSMDatastreamModel first, however without doing so there will be no information about the datastream until it is next changed on Cosm._
 
``` objective-c
- (id)init {
    self = [super init];
    if (self) {
        // set up the datastream
        self.datastream = [[COSMDatastream alloc] init];
        self.datastream.feedId = 100;
        [self.datastream.info setValue:@"miles" forKey:@"id"];
        
    }
}

- (IBAction)subscribeTouched:(id)sender {
   self.datastream.delegate = self;
   // toggle the datastream being subscribed
   if (self.datastream.isSubscribed) {
      [self.datastream subscribe];
   } else {
      [self.datastream unsubscribe];
   }
}

- (void)modelUpdatedViaSubscription:(COSMModel *)model {
   myLabel.text = [self.datastream.info valueForKeyPath:@"current_value"];
}

- (void)modelDidSubscribe:(COSMModel *)model {
    NSLog(@"Web socket connected, now recieving live changes to datastream");
}

- (void)modelDidUnsubscribe:(COSMModel *)model withError:(NSError *)error;
    NSLog("Web socket disconnected...");
    if (error) {
        NSLog(@"...because something went wrong");
    } else {
        NSLog(@"...because we successfully unsubscribed");
    }
}
```

The above will also work for a COSMFeedModel
    