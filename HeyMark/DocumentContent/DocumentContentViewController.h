//
//  DocumentContentViewController.h
//  HeyMark
//
//  Created by Jinwoo Kim on 6/16/22.
//

#import <UIKit/UIKit.h>
#import "Document.h"
#import "DocumentContentViewControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface DocumentContentViewController : UIViewController
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFileURL:(NSURL *)fileURL delegate:(id<DocumentContentViewControllerDelegate>)delegate;
- (instancetype)initWithDocument:(Document *)document delegate:(id<DocumentContentViewControllerDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
