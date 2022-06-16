//
//  DocumentContentViewController.m
//  HeyMark
//
//  Created by Jinwoo Kim on 6/16/22.
//

#import "DocumentContentViewController.h"
#import "DocumentContentViewModel.h"

@interface DocumentContentViewController () <UITextViewDelegate, UINavigationItemRenameDelegate>
@property (retain) UIStackView *stackView;
@property (retain) UITextView *editorTextView;
@property (retain) UITextView *previewTextView;
@property (retain) DocumentContentViewModel *viewModel;
@property (assign) id<DocumentContentViewControllerDelegate> delegate;
@end

@implementation DocumentContentViewController

- (instancetype)initWithFileURL:(NSURL *)fileURL delegate:(nonnull id<DocumentContentViewControllerDelegate>)delegate {
    Document *document = [[Document alloc] initWithFileURL:fileURL];
    self = [self initWithDocument:document delegate:delegate];
    [document release];
    
    return self;
}

- (instancetype)initWithDocument:(Document *)document delegate:(nonnull id<DocumentContentViewControllerDelegate>)delegate {
    if (self = [self init]) {
        self.delegate = delegate;
        [self loadViewIfNeeded];
        [self updateDocument:document];
    }
    
    return self;
}

- (void)dealloc {
    [_editorTextView release];
    [_previewTextView release];
    [_viewModel release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAttributes];
    [self configureStackView];
    [self configureEditorTextView];
    [self configurePreviewTextView];
    [self configureViewModel];
    [self bind];
}

- (void)setAttributes {
    NSString *customizationIdentifier = DocumentContentViewModel.customizationIdentifier;
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    self.navigationItem.renameDelegate = self;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.navigationItem.customizationIdentifier = customizationIdentifier;
    self.navigationController.navigationBar.prefersLargeTitles = NO;
    
    //
    
    UIBarButtonItem *undoItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"arrow.uturn.backward"] style:UIBarButtonItemStylePlain target:self action:@selector(undo:)];
    UIBarButtonItem *redoItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"arrow.uturn.forward"] style:UIBarButtonItemStylePlain target:self action:@selector(redo:)];
    UIBarButtonItemGroup *doGroup = [UIBarButtonItemGroup fixedGroupWithRepresentativeItem:nil items:@[undoItem, redoItem]];
    [undoItem release];
    [redoItem release];
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"square.and.arrow.down"] style:UIBarButtonItemStylePlain target:self action:@selector(save:)];
    UIBarButtonItemGroup *saveGroup = [saveItem creatingFixedGroup];
    [saveItem release];
    
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"trash"] style:UIBarButtonItemStylePlain target:self action:@selector(delete:)];
    UIBarButtonItemGroup *deleteGroup = [deleteItem creatingFixedGroup];
    [deleteItem release];
    
    UIBarButtonItem *renameItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"pencil"] style:UIBarButtonItemStylePlain target:self action:@selector(rename:)];
    UIBarButtonItemGroup *renameGroup = [renameItem creatingFixedGroup];
    [renameItem release];
    
    UIBarButtonItem *boldItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"bold"] style:UIBarButtonItemStylePlain target:self action:@selector(makeBoldWithSelectedRange:)];
    boldItem.title = @"Bold";
    UIBarButtonItemGroup *boldGroup = [boldItem creatingOptionalGroupWithCustomizationIdentifier:[customizationIdentifier stringByAppendingString:@".bold"] inDefaultCustomization:YES];
    [boldItem release];
    
    UIBarButtonItem *textSizeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"plus.forwardslash.minus"] style:UIBarButtonItemStylePlain target:nil action:nil];
    UIBarButtonItem *decrementItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"minus"] style:UIBarButtonItemStylePlain target:self action:@selector(decreaseSize:)];
    UIBarButtonItem *incrementItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"plus"] style:UIBarButtonItemStylePlain target:self action:@selector(increaseSize:)];
    UIBarButtonItemGroup *textSizeGroup = [UIBarButtonItemGroup optionalGroupWithCustomizationIdentifier:[customizationIdentifier stringByAppendingString:@".textSize"] inDefaultCustomization:YES representativeItem:textSizeItem items:@[decrementItem, incrementItem]];
    [textSizeItem release];
    [incrementItem release];
    [decrementItem release];
    
    self.navigationItem.leadingItemGroups = @[doGroup];
    self.navigationItem.centerItemGroups = @[boldGroup, textSizeGroup];
    self.navigationItem.trailingItemGroups = @[renameGroup, deleteGroup, saveGroup];
    
    //
    
    self.navigationItem.titleMenuProvider = ^UIMenu * _Nullable (NSArray<UIMenuElement *> *suggestedActions) {
        UIMenu *menu = [UIMenu menuWithChildren:suggestedActions];
        return menu;
    };
    self.navigationItem.style = UINavigationItemStyleEditor;
    self.navigationController.navigationBar.preferredBehavioralStyle = UIBehavioralStylePad;
    
    DocumentContentViewController * __block unretainedSelf = self;
    self.navigationItem.backAction = [UIAction actionWithHandler:^(__kindof UIAction * _Nonnull action) {
        [unretainedSelf dismissViewControllerAnimated:YES completion:^{}];
    }];
}

- (void)updateDocument:(Document *)document {
    [self.viewModel updateDocument:document open:NO];
    
    self.title = nil;
    DocumentContentViewController * __block unretainedSelf = self;
    [document openWithCompletionHandler:^(BOOL success) {
        if (success) {
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                unretainedSelf.title = document.localizedName;
            }];
        }
    }];
    
    NSURL * __block fileURL = document.fileURL;
    
    UIDocumentProperties *documentProperties = [[UIDocumentProperties alloc] initWithURL:fileURL];
    documentProperties.wantsIconRepresentation = YES;
    
    NSItemProvider * _Nullable itemProvier = [[NSItemProvider alloc] initWithContentsOfURL:fileURL];
    
    if (itemProvier) {
        documentProperties.dragItemsProvider = ^NSArray<UIDragItem *> *(id<UIDragSession> dragSession) {
            UIDragItem *dragItem = [[UIDragItem alloc] initWithItemProvider:itemProvier];
            return @[[dragItem autorelease]];
        };
    }
    
    [itemProvier release];
    
    documentProperties.activityViewControllerProvider = ^UIActivityViewController * _Nonnull{
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
        return [activityController autorelease];
    };
    
    self.navigationItem.documentProperties = documentProperties;
    [documentProperties release];
}

- (void)configureStackView {
    UIStackView *stackView = [UIStackView new];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stackView];
    [NSLayoutConstraint activateConstraints:@[
        [stackView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [stackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [stackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [stackView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    self.stackView = stackView;
    [stackView release];
}

- (void)configureEditorTextView {
    UITextView *editorTextView = [UITextView new];
    editorTextView.delegate = self;
    
    UILabel *inputAccessoryViewLabel = [UILabel new];
    inputAccessoryViewLabel.text = @"UIResponder - inputAccessoryView";
    inputAccessoryViewLabel.backgroundColor = UIColor.whiteColor;
    inputAccessoryViewLabel.textColor = UIColor.blackColor;
    inputAccessoryViewLabel.textAlignment = NSTextAlignmentCenter;
    editorTextView.inputAccessoryView = inputAccessoryViewLabel;
    [inputAccessoryViewLabel sizeToFit];
    [inputAccessoryViewLabel release];
    
//    UILabel *inputViewLabel = [UILabel new];
//    inputViewLabel.text = @"UIResponder - inputView";
//    inputViewLabel.backgroundColor = UIColor.whiteColor;
//    inputViewLabel.textColor = UIColor.blackColor;
//    inputViewLabel.textAlignment = NSTextAlignmentCenter;
//    editorTextView.inputView = inputViewLabel;
//    [inputViewLabel sizeToFit];
//    [inputViewLabel release];
    
    UIBarButtonItem *boldItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"bold"] style:UIBarButtonItemStylePlain target:self action:@selector(makeBoldWithSelectedRange:)];
    UIBarButtonItem *italicItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"italic"] style:UIBarButtonItemStylePlain target:self action:@selector(makeItalicWithSelectedRange:)];
    UIBarButtonItem *styleRepresentedItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"bold.italic.underline"] style:UIBarButtonItemStylePlain target:nil action:nil];
    
    // menu isn't presented... bug?
    styleRepresentedItem.menu = [UIMenu menuWithChildren:@[
        [UICommand commandWithTitle:@"Bold" image:[UIImage systemImageNamed:@"bold"] action:@selector(makeBoldWithSelectedRange:) propertyList:nil],
        [UICommand commandWithTitle:@"Italic" image:[UIImage systemImageNamed:@"italic"] action:@selector(makeItalicWithSelectedRange:) propertyList:nil]
    ]];
    UIBarButtonItemGroup *styleGroup = [[UIBarButtonItemGroup alloc] initWithBarButtonItems:@[boldItem, italicItem] representativeItem:styleRepresentedItem];
    [boldItem release];
    [italicItem release];
    [styleRepresentedItem release];
    
    editorTextView.inputAssistantItem.leadingBarButtonGroups = [editorTextView.inputAssistantItem.leadingBarButtonGroups arrayByAddingObject:styleGroup];
    [styleGroup release];
    
    //
    
    UIBarButtonItem *decrementItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"minus"] style:UIBarButtonItemStylePlain target:self action:@selector(decreaseSize:)];
    UIBarButtonItem *incrementItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"plus"] style:UIBarButtonItemStylePlain target:self action:@selector(increaseSize:)];
    UIBarButtonItem *sizeRepresentedItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"plus.forwardslash.minus"] style:UIBarButtonItemStylePlain target:nil action:nil];
    sizeRepresentedItem.menu = [UIMenu menuWithChildren:@[
        [UICommand commandWithTitle:@"Increase Font Size" image:[UIImage systemImageNamed:@"plus"] action:@selector(increaseSize:) propertyList:nil],
        [UICommand commandWithTitle:@"Decrease Font Size" image:[UIImage systemImageNamed:@"minus"] action:@selector(decreaseSize:) propertyList:nil]
    ]];
    UIBarButtonItemGroup *sizeGroup = [[UIBarButtonItemGroup alloc] initWithBarButtonItems:@[decrementItem, incrementItem] representativeItem:sizeRepresentedItem];
    [decrementItem release];
    [incrementItem release];
    [sizeRepresentedItem release];
    
    editorTextView.inputAssistantItem.trailingBarButtonGroups = [editorTextView.inputAssistantItem.trailingBarButtonGroups arrayByAddingObject:sizeGroup];
    [sizeGroup release];
    
    //
    
    [self.stackView addArrangedSubview:editorTextView];
    self.editorTextView = editorTextView;
    [editorTextView release];
}

- (void)configurePreviewTextView {
    UITextView *previewTextView = [UITextView new];
    previewTextView.editable = NO;
    [self.stackView addArrangedSubview:previewTextView];
    self.previewTextView = previewTextView;
    [previewTextView release];
}

- (void)configureViewModel {
    DocumentContentViewModel *viewModel = [DocumentContentViewModel new];
    self.viewModel = viewModel;
    [viewModel release];
}

- (void)bind {
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(didReceiveTextDidChangeWithNotification:)
                                               name:DocumentContentViewModelDidChangeTextNotificationName
                                             object:self.viewModel];
}

- (void)didReceiveTextDidChangeWithNotification:(NSNotification *)notification {
    id text = notification.userInfo[DocumentContentViewModelDidChangeTextStringKey];
    id attributedText = notification.userInfo[DocumentContentViewModelDidChangeAttributedTextKey];
    
    if ([text isKindOfClass:[NSString class]]) {
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            self.editorTextView.text = text;
        }];
    }
    
    if ([attributedText isKindOfClass:[NSAttributedString class]]) {
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            self.previewTextView.attributedText = attributedText;
        }];
    }
}

- (void)applyStyleToSelectedRangeWithSyntax:(NSString *)syntax {
    NSRange selectedRange = self.editorTextView.selectedRange;
    if (selectedRange.length == 0) return;
    NSString *text = self.editorTextView.text;
    if (text.length == 0) return;
    
    // Using `-[UITextView setText:]` will clear NSUndoManager's stack.
//    NSMutableString *mutableString = [text mutableCopy];
//    self.editorTextView.selectedTextRange

//    [mutableString insertString:syntax atIndex:selectedRange.location];
//    [mutableString insertString:syntax atIndex:selectedRange.location + selectedRange.length + syntax.length];
    
//    self.editorTextView.text = mutableString;
    //    [mutableString release];
    
    NSString *replacementText = [[syntax stringByAppendingString:[self.editorTextView.text substringWithRange:selectedRange]] stringByAppendingString:syntax];
    [self.editorTextView replaceRange:self.editorTextView.selectedTextRange withText:replacementText];

//    UITextRange *endRange = [[self.editorTextView _inputController] _textRangeFromNSRange:NSMakeRange((selectedRange.location + selectedRange.length + syntax.length), 0)];
//    [self.editorTextView replaceRange:endRange withText:syntax];
    
    [self.viewModel textDidChange:self.editorTextView.text];
}

- (void)makeBoldWithSelectedRange:(id)sender {
    [self applyStyleToSelectedRangeWithSyntax:@"**"];
}

- (void)makeItalicWithSelectedRange:(id)sender {
    [self applyStyleToSelectedRangeWithSyntax:@"*"];
}

- (void)undo:(id)sender {
    [self.editorTextView.undoManager undo];
}

- (void)redo:(id)sender {
    [self.editorTextView.undoManager redo];
}

- (void)save:(id)sender {
    [self.viewModel.document save];
}

- (void)delete:(id)sender {
    NSLog(@"TODO");
}

- (void)rename:(id)sender {
    // Private?
    [self.navigationController.navigationBar rename:nil];
}

- (void)increaseSize:(id)sender {
    
}

- (void)decreaseSize:(id)sender {
    
}

#pragma mark UIResponderStandardEditActions

- (void)duplicate:(id)sender {
    NSLog(@"TODO");
}

- (void)export:(id)sender {
    NSLog(@"TODO");
}

- (void)move:(id)sender {
    NSLog(@"TODO");
}

#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    if ([textView isEqual:self.editorTextView]) {
        [self.viewModel textDidChange:textView.text];
    }
}

- (UIMenu *)textView:(UITextView *)textView editMenuForTextInRange:(NSRange)range suggestedActions:(NSArray<UIMenuElement *> *)suggestedActions {
    if ([textView isEqual:self.editorTextView]) {
        UICommand *boldCommand = [UICommand commandWithTitle:@"Bold" image:[UIImage systemImageNamed:@"bold"] action:@selector(makeBoldWithSelectedRange:) propertyList:nil alternates:@[]];
        UICommand *italicCommand = [UICommand commandWithTitle:@"Italic" image:[UIImage systemImageNamed:@"italic"] action:@selector(makeItalicWithSelectedRange:) propertyList:nil alternates:@[]];
        NSArray<UIMenuElement *> *actions = [suggestedActions arrayByAddingObjectsFromArray:@[boldCommand, italicCommand]];
        UIMenu *menu = [UIMenu menuWithChildren:actions];
        return menu;
    } else {
        return nil;
    }
}

#pragma mark UINavigationItemRenameDelegate

- (void)navigationItem:(UINavigationItem *)navigationItem didEndRenamingWithTitle:(NSString *)title {
    if (![title isEqualToString:self.viewModel.document.localizedName]) {
        [self.delegate documentContentViewController:self renameDocument:self.viewModel.document proposedName:title completionHandler:^(NSURL * _Nullable finalURL, NSError * _Nullable error) {
            if (error) {
                NSLog(@"%@", error);
                return;
            }
            Document *document = [[Document alloc] initWithFileURL:finalURL];
            [self updateDocument:document];
        }];
    }
}

- (BOOL)navigationItemShouldBeginRenaming:(UINavigationItem *)navigationItem {
    return YES;
}

//- (NSString *)navigationItem:(UINavigationItem *)navigationItem willBeginRenamingWithSuggestedTitle:(NSString *)title selectedRange:(inout NSRange *)selectedRange {
//
//}

- (BOOL)navigationItem:(UINavigationItem *)navigationItem shouldEndRenamingWithTitle:(NSString *)title {
    return YES;
}

@end
