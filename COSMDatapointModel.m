#import "COSMDatapointModel.h"

@implementation COSMDatapointModel

-(id)init {
    if (self = [super init]) { }
    return self;
}

#pragma mark - Synchronization

- (void)parse:(id)JSON {
    self.info = [NSMutableDictionary dictionaryWithDictionary:JSON];
    self.isNew = FALSE;
}

@end
