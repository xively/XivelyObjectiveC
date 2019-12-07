#import "XivelyDatapointCollection.h"
#import "XivelyDatapointModel.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

@implementation XivelyDatapointCollection

#pragma mark - Data

@synthesize feedId, datastreamId;


#pragma mark - Datapoints

@synthesize datapoints;

#pragma mark - Synchronisation

@synthesize delegate, api;

- (void)save {
    if (self.feedId == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(datapointCollectionFailedToSaveAll:withError:json:)]) {
            [self.delegate datapointCollectionFailedToSaveAll:self withError:nil json:@{ @"Error" : @"Datapoint collection has no feed id" }];
        }
        return;
    }
    if (self.datastreamId == nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(datapointCollectionFailedToSaveAll:withError:json:)]) {
            [self.delegate datapointCollectionFailedToSaveAll:self withError:nil json:@{ @"Error" : @"Datapoint collection has no datastream id" }];
        }
        return;
    }
    NSURL *url = [self.api urlForRoute:[NSString stringWithFormat:@"feeds/%lu/datastreams/%@/datapoints", (unsigned long)self.feedId, self.datastreamId]];
    AFHTTPClient *httpClient = [AFHTTPClient clientWithBaseURL:url];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:nil parameters:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:self.api.versionString forHTTPHeaderField:@"User-Agent"];

    NSMutableArray *arrayOfDatapoints = [[NSMutableArray alloc] initWithCapacity:self.datapoints.count];
    [self.datapoints enumerateObjectsUsingBlock:^(XivelyDatapointModel *model, NSUInteger idx, BOOL *stop) {
        if (model.isNew) {
            [arrayOfDatapoints addObject:model.info];
        }
    }];

    NSData *data  = [NSJSONSerialization dataWithJSONObject:@{@"datapoints":arrayOfDatapoints} options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:data];
    AFHTTPRequestOperation *operation = [httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(datapointCollectionDidSaveAll:)]) {
            [self.delegate datapointCollectionDidSaveAll:self];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(datapointCollectionFailedToSaveAll:withError:json:)]) {
            // get some data to use as JSON from the error
            id dataToJsonify = [[error userInfo] valueForKeyPath:NSLocalizedRecoverySuggestionErrorKey];
            if (!dataToJsonify) {
                dataToJsonify = [[error userInfo] valueForKeyPath:NSLocalizedDescriptionKey];
            }
            if (!dataToJsonify) {
                dataToJsonify = @"Save failed with unknown error.";
            }
            NSError *jsonError = NULL;
            id JSON;
            // see if the data can be made into data, if not
            // make something similar to Xively Api error
            // with the error information we have extracted.
            if ([NSJSONSerialization isValidJSONObject:dataToJsonify]) {
                JSON = [NSJSONSerialization JSONObjectWithData:[dataToJsonify dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&jsonError];
            } else {
                JSON = @{@"title" : @"Failed to save", @"errors" : dataToJsonify};
            }
            [self.delegate datapointCollectionFailedToSaveAll:self withError:error json:JSON];
        }
    }];
    [operation start];
}

- (void)parse:(id)JSON {
    if ([JSON isKindOfClass:[NSDictionary class]])  {
        NSLog(@"@stub: XivelyDatapointCollection::parse with JSON of NSDictionary. Not adding any datapoints to collection.");
    } else if ([JSON isKindOfClass:[NSArray class]]) {
        // clear all the previous data
        [self.datapoints removeAllObjects];        // add the data streams
        NSEnumerator *enumerator = [JSON objectEnumerator];
        NSDictionary *datapointData;
        while (datapointData = [enumerator nextObject]) {
            XivelyDatapointModel *datapoint = [[XivelyDatapointModel alloc] init];
            datapoint.feedId = self.feedId;
            datapoint.datastreamId = self.datastreamId;
            datapoint.isNew = NO;
            [datapoint parse:datapointData];
            [self.datapoints addObject:datapoint];
        }
    } else {
        //NSLog(@"XivelyDatapointCollection::parse: don't know what kind JSON is. Not adding any datapoint to collection.");
    }
}

#pragma mark - Life Cycle

- (id)init {
    if (self=[super init]) {
        self.api = [XivelyAPI defaultAPI];
        self.datapoints = [[NSMutableArray alloc] init];
    }
    return self;
}



@end
