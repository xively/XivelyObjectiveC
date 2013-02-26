#import <UIKit/UIKit.h>
#import "COSM.h"

@interface DatastreamViewController : UIViewController<COSMSubscribableDelegate, UITextFieldDelegate>

// UI
- (void)updateLabels;

// Cosm Datastream
@property (nonatomic, strong) COSMDatastreamModel *datastreamModel;

// Cosm Model Delegate Methods
- (void)modelDidFetch:(COSMModel *)model;
- (void)modelFailedToFetch:(COSMModel *)model withError:(NSError *)error json:(id)JSON;
// Socket Connection Delegate Methods
- (void)modelDidSubscribe:(COSMModel *)model;
- (void)modelDidUnsubscribe:(COSMModel *)model withError:(NSError *)error;
- (void)modelUpdatedViaSubscription:(COSMModel *)model;

// Interface Builder
- (IBAction)loadDatastreamTouched:(id)sender;
- (IBAction)subscribeUnsubscribeTouched:(id)sender;
@property (nonatomic, weak) IBOutlet UITextField *apiKeyTextField;
@property (nonatomic, weak) IBOutlet UITextField *feedIdTextField;
@property (nonatomic, weak) IBOutlet UITextField *datastreamIdTextField;
@property (nonatomic, weak) IBOutlet UIView *datastreamInfoContainerView;
@property (nonatomic, weak) IBOutlet UILabel *idLabel;
@property (nonatomic, weak) IBOutlet UILabel *currentValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *unitLabel;
@property (nonatomic, weak) IBOutlet UILabel *minValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *maxValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastUpdatedLabel;
@property (nonatomic, weak) IBOutlet UIButton *subscribeUnsubscribeButton;

// UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField;

// Utils
- (void)saveUserInfo;
- (void)loadUserEnteredInfo;

@end
