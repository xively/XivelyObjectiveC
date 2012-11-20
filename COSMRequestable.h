#import <Foundation/Foundation.h>

@interface COSMRequestable : NSObject

@property (strong, nonatomic) NSMutableDictionary *parameters;

- (void)useParameter:(NSString*)parameterName withValue:(NSString*)value;
- (void)resetParameters;

@end
