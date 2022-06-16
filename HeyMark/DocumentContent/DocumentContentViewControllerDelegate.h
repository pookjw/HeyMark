//
//  DocumentContentViewControllerDelegate.h
//  HeyMark
//
//  Created by Jinwoo Kim on 6/16/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DocumentContentViewController;
@class Document;

@protocol DocumentContentViewControllerDelegate <NSObject>
- (void)documentContentViewController:(DocumentContentViewController *)documentContentViewController renameDocument:(Document *)document proposedName:(NSString *)proposedName completionHandler:(void(^)(NSURL *_Nullable finalURL, NSError *_Nullable error))completionHandler;
@end

NS_ASSUME_NONNULL_END
