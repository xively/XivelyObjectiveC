// Utils.h
//
// Contains generic functions, algorthyms & static resources
// which are used through out the app. For simplicity, everything
// is a class method
//
#import <Foundation/Foundation.h>
@class ISO8601DateFormatter;

@interface Utils : NSObject

// UI
+ (void)alertUsingJSON:(id)JSON orTitle:(NSString *)fallbackTile message:(NSString*)messageOrNil;
+ (void)alert:(NSString *)title message:(NSString *)messageOrNil;

// String
+ (NSString*)describe:(id)obj;
+ (NSString*)describeArray:(NSArray *)arr;
+ (NSString*)describeDictionary:(NSDictionary *)dict;
+ (NSString *)replaceDates:(NSString*)str;

// Date
+ (ISO8601DateFormatter *)dateFormmater;

@end
