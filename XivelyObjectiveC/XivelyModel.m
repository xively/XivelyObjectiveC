#import "COSMModel.h"

@implementation COSMModel

#pragma mark - Data

@synthesize info;

#pragma mark - State

- (BOOL)isNew {
    return NO;
}

@synthesize isDeletedFromCosm;

#pragma mark - Synchronisation 

@synthesize api, delegate;

- (NSString *)resourceURLString {
    return nil;
}

- (void)parse:(id)JSON {}

#pragma mark - Lifecycle

- (id)init {
    if (self=[super init]) {
        isDeletedFromCosm = FALSE;
        info = [[NSMutableDictionary alloc] initWithCapacity:25.0f];
		api = [COSMAPI defaultAPI];
	}
    return self;
}

@end
