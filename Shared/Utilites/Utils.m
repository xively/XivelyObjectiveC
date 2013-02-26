#import "Utils.h"

@implementation Utils

#pragma mark - UI

+ (void)alertUsingJSON:(id)JSON orTitle:(NSString *)fallbackTile message:(NSString*)messageOrNil {
    if ([JSON valueForKeyPath:@"title"] && [JSON valueForKeyPath:@"errors"]) {
        [Utils alert:[JSON valueForKeyPath:@"title"] message:[Utils describe:[JSON valueForKeyPath:@"errors"]]];
    } else {
        [Utils alert:fallbackTile message:[Utils describe:messageOrNil]];
    }
}

+ (void)alert:(NSString *)title message:(NSString *)messageOrNil {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:title
                                                      message:messageOrNil
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}

#pragma mark - String

+ (NSString*)describe:(id)obj {
    if (obj == NULL) {
        return @"";
    }
    else if ([obj isKindOfClass:[NSArray class]]) {
        return [Utils describeArray:obj];
    }
    else if ([obj isKindOfClass:[NSDictionary class]]) {
        return [Utils describeDictionary:obj];
    }
    else if ([obj isKindOfClass:[NSString class]]) {
        return [Utils replaceDates:obj];
    }
    else if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj stringValue];
    }
    else {
        NSLog(@"Utils `describe:` does not know what to do with %@ class %@", obj, [obj class]);
        return obj;
    }
}

+ (NSString*)describeArray:(NSArray *)arr {
    NSMutableString *str = [NSMutableString stringWithString:@""];
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx>0) {
            [str appendString:[NSString stringWithFormat:@", %@", [Utils describe:obj]]];
        } else {
            [str appendString:[Utils describe:obj]];
        }
    }];
    return str;
}

+ (NSString*)describeDictionary:(NSDictionary *)dict {
    NSMutableString *str = [NSMutableString stringWithString:@""];
    __block NSUInteger count = 0;
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (count>0) {
            [str appendString:[NSString stringWithFormat:@", %@: %@", [Utils describe:key], [Utils describe:obj]]];
        } else {
            [str appendString:[NSString stringWithFormat:@"%@: %@", [Utils describe:key], [Utils describe:obj]]];
        }
        ++count;
    }];
    return str;
}

+ (NSString *)replaceDates:(NSString*)str {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([0-9]*?)-([0-9]*?)-([0-9]*?)T([0-9]*?):([0-9]*?):([0-9]*?).([0-9]*?)Z"
                                                                           options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators | NSRegularExpressionAnchorsMatchLines | NSRegularExpressionAllowCommentsAndWhitespace
                                                                             error:&error];
    if (error) {
        NSLog(@"error regexing string: %@", error);
        return str;
    }
    return [regex stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:@"$4:$5 $1/$2/$3"];
}

@end
