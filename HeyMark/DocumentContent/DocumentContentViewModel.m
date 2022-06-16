//
//  DocumentContentViewModel.m
//  HeyMark
//
//  Created by Jinwoo Kim on 6/16/22.
//

#import "DocumentContentViewModel.h"

@interface DocumentContentViewModel ()
@property (retain) NSOperationQueue *queue;
@end

@implementation DocumentContentViewModel

- (instancetype)init {
    if (self = [super init]) {
        [self->_document release];
        self->_document = nil;
        
        NSOperationQueue *queue = [NSOperationQueue new];
        queue.qualityOfService = NSQualityOfServiceUtility;
        self.queue = queue;
        [queue release];
    }
    
    return self;
}

- (void)dealloc {
    [_document release];
    [_queue release];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([object isEqual:self.document]) {
        if ([keyPath isEqualToString:@"text"]) {
            [self postDidChangeTextNotification];
        } else {
            return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    } else {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

+ (NSString *)customizationIdentifier {
    NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
    return [bundleIdentifier stringByAppendingString:@".DocumentContent"];
}

- (void)updateDocument:(Document *)document open:(BOOL)open {
    if (self.document) {
        [self.document removeObserver:self forKeyPath:@"text"];
    }
    
    [self->_document release];
    self->_document = [document retain];
    [document addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    
    if (open) {
        [document openWithCompletionHandler:^(BOOL success) {}];
    }
}

- (void)textDidChange:(NSString *)text {
    [self.queue addOperationWithBlock:^{
        self.document.text = text;
    }];
}

- (void)save {
    [self.queue addOperationWithBlock:^{
        [self.document save];
    }];
}

- (void)postDidChangeTextNotification {
    [self.queue addOperationWithBlock:^{
        Document *document = self.document;
        NSData *data = document.data;
        NSString *text = document.text;
        
        NSError * _Nullable __autoreleasing error = nil;
        NSAttributedStringMarkdownParsingOptions *options = [NSAttributedStringMarkdownParsingOptions new];
        options.allowsExtendedAttributes = YES;
        options.appliesSourcePositionAttributes = YES;
        options.failurePolicy = NSAttributedStringMarkdownParsingFailureReturnError;
        options.interpretedSyntax = NSAttributedStringMarkdownInterpretedSyntaxInlineOnlyPreservingWhitespace;
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithMarkdown:data options:options baseURL:document.fileURL error:&error];
        [options release];
        
        NSMutableDictionary<NSString *, id> *userInfo = [NSMutableDictionary<NSString *, id> new];
        
        if (text) {
            userInfo[DocumentContentViewModelDidChangeTextStringKey] = text;
        } else {
            userInfo[DocumentContentViewModelDidChangeTextStringKey] = [NSNull null];
        }
        
        if ((error) || (!attributedString)) {
            NSLog(@"%@", error);
            userInfo[DocumentContentViewModelDidChangeAttributedTextKey] = [NSNull null];
        } else {
            userInfo[DocumentContentViewModelDidChangeAttributedTextKey] = attributedString;
        }
        
        [NSNotificationCenter.defaultCenter postNotificationName:DocumentContentViewModelDidChangeTextNotificationName
                                                          object:self
                                                        userInfo:userInfo];
        [userInfo release];
    }];
}

@end
