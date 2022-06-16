//
//  DocumentBrowserViewModel.h
//  HeyMark
//
//  Created by Jinwoo Kim on 6/8/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^DocumentBrowserViewModelDocumentWithNameCompletionHandler)(UIDocument * _Nullable url, NSError * _Nullable error);

@interface DocumentBrowserViewModel : NSObject
@property (retain, readonly, nonatomic) NSOperationQueue *queue;
- (void)documentWithName:(NSString *)name completionHandler:(DocumentBrowserViewModelDocumentWithNameCompletionHandler)completionHandler;
@end

NS_ASSUME_NONNULL_END
