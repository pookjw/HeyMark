//
//  SceneDelegate.m
//  HeyMark
//
//  Created by Jinwoo Kim on 6/8/22.
//

#import "SceneDelegate.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import "DocumentBrowserViewController.h"

@interface SceneDelegate ()
@end

@implementation SceneDelegate

- (void)dealloc {
    [_window release];
    [super dealloc];
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:windowScene];
    DocumentBrowserViewController *viewController = [[DocumentBrowserViewController alloc] initForOpeningContentTypes:nil];
    window.rootViewController = viewController;
    [viewController release];
    [window makeKeyAndVisible];
    
    self.window = window;
    [window release];
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    NSURL * _Nullable url = URLContexts.allObjects.firstObject.URL;
    if (!url) return;
    
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    DocumentBrowserViewController * __block rootViewController = (DocumentBrowserViewController *)windowScene.keyWindow.rootViewController;
    if (![rootViewController isKindOfClass:[DocumentBrowserViewController class]]) return;
    
    [rootViewController revealDocumentAtURL:url importIfNeeded:YES completion:^(NSURL * _Nullable revealedDocumentURL, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error);
        }
        
        if (revealedDocumentURL) {
            [rootViewController presentContentViewControllerAtURL:revealedDocumentURL];
        }
    }];
}

@end

