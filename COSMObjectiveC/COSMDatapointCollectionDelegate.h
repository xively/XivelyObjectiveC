#import <Foundation/Foundation.h>
@class COSMDatapointCollection;

@protocol COSMDatapointCollectionDelegate <NSObject>
@optional
- (void)datapointCollectionDidSaveAll:(COSMDatapointCollection *)collection;
- (void)datapointCollectionFailedToSaveAll:(COSMDatapointCollection *)collection withError:(NSError *)error json:(id)JSON;
@end
