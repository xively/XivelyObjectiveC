#import <UIKit/UIKit.h>
#import "COSM.h"

@interface FeedViewController : UIViewController<COSMSubscribableDelegate, UITableViewDataSource, UITextFieldDelegate>

// UI
- (void)updateDatastreamLabels;
@property (nonatomic, weak) UITableView *tableView;

// Cosm Datastream
@property (nonatomic, strong) COSMFeedModel *feedModel;

// Cosm Model Delegate Methods
- (void)modelDidFetch:(COSMModel *)model;
- (void)modelFailedToFetch:(COSMModel *)model withError:(NSError *)error json:(id)JSON;
// Socket Connection Delegate Methods
- (void)modelDidSubscribe:(COSMModel *)model;
- (void)modelDidUnsubscribe:(COSMModel *)model withError:(NSError *)error;
- (void)modelUpdatedViaSubscription:(COSMModel *)model;

// Interface Builder
- (IBAction)fetchFeedTouched:(id)sender;
- (IBAction)subscribeUnsubscribeTouched:(id)sender;
@property (nonatomic, weak) IBOutlet UITextField *apiKeyTextField;
@property (nonatomic, weak) IBOutlet UITextField *feedIdTextField;
@property (nonatomic, weak) IBOutlet UIButton *subscribeUnsubscribeButton;

// UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField;

// Utils
- (void)saveUserInfo;
- (void)loadUserEnteredInfo;

// UITableView Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;

@end
