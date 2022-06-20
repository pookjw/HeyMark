//
//  TestFindView.m
//  HeyMark
//
//  Created by Jinwoo Kim on 6/20/22.
//

#import "TestFindView.h"

@interface TestFindView () <UIFindInteractionDelegate, UITextSearching>

@end

@implementation TestFindView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = UIColor.systemPinkColor;
        
        UIFindInteraction *findInteraction = [[UIFindInteraction alloc] initWithSessionDelegate:self];
        [self addInteraction:findInteraction];
        [self->_findInteraction release];
        self->_findInteraction = [findInteraction retain];
        [findInteraction release];
    }
    
    return self;
}

- (void)dealloc {
    [_findInteraction release];
    [super dealloc];
}

#pragma mark UIFindInteractionDelegate

- (UIFindSession *)findInteraction:(UIFindInteraction *)interaction sessionForView:(UIView *)view {
    UITextSearchingFindSession *session = [[UITextSearchingFindSession alloc] initWithSearchableObject:self];
    return [session autorelease];
}

- (void)findInteraction:(UIFindInteraction *)interaction didBeginFindSession:(UIFindSession *)session {
    
}

- (void)findInteraction:(UIFindInteraction *)interaction didEndFindSession:(UIFindSession *)session {
    
}

#pragma mark UITextSearching

- (void)performTextSearchWithQueryString:(NSString *)string usingOptions:(UITextSearchOptions *)options resultAggregator:(id<UITextSearchAggregator>)aggregator {
    
}

- (NSComparisonResult)compareFoundRange:(UITextRange *)foundRange toRange:(UITextRange *)toRange inDocument:(UITextSearchDocumentIdentifier)document {
    return NSOrderedSame;
}

- (NSComparisonResult)compareOrderFromDocument:(UITextSearchDocumentIdentifier)fromDocument toDocument:(UITextSearchDocumentIdentifier)toDocument {
    return NSOrderedSame;
}

- (void)decorateFoundTextRange:(UITextRange *)range inDocument:(UITextSearchDocumentIdentifier)document usingStyle:(UITextSearchFoundTextStyle)style {
    
}

- (void)clearAllDecoratedFoundText {
    
}

- (void)willHighlightFoundTextRange:(UITextRange *)range inDocument:(UITextSearchDocumentIdentifier)document {
    
}

- (void)scrollRangeToVisible:(UITextRange *)range inDocument:(UITextSearchDocumentIdentifier)document {
    
}

- (UITextRange *)selectedTextRange {
    return nil;
}

- (UITextSearchDocumentIdentifier)selectedTextSearchDocument {
    return @"";
}

- (void)replaceFoundTextInRange:(UITextRange *)range inDocument:(UITextSearchDocumentIdentifier)document withText:(NSString *)replacementText {
    
}

- (void)replaceAllOccurrencesOfQueryString:(NSString *)queryString usingOptions:(UITextSearchOptions *)options withText:(NSString *)replacementText {
    
}

- (BOOL)shouldReplaceFoundTextInRange:(UITextRange *)range inDocument:(UITextSearchDocumentIdentifier)document withText:(NSString *)replacementText {
    return YES;
}

@end
