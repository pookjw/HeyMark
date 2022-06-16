//
//  DocumentBrowserViewModel.m
//  HeyMark
//
//  Created by Jinwoo Kim on 6/8/22.
//

#import "DocumentBrowserViewModel.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@implementation DocumentBrowserViewModel

- (instancetype)init {
    if (self = [super init]) {
        NSOperationQueue *queue = [NSOperationQueue new];
        queue.qualityOfService = NSQualityOfServiceUtility;
        [self->_queue release];
        self->_queue = [queue retain];
        [queue release];
    }
    
    return self;
}

- (void)dealloc {
    [self.queue cancelAllOperations];
    [_queue release];
    [super dealloc];
}

- (void)documentWithName:(NSString *)name completionHandler:(DocumentBrowserViewModelDocumentWithNameCompletionHandler)completionHandler {
    [self.queue addBarrierBlock:^{
        NSDictionary<NSString *, id> *infoDictionary = NSBundle.mainBundle.infoDictionary;
        NSArray<NSDictionary<NSString *, id> *> *bundleDocumentTypes = infoDictionary[@"CFBundleDocumentTypes"];
        NSDictionary<NSString *, id> *itemContentTypes = bundleDocumentTypes.firstObject;
        NSArray<NSString *> *contentTypes = itemContentTypes[@"LSItemContentTypes"];
        NSString *contentType = contentTypes.firstObject;
        
        if (!contentType) {
            [NSException raise:NSGenericException format:@""];
        }
        
        UTType *utType = [UTType typeWithIdentifier:contentType];
        NSURL *fileURL = [[NSFileManager.defaultManager.temporaryDirectory URLByAppendingPathComponent:name] URLByAppendingPathExtension:utType.preferredFilenameExtension];
        UIDocument *document = [[UIDocument alloc] initWithFileURL:fileURL];
        NSData *data = [[NSData alloc] initWithBytes:nil length:0];
        
        [document performAsynchronousFileAccessUsingBlock:^{
            NSError * _Nullable __autoreleasing error = nil;
            [document writeContents:data toURL:fileURL forSaveOperation:UIDocumentSaveForCreating originalContentsURL:nil error:&error];
            [data release];
            
            if (error) {
                [document release];
                completionHandler(nil, error);
            } else {
                completionHandler([document autorelease], nil);
            }
        }];
    }];
}

@end
