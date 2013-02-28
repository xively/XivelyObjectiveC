#import "COSMRequestable.h"

@implementation COSMRequestable

@synthesize parameters;

- (id)init {
    if (self=[super init]) {
        self.parameters = [[NSMutableDictionary alloc] initWithCapacity:13];
    }
    return self;
}

- (void)useParameter:(NSString*)parameterName withValue:(NSString*)value {
    if (value != NULL) {
        [parameters setObject:value forKey:parameterName];
    }
}

- (void)resetParameters {
    [parameters removeAllObjects];
}

@end
