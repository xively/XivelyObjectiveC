#import "COSMDatapointModel.h"

@implementation COSMDatapointModel

-(id)init {
    if (self = [super init]) {
        required = @[
            @"at",
            @"value"
        ];
    }
    return self;
}

#pragma mark - Synchronization

- (void)parse:(id)JSON {
    self.info = [NSMutableDictionary dictionaryWithDictionary:JSON];
    self.isNew = FALSE;
}

@end
