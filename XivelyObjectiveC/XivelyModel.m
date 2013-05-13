#import "XivelyModel.h"

@implementation XivelyModel

#pragma mark - Data

@synthesize info;

#pragma mark - State

- (BOOL)isNew {
    return NO;
}

@synthesize isDeletedFromXively;

#pragma mark - Synchronisation

@synthesize api, delegate;

- (NSString *)resourceURLString {
    return nil;
}

- (void)parse:(id)JSON {}

#pragma mark - Lifecycle

- (id)init {
    if (self=[super init]) {
        isDeletedFromXively = FALSE;
        info = [[NSMutableDictionary alloc] initWithCapacity:25.0f];
		api = [XivelyAPI defaultAPI];
	}
    return self;
}

@end
