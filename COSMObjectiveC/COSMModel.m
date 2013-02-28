#import "COSMModel.h"

@interface COSMModel () {}
@property (nonatomic, readonly) NSString *resourceFormat;
@end

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

@synthesize isNew, isDeletedFromCOSM;

#pragma mark - Synchronisation 

@synthesize api;

- (NSString *)resourceURLString {
    return nil;
}

- (void)parse:(id)JSON {}

@end
