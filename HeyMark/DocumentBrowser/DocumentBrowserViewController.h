//
//  DocumentBrowserViewController.h
//  HeyMark
//
//  Created by Jinwoo Kim on 6/8/22.
//

#import <UIKit/UIKit.h>
#import "Document.h"

@interface DocumentBrowserViewController : UIDocumentBrowserViewController
- (void)presentContentViewControllerAtURL:(NSURL *)documentURL;
- (void)presentContentViewControllerWithDocument:(Document *)document;
@end
