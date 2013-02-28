#import "COSMDatapointModel.h"

@implementation COSMDatapointModel

#pragma mark - Data

@synthesize feedId;

#pragma mark - Synchronization

- (void)parse:(id)JSON {
    self.info = [NSMutableDictionary dictionaryWithDictionary:JSON];
    self.isNew = FALSE;
}

@end
