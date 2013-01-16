#import "COSMModel.h"

@implementation COSMModel

@synthesize info, delegate;

#pragma mark - Lifecycle 

- (id)init {
    if (self=[super init]) {
        isNew = YES;
        isDeletedFromCOSM = FALSE;
        info = [[NSMutableDictionary alloc] initWithCapacity:25.0f];
		api = [COSMAPI defaultAPI];
	}
    return self;
}

#pragma mark - State

@synthesize isNew, isDeletedFromCOSM, required;

- (BOOL)isValid {
    BOOL valid = YES;
    NSEnumerator *requireEnumerator = [required objectEnumerator];
    id requiredKey;
    while (requiredKey = [requireEnumerator nextObject]) {
        id object = [info objectForKey:requiredKey];
        if (object == NULL || ([object isKindOfClass:[NSString class]] && [object isEqualToString:@""])) {
            NSLog(@"Object does not contain %@", requiredKey);
            valid = NO;
        }
        
    }
    return valid;
}

#pragma mark - Synchronisation 

@synthesize api;

@end
