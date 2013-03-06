#import "COSMSubscribable.h"
@class COSMDatapointCollection;

/** An Objective-C representation of a Cosm datastream which can interact with Cosm.
 
 There are two main properties of a COSMDatastreamModel: a NSMutableDictionary called info which contains information relative to the datastream, and a COSMDatapointCollection which contains the datastreams datapoints in the for of COSMDatapointModels.
 
 A COSMDatastreamModel may be fetched, saved or deleted from Cosm. Also an existing COSMDatastreamModel may recieve live updates from Cosm by subscribing to updates. Updates will recieved from Cosm internally by using a web socket connection.
 
 Successful or unsuccessful fetch, save and deleted requests will notify a COSMDatastreamModel delegate object by using the COSMModelDelegate protocol. In addition to this a COSMDatastreamModel delegate object may be notified of succesful, unsuccesful or update events when the COSMDatastreamModel attempts to subscribe or is subscribed to Cosm via the COSMSubscribableDelegate protocol.
 
 ## Retreving a COSMDatastreamModel from Cosm.
 
 A COSMDatastreamModel can retreieved by providing a feedId, adding the datastreams 'id' key to the info dictionary and calling fetch. For example:
 
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
 
 ## Retreving live updates of a COSMDatastreamModel from Cosm.
 
 A COSMDatastreamModel may be updated with live updates from Cosm by subscribing the COSMDatastreamModel to Cosm. 
 
 When subscribing a COSMDatastreamModel it should be providing a delegate conforming to the COSMDatastreamModel which will be notified when the subscribe request is successful via `modelDidSubscribe:`, when the subscribe request is unsuccessful or the socket connection drop via `modelDidUnsubscribe:withError:` or when it recieves an update via `modelUpdatedViaSubscription:`. For example, after COSMDatastreamModel has been fetched* it can be subscribed to update a UILabel with current changes:
 
 _*It is not nessicary to fetch the COSMDatastreamModel first, however without doing so there will be no information about the datastream until it is next changed on Cosm._
 
    // 0
    - (IBAction)subscribeTouched:(id)sender {
       myDatastream.delegate = self;
       [myDatastream subscribe];
    }
 
    - (void)modelUpdatedViaSubscription:(COSMModel *)model {
       myLabel.text = [myDatastream.info valueForKeyPath:@"current_value"];
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
 
 
 ## Create a new COSMDatastreamModel and save it to Cosm.
 
 A new datastream can be created and saved to Cosm using the save method. 
 
 Internally, COSMDatastreamModel will check to see if it has a valid id in its info dictionary before decideding if it should use a POST or PUT request.
 
    // Create a new datastream model
    COSMDatastreamModel *myDatastream = [[COSMDatastreamModel alloc] init];
 
    // Set the id
    [myDatastream.info setValue:@"SoundLevel" forKey:@"id"];
   
    // Set private
    [myDatastream.info setValue:@"true" forKey:@"private"];
 
    // Add some tags
    [myDatastream.info setValue:myTagsArray forKey:@"private"];
   
    // Save
    [myDatastream save];
 
 */

@interface COSMDatastreamModel : COSMSubscribable

///---------------------------------------------------------------------------------------
/// @name Data
///---------------------------------------------------------------------------------------
@property NSUInteger feedId;

///---------------------------------------------------------------------------------------
/// @name Datapoints
///---------------------------------------------------------------------------------------
@property (nonatomic, strong) COSMDatapointCollection *datapointCollection;

///---------------------------------------------------------------------------------------
/// @name Synchronization
///---------------------------------------------------------------------------------------
- (void)fetch;
- (void)save;
- (void)deleteFromCosm;
- (void)parse:(id)JSON;
@property BOOL isNew;
/// returns the info dictionary without any references
/// to any datapoints, so that the COSMDatastreamModel
/// and COSMFeedModel cannot make edits to any datapoints
- (NSMutableDictionary *)saveableInfo;

@end
