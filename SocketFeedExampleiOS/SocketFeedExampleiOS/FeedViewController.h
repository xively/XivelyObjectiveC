#import <UIKit/UIKit.h>
#import "Xively.h"

@interface FeedViewController : UIViewController<XivelySubscribableDelegate, UITableViewDataSource, UITextFieldDelegate>

// UI
- (void)updateView;
@property (nonatomic, weak) UITableView *tableView;

// Xively Datastream
@property (nonatomic, strong) XivelyFeedModel *feedModel;

// Xively Model Delegate Methods
- (void)modelDidFetch:(XivelyModel *)model;
- (void)modelFailedToFetch:(XivelyModel *)model withError:(NSError *)error json:(id)JSON;
// Socket Connection Delegate Methods
- (void)modelDidSubscribe:(XivelyModel *)model;
- (void)modelDidUnsubscribe:(XivelyModel *)model withError:(NSError *)error;
- (void)modelUpdatedViaSubscription:(XivelyModel *)model;

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
