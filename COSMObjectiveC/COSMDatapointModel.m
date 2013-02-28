#import "COSMDatapointModel.h"

@implementation COSMDatapointModel

#pragma mark - Data

@synthesize feedId;

#pragma mark - Synchronization

- (BOOL)isNew {
    return ([self.info valueForKeyPath:@"at"] != NULL);
}

- (void)parse:(id)JSON {
    self.info = [NSMutableDictionary dictionaryWithDictionary:JSON];
}

@end
