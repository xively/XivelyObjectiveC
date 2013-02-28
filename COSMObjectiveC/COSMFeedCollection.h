#import <Foundation/Foundation.h>
#import "COSMRequestable.h"
#import "COSMFeedCollectionDelegate.h"
#import "COSMAPI.h"

@interface COSMFeedCollection : COSMRequestable {
    
}

////
/// data

// feeds
@property (nonatomic, strong) NSMutableArray *feeds;
// everything else
@property (nonatomic, strong) NSMutableDictionary *info;
- (void)removeDeletedFromCOSM;

////
/// Synchronisation
@property (nonatomic, strong) COSMAPI *api;
@property (weak) id<COSMFeedCollectionDelegate> delegate;
- (void)fetch;
- (void)parse:(id)JSON;

@end
