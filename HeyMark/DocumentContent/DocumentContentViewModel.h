//
//  DocumentContentViewModel.h
//  HeyMark
//
//  Created by Jinwoo Kim on 6/16/22.
//

#import <Foundation/Foundation.h>
#import "Document.h"

NS_ASSUME_NONNULL_BEGIN

static NSNotificationName const DocumentContentViewModelDidChangeTextNotificationName = @"DocumentContentViewModelDidChangeTextNotificationName";
static NSString * const DocumentContentViewModelDidChangeTextStringKey = @"DocumentContentViewModelDidChangeTextStringKey";
static NSString * const DocumentContentViewModelDidChangeAttributedTextKey = @"DocumentContentViewModelDidChangeAttributedStringKey";

@interface DocumentContentViewModel : NSObject
@property (class, readonly, nonatomic) NSString *customizationIdentifier;
@property (retain, readonly) Document * _Nullable document;
- (void)updateDocument:(Document *)document open:(BOOL)open;
- (void)textDidChange:(NSString *)text;
- (void)save;
@end

NS_ASSUME_NONNULL_END
