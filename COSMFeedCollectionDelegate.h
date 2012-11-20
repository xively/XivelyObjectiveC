#import <Foundation/Foundation.h>

@class COSMFeedCollection;

@protocol COSMFeedCollectionDelegate <NSObject>

@optional
- (void)feedCollectionDidFetch:(COSMFeedCollection *)feedCollection;
- (void)feedCollectionFailedToFetch:(COSMFeedCollection *)feedCollection withError:(NSError*)error json:(id)JSON;

@end
