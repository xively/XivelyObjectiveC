#import <Foundation/Foundation.h>
#import "COSMRequestable.h"
#import "COSMModelDelegate.h"
#import "COSMAPI.h"

@interface COSMModel : COSMRequestable {
    NSArray *required;
}

// data
@property (nonatomic, strong) NSMutableDictionary *info;

// State
@property (nonatomic, strong) NSArray *required;
@property BOOL isNew;
@property BOOL isUpdated;
@property BOOL isDeletedFromCOSM;
- (BOOL)isValid;

// Synchronisation
@property (weak) id<COSMModelDelegate> delegate;
@property (nonatomic, strong) COSMAPI *api;

@end
