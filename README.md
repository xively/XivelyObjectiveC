# XivelyObjectiveC

An iOS and OSX Objective-C Library for [Xively](http://xively.com/) similar in design to [backbone.js](http://backbonejs.org).

## Requirements

Requires [AFNetworking](https://github.com/AFNetworking/AFNetworking) and [SocketRocket](https://github.com/square/SocketRocket).

## Adding to your project

After adding [AFNetworking](https://github.com/AFNetworking/AFNetworking) and [SocketRocket](https://github.com/square/SocketRocket) to your project, simply add the files within the XivelyObjectiveC to your project.

## Documentation

Documentation is online at [http://xively.github.com/XivelyObjective-C](http://xively.github.com/XivelyObjectiveC).

## Core Concepts

### Models

XivelyFeedModel, XivelyDatastreamModel and XivelyDatapointModel are representations of a single entity on Xively: a feed, a datastream or a datapoint. 

Information about the entity is stored in a mutable dictionary called `info`  (such the _id_, _current_value_, _tags_, _title_, _at_, etc.) .

A model can __fetch__ which will load it from Xively; it can __save__ which will create or update it on Xively; and __deleteFromXively__ which will remove it from Xively.
    
XivelyFeedModel and XivelyDatastreamModel can also __subscribe__ and __unsubscribe__ from Xively. A subscribed feed or datastream model will automatically update with any changes which happen on Xively.

Information about the model's child entities (a feed's datastreams or a datastream's datapoints) are stored in collections.

### Collections

XivelyFeedCollection, XivelyDatastreamCollection and XivelyDatapoints are container classes for models. 

XivelyFeedCollection can also __fetch__ feeds from Xively whilst specifying request parameters so the fetch will return a filtered set of feeds, or feeds based on a historical query. 

XivelyDatapointCollection can also __save__ all its new datapoints to Xively.

### Setting the API Key

This should be done early as possible if only one API Key is used.

``` objective-c
[[XivelyAPI defaultAPI] setApiKey:@"<API Key>"];
```

By default all new models and collections will use this API Key when communicating with the server. 

A different API Key may be used by creating new XivelyAPI object and adding to other XivelyModels and XivelyCollections on a case by case basis

``` objective-c
XivelyFeedModel *feed = [[XivelyFeedModel alloc] init];
XivelyAPI *alternativeAPI = [[XivelyApi alloc] init];
[feed setApi:alternativeAPI]; 
```

## Examples

### Basic example

Add a new datapoint to  Xively

``` objective-c
// set your API key
[[XivelyAPI defaultAPI] setApiKey:@"somekey"];

// create and & setup datapoint
XivelyDatapointModel *datapoint = [[XivelyDatapointModel alloc] init];
// set the id of the feed the datapoint belongs to
datapoint.feedId = 100;
// set the id of the datastream the datapoint belongs to
datapoint.datastreamId = @"miles";

// set the value of the datapoint
[datapoint.info setValue:@"2399" forKey:@"value"];

// save it to Xively
[datapoint save];
```
    
### Adding multiple new datapoints to Xively

Multiple datapoints can be saved to Xively in one go by using a datapoint collection

``` objective-c
// create & setup a new datapoint collection
self.datapointCollection = [[XivelyDatapointCollection alloc] init];
self.datapointCollection.feedId = 100;
self.datapointCollection.datastreamId = @"miles";

// ..
// later add a datapoint to the collection
XivelyDatapointModel *datapoint = [[XivelyDatapointModel alloc] init];
[datapoint.info setValue:@"13234" forKey:@"value"];
[datapoint.info setValue:@"2010-05-20T11:01:43Z" forKey:@"at"];
[self.datapointCollection.datapoints addObject:datapoint];

// save the new datapoints
[self.datapointsCollection save];
```

### Fetching a list of all feeds from Xively

For example, in a table view controller

``` objective-c
-(void)viewWillAppear:(BOOL)animated {
    // create the a new feed collection
    if (!self.feedCollection) {
        self.feedCollection = [[XivelyFeedCollection alloc] init]
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
    
To know when the collection has fetched, implement the methods of the XivelyFeedCollectionDelegate protocol.

``` objective-c
- (void)feedCollectionDidFetch:(XivelyFeedCollection *)feedCollection {
    // feeds were fetch so reload the table view
    [self.tableView reload];
}
 
- (void)feedCollectionFailedToFetch:(XivelyFeedCollection *)feedCollection withError:(NSError*)error json:(id)JSON {
    // feeds failed to fetch
    NSLog(@"The feed collection failed to fetch.")
    NSLog(@"The error is %@", error)

    // and if we spoke to the Xively server, there is a good 
    // chance we will have JSON that describe the error
    NSLog(@"Xively said %@", JSON);
```

The feed collection will now have an array of feed models which can be use to populate the table cells

``` objective-c
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // get the feed model
    XivelyFeedModel *feed = [self.feedsCollection.feeds objectAtIndex:indexPath.row];
    
    // we can query things about this feed
    NSString *title = [feed.info valueForKeyPath:@"title"];
    
    // the feeds also has a datastream collection with all the datastreams
    XivelyDatastreamCollection *datastreamCollection = feed.datastreamCollection;
    
    // this contains an array of XivelyDatastreamModels and we can get the last one as it is an array
    XivelyDatastreamModel *datastream = [datastreamCollection.datastreams lastObject];
    
    // then we can get information about the datastream
    NSString *datastreamID  = [feed.info valueForKeyPath:@"id"];
    NSString *unitLabel     = [feed.info valueForKeyPath:@"unit.label"];
    float currentValue      = [[feed.info valueForKeyPath:@"current_value"] floatValue];
    
    // or, we could just log all the info about the stream
    NSLog(@"%@", feed.info);
```

### Creating a new feed on Xively

Feeds can be created and saved

``` objective-c
// create the feed model
XivelyFeedModel *feedModel = [[XivelyFeedModel alloc] init];

// add a title
[feedModel.info setObject:@"Example Feed" forKey:@"title"];

[feedModel save];
```

After this a delegate will be notified via either of these methods

``` objective-c
- (void)modelDidSave:(XivelyModel *)model;
- (void)modelFailedToSave:(XivelyModel *)model withError:(NSError*)error json:(id)JSON;
```

### Fetching a feed from Xively

A feed on Xively can be retrieved from Xively by

``` objective-c
// create a feed model
XivelyFeedModel *feedModel = [[XivelyFeedModel alloc] init];

// set the feed's id
[feedModel.info setValue:@"100" forKey:@"id"];

[feedModel.info fetch];
```

After this a delegate will be notified via either of these methods

``` objective-c
- (void)modelDidFetch:(XivelyModel *)model;
- (void)modelFailedToFetch:(XivelyModel *)model withError:(NSError*)error json:(id)JSON;
```

### Creating a new datastream via a feed on Xively

A datastream can be created at the same time as feed

``` objective-c
// create the datastream model
XivelyDatastream *datastream = [[XivelyDatastream alloc] init];

// add some information
[datastream.info setObject:@"id" forKey:@"Room"];
[datastream.info setObject:@"id" forKey:@"current_value"];

// add the datastream  to the feed's datastream collection
[feedModel.datastreamCollection.datastreams addObject:datastream];

[feedModel save];
```

### Creating a new datastream on Xively

A new datastream may be made directly

``` objective-c
// create the datastream model
XivelyDatastream *datastream = [[XivelyDatastream alloc] init];

// provide its feed's id
datastream.feedId = 101;

// give the datastream a new id
[datastream.info setValue:@"Temperature"];

[datastream.feedId save];
```

### Retrieving a datastream from Xively
 
A datastream can retrieved by providing a `feedId` and the datastreams 'id' key to the info dictionary and calling `fetch`
 
``` objective-c
// Create a new datastream model
XivelyDatastreamModel *myDatastream = [[XivelyDatastreamModel alloc] init];

// Set the datastream's id
[myDatastream setValue:@"Temperture" forKey:@"id"];

// Also add the datastream parent feed id
myDatastream.feedId = 100;

// Finally, fetch the datastream from Xively
[myDatastream fetch];

// ...
// Later, after feed has called `modelDidFetch:` on its delegate
NSString *currentValue = [myDatastream.info valueForKeyPath:@"current_value"];
```

### Retrieving live updates of a datastream from Xively.

__The below example also applies to feeds__
 
A datastream may be updated with live updates from Xively by subscribing a XivelyDatastreamModel to Xively. 
 
 _*It is not nessicary to fetch the XivelyDatastreamModel first, however without doing so there will be no information about the datastream until it is next changed on Xively._
 
``` objective-c
- (id)init {
    self = [super init];
    if (self) {
        // set up the datastream
        self.datastream = [[XivelyDatastream alloc] init];
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

- (void)modelUpdatedViaSubscription:(XivelyModel *)model {
   myLabel.text = [self.datastream.info valueForKeyPath:@"current_value"];
}

- (void)modelDidSubscribe:(XivelyModel *)model {
    NSLog(@"Web socket connected, now receiving live changes to datastream");
}

- (void)modelDidUnsubscribe:(XivelyModel *)model withError:(NSError *)error;
    NSLog("Web socket disconnected...");
    if (error) {
        NSLog(@"...because something went wrong");
    } else {
        NSLog(@"...because we successfully unsubscribed");
    }
}
```
    
