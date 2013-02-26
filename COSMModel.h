#import <Foundation/Foundation.h>
#import "COSMRequestable.h"
#import "COSMModelDelegate.h"
#import "COSMAPI.h"

@interface COSMModel : COSMRequestable

// data
@property (nonatomic, strong) NSMutableDictionary *info;

// State
@property BOOL isNew;
@property BOOL isDeletedFromCOSM;

// Synchronisation
@property (nonatomic, weak) id<COSMModelDelegate> delegate;
@property (nonatomic, strong) COSMAPI *api;
- (NSString *)resourceURLString;
- (void)parse:(id)JSON;

@end
