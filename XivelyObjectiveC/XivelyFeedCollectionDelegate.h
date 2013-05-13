#import <Foundation/Foundation.h>

@class XivelyFeedCollection;

@protocol XivelyFeedCollectionDelegate <NSObject>
@optional
///---------------------------------------------------------------------------------------
/// @name Fetching
///---------------------------------------------------------------------------------------

/** Tells the delegate that the fetch was successful.
 @param feedCollection Reference to the collection which was fetch */
- (void)feedCollectionDidFetch:(XivelyFeedCollection *)feedCollection;

/** Tells the delegate that the fetch failed.
 @param feedCollection Reference to the collection which attempted to fetch
 @param error An error or `nil`
 @param json JSON representation of the error, or a JSON responce from Xively, or `nil` */
- (void)feedCollectionFailedToFetch:(XivelyFeedCollection *)feedCollection withError:(NSError*)error json:(id)JSON;

@end
