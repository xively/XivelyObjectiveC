#import <Foundation/Foundation.h>
#import "COSMRequestable.h"
#import "COSMFeedCollectionDelegate.h"
#import "COSMAPI.h"

@interface COSMFeedCollection : COSMRequestable

// Data
@property (nonatomic, strong) NSMutableDictionary *info;
@property (nonatomic, strong) NSMutableArray *feeds;

// Synchronisation
@property (nonatomic, strong) COSMAPI *api;
@property (weak) id<COSMFeedCollectionDelegate> delegate;
- (void)fetch;
- (void)removeDeletedFromCOSM;
- (void)parse:(id)JSON;

@end
