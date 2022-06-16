//
//  Document.m
//  HeyMark
//
//  Created by Jinwoo Kim on 6/8/22.
//

#import "Document.h"

@implementation Document

- (void)dealloc {
    [_data release];
    [super dealloc];
}

- (NSString *)text {
    @synchronized (self) {
        NSData * _Nullable data = self.data;
        if (!data) return nil;
        if (![data isKindOfClass:[NSData class]]) return nil;
        NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return [text autorelease];
    }
}

- (void)setText:(NSString *)text {
    @synchronized (self) {
        [self willChangeValueForKey:@"text"];
        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        self.data = data;
        [self didChangeValueForKey:@"text"];
        
        [self autosaveWithCompletionHandler:^(BOOL success) {
            
        }];
    }
}
    
- (id)contentsForType:(NSString*)typeName error:(NSError **)errorPtr {
    return self.data;
}
    
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)errorPtr {
    [self willChangeValueForKey:@"text"];
    self.data = contents;
    [self didChangeValueForKey:@"text"];
    return YES;
}

- (void)save{
    [self performAsynchronousFileAccessUsingBlock:^{
        [self saveToURL:self.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            
        }];
    }];
}

@end
