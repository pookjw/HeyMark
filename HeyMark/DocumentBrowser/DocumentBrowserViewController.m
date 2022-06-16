//
//  DocumentBrowserViewController.m
//  HeyMark
//
//  Created by Jinwoo Kim on 6/8/22.
//

#import "DocumentBrowserViewController.h"
#import "DocumentBrowserViewModel.h"
#import "DocumentContentViewController.h"

@interface DocumentBrowserViewController () <UIDocumentBrowserViewControllerDelegate, DocumentContentViewControllerDelegate>
@property (retain) DocumentBrowserViewModel *viewModel;
@end

@implementation DocumentBrowserViewController

- (void)dealloc {
    [_viewModel release];
    [super dealloc];
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAttributes];
    [self setupViewModel];
}

- (void)setAttributes {
    self.delegate = self;
    self.allowsDocumentCreation = YES;
    self.allowsPickingMultipleItems = NO;
    self.shouldShowFileExtensions = YES;
}

- (void)setupViewModel {
    DocumentBrowserViewModel *viewModel = [DocumentBrowserViewModel new];
    self.viewModel = viewModel;
    [viewModel release];
}

- (void)presentContentViewControllerAtURL:(NSURL *)documentURL {
    DocumentContentViewController *viewController = [[DocumentContentViewController alloc] initWithFileURL:documentURL delegate:self];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [viewController release];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:nil];
    [navigationController release];
}

- (void)presentContentViewControllerWithDocument:(Document *)document {
    DocumentContentViewController *viewController = [[DocumentContentViewController alloc] initWithDocument:document delegate:self];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [viewController release];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:nil];
    [navigationController release];
}

#pragma mark UIDocumentBrowserViewControllerDelegate

- (void)documentBrowser:(UIDocumentBrowserViewController *)controller didRequestDocumentCreationWithHandler:(void (^)(NSURL * _Nullable, UIDocumentBrowserImportMode))importHandler {
    UIAlertController * __block alertController = [UIAlertController alertControllerWithTitle:@"Enter file name." message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {}];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    
    DocumentBrowserViewModel * __block unretainedViewModel = self.viewModel;
    
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField * _Nullable textField = alertController.textFields.firstObject;
        NSString * _Nullable text = textField.text;
        
        if (text) {
            [unretainedViewModel documentWithName:text completionHandler:^(UIDocument * _Nullable document, NSError * _Nullable error) {
                if (error) {
                    importHandler(nil, UIDocumentBrowserImportModeNone);
                } else {
                    importHandler(document.fileURL, UIDocumentBrowserImportModeMove);
                }
            }];
        } else {
            importHandler(nil, UIDocumentBrowserImportModeNone);
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:doneAction];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}

-(void)documentBrowser:(UIDocumentBrowserViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)documentURLs {
    NSURL * _Nullable documentURL = documentURLs.firstObject;
    if (!documentURL) {
        return;
    }
    
    [self presentContentViewControllerAtURL:documentURL];
}

- (void)documentBrowser:(UIDocumentBrowserViewController *)controller didImportDocumentAtURL:(NSURL *)sourceURL toDestinationURL:(NSURL *)destinationURL {
    [self presentContentViewControllerAtURL:destinationURL];
}

- (void)documentBrowser:(UIDocumentBrowserViewController *)controller failedToImportDocumentAtURL:(NSURL *)documentURL error:(NSError * _Nullable)error {
    NSLog(@"%@", error);
}

#pragma mark DocumentContentViewControllerDelegate

- (void)documentContentViewController:(DocumentContentViewController *)documentContentViewController renameDocument:(Document *)document proposedName:(NSString *)proposedName completionHandler:(void (^)(NSURL * _Nullable, NSError * _Nullable))completionHandler {
    [self renameDocumentAtURL:document.fileURL proposedName:proposedName completionHandler:completionHandler];
}

@end
