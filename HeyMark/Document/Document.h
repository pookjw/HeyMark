//
//  Document.h
//  HeyMark
//
//  Created by Jinwoo Kim on 6/8/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Document : UIDocument
@property (assign, nonatomic) NSString * _Nullable text;
@property (retain) NSData * _Nullable data;
- (void)save;
@end

NS_ASSUME_NONNULL_END
