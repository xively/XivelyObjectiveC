#import <Foundation/Foundation.h>

@class COSMFeedCollection;

@protocol COSMFeedCollectionDelegate <NSObject>
@optional
///---------------------------------------------------------------------------------------
/// @name Fetching
///---------------------------------------------------------------------------------------

/** Tells the delegate that the fetch was successful.
 @param feedCollection Reference to the collection which was fetch */
- (void)feedCollectionDidFetch:(COSMFeedCollection *)feedCollection;

/** Tells the delegate that the fetch failed.
 @param feedCollection Reference to the collection which attempted to fetch
 @param error An error or `nil`
 @param json JSON representation of the error, or a JSON responce from Cosm, or `nil` */
- (void)feedCollectionFailedToFetch:(COSMFeedCollection *)feedCollection withError:(NSError*)error json:(id)JSON;

@end
