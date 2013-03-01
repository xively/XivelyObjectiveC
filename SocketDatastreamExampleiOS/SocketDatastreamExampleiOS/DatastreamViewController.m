#import "DatastreamViewController.h"
#import "Utils.h"

@interface DatastreamViewController ()

@end

@implementation DatastreamViewController

#pragma mark - UI

- (void)updateLabels {
    if (self.datastreamModel) {
        self.datastreamInfoContainerView.hidden = NO;
        self.idLabel.text = [self.datastreamModel.info valueForKeyPath:@"id"];
        self.currentValueLabel.text = [NSString stringWithFormat:@"%@%@", [self.datastreamModel.info valueForKeyPath:@"current_value"], [self.datastreamModel.info valueForKeyPath:@"unit.symbol"]];
        self.unitLabel.text = [self.datastreamModel.info valueForKeyPath:@"unit.label"];
        self.minValueLabel.text = [self.datastreamModel.info valueForKeyPath:@"max_value"];
        self.maxValueLabel.text = [self.datastreamModel.info valueForKeyPath:@"min_value"];
        self.lastUpdatedLabel.text = [Utils replaceDates:[NSString stringWithFormat:@"last updated: %@", [self.datastreamModel.info valueForKeyPath:@"at"]]];
        
        // reset the button is this is a newly synced feed
        if (!self.datastreamModel.isSubscribed) {
            self.subscribeUnsubscribeButton.userInteractionEnabled = YES;
            [self.subscribeUnsubscribeButton setTitle:@"Subscribe" forState:UIControlStateNormal];
        }
        
    } else {
        self.datastreamInfoContainerView.hidden = YES;
    }
}

#pragma mark - Cosm Datastream

@synthesize datastreamModel;

#pragma mark - Cosm Model Delegate Methods

- (void)modelDidFetch:(COSMModel *)model {
    [self updateLabels];
}

- (void)modelFailedToFetch:(COSMModel *)model withError:(NSError *)error json:(id)JSON {
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
    [self updateLabels];
}

#pragma mark - Interface Builder

- (IBAction)loadDatastreamTouched:(id)sender {
    // hide the keyboard
    [self.apiKeyTextField resignFirstResponder];
    [self.feedIdTextField resignFirstResponder];
    [self.datastreamIdTextField resignFirstResponder];
    
    // check data has been entered by the use
    if (!self.apiKeyTextField.text.length) {
        [Utils alert:@"Missing COSM API Key" message:@"Please add your API key"];
        return;
    } else if (!self.feedIdTextField.text.length) {
        [Utils alert:@"Missing Feed ID" message:@"Please enter the feed ID of the datastream you wish to fetch"];
        return;
    } else if (!self.datastreamIdTextField.text.length) {
        [Utils alert:@"Missing Datastrean ID" message:@"Please enter the datastream ID of the datastream you wish to fetch"];
        return;
    }
    
    // clear any previous model
    self.datastreamModel.delegate = nil;
    [self.datastreamModel unsubscribe];
    
    // set the API key for Cosm
    [[COSMAPI defaultAPI] setApiKey:self.apiKeyTextField.text];
    
    // create a new datastream model
    self.datastreamModel = [[COSMDatastreamModel alloc] init];
    self.datastreamModel.feedId = [self.feedIdTextField.text integerValue];
    [self.datastreamModel.info setObject:self.datastreamIdTextField.text forKey:@"id"];
    self.datastreamModel.delegate = self;
    [self.datastreamModel fetch];
}

- (IBAction)subscribeUnsubscribeTouched:(id)sender {
    self.subscribeUnsubscribeButton.userInteractionEnabled = NO;
    if (self.datastreamModel.isSubscribed) {
        [self.subscribeUnsubscribeButton setTitle:@"Unsubscribing..." forState:UIControlStateNormal];
        [self.datastreamModel unsubscribe];
    } else {
        [self.subscribeUnsubscribeButton setTitle:@"Subscribing..." forState:UIControlStateNormal];
        [self.datastreamModel subscribe];
    }
}

@synthesize apiKeyTextField, feedIdTextField, datastreamIdTextField, datastreamInfoContainerView, idLabel, currentValueLabel, unitLabel, minValueLabel, maxValueLabel, lastUpdatedLabel;

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
    [defaults setObject:self.datastreamIdTextField.text forKey:@"Datastream Id"];
    [defaults synchronize];
}

- (void)loadUserEnteredInfo {
    // load any values previously inputed from the user
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    self.apiKeyTextField.text = [defaults objectForKey:@"Api Key"];
    self.feedIdTextField.text = [defaults objectForKey:@"Feed Id"];
    self.datastreamIdTextField.text = [defaults objectForKey:@"Datastream Id"];
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    
    // hide the information until we have successful
    // created a connection 
    self.datastreamInfoContainerView.hidden = YES;
    
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
