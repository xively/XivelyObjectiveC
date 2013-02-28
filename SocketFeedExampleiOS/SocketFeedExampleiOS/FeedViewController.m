#import "FeedViewController.h"
#import "Utils.h"
#import "DatastreamCell.h"

@interface FeedViewController ()

@end

@implementation FeedViewController

#pragma mark - UI

- (void)updateTable {
    if (self.feedModel) {
        // reset the button is this is a newly synced feed
        if (!self.feedModel.isSubscribed) {
            self.subscribeUnsubscribeButton.userInteractionEnabled = YES;
            [self.subscribeUnsubscribeButton setTitle:@"Subscribe" forState:UIControlStateNormal];
        }
        // update the table
        NSLog(@"Should be updating table");
        [self.tableView reloadData];
    }
}

@synthesize tableView;

#pragma mark - Cosm Datastream

@synthesize feedModel;

#pragma mark - Cosm Model Delegate Methods

- (void)modelDidFetch:(COSMModel *)model {
    [self updateTable];
}

- (void)modelFailedToFetch:(COSMModel *)model withError:(NSError *)error json:(id)JSON {
    NSLog(@"Error fetching feed");
    NSLog(@"Error is %@", error);
    NSLog(@"JSON is %@", JSON);
    [Utils alertUsingJSON:JSON orTitle:@"Failed to fetch feed" message:@"Something went wrong, check console"];
}

#pragma mark – Socket Connection Delegate Methods

- (void)modelDidSubscribe:(COSMModel *)model {
    self.subscribeUnsubscribeButton.userInteractionEnabled = YES;
    [self.subscribeUnsubscribeButton setTitle:@"Unsubscribe" forState:UIControlStateNormal];
}

- (void)modelDidUnsubscribe:(COSMModel *)model withError:(NSError *)error {
    if (error) {
        NSLog(@"Error subscribing %@", error);
        [Utils alert:@"Failed to subscribe to feed" message:@"Something went wrong, check console"];
    }
    self.subscribeUnsubscribeButton.userInteractionEnabled = YES;
    [self.subscribeUnsubscribeButton setTitle:@"Subscribe" forState:UIControlStateNormal];
}

- (void)modelUpdatedViaSubscription:(COSMModel *)model {
    [self updateTable];
}

#pragma mark - Interface Builder
    
- (IBAction)fetchFeedTouched:(id)sender {
    // hide the keyboard
    [self.apiKeyTextField resignFirstResponder];
    [self.feedIdTextField resignFirstResponder];
    
    // check data has been entered by the use
    if (!self.apiKeyTextField.text.length) {
        [Utils alert:@"Missing COSM API Key" message:@"Please add your API key"];
        return;
    } else if (!self.feedIdTextField.text.length) {
        [Utils alert:@"Missing Feed ID" message:@"Please enter the feed ID of the datastream you wish to fetch"];
        return;
    }
    
    // clear any previous model
    self.feedModel.delegate = nil;
    [self.feedModel unsubscribe];
    
    // set the API key for Cosm
    [[COSMAPI defaultAPI] setApiKey:self.apiKeyTextField.text];
    
    // create a new datastream model
    self.feedModel = [[COSMFeedModel alloc] init];
    [self.feedModel.info setObject:self.feedIdTextField.text forKey:@"id"] ;
    self.feedModel.delegate = self;
    [self.feedModel fetch];
}

- (IBAction)subscribeUnsubscribeTouched:(id)sender {
    self.subscribeUnsubscribeButton.userInteractionEnabled = NO;
    if (self.feedModel.isSubscribed) {
        [self.subscribeUnsubscribeButton setTitle:@"Unsubscribing..." forState:UIControlStateNormal];
        [self.feedModel unsubscribe];
    } else {
        [self.subscribeUnsubscribeButton setTitle:@"Subscribing..." forState:UIControlStateNormal];
        [self.feedModel subscribe];
    }
}

@synthesize apiKeyTextField, feedIdTextField;

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Utils

- (void)saveUserInfo {
    // save any values inputed from the user
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:self.apiKeyTextField.text forKey:@"Api Key"];
    [defaults setObject:self.feedIdTextField.text forKey:@"Feed Id"];
    [defaults synchronize];
}

- (void)loadUserEnteredInfo {
    // load any values previously inputed from the user
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    self.apiKeyTextField.text = [defaults objectForKey:@"Api Key"];
    self.feedIdTextField.text = [defaults objectForKey:@"Feed Id"];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.feedModel.datastreamCollection.datastreams count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"Datastream Cell";
    DatastreamCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    // populate with data about the feed
    COSMDatapointModel *datastream = [self.feedModel.datastreamCollection.datastreams objectAtIndex:indexPath.row];
    cell.currentValueLabel.text = [datastream.info valueForKeyPath:@"current_value"];
    cell.datastreamNameLabel.text = [datastream.info valueForKeyPath:@"id"];
    
    return cell;
}

#pragma mark - Lifecycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Datasources Table View Controller"]) {
        UITableViewController *tableViewController = segue.destinationViewController;
        self.tableView = tableViewController.tableView;
        self.tableView.dataSource = self;
        [self.tableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self loadUserEnteredInfo];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self saveUserInfo];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(saveUserInfo)
                          name:@"Should save data"
                        object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
