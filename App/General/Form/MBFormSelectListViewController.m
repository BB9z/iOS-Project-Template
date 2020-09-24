
#import "MBFormSelectListViewController.h"
#import "Common.h"
#import <MBAppKit/MBGeneralItemExchanging.h>
#import <RFAlpha/RFTimer.h>

@interface MBFormSelectListViewController () {
    BOOL _needsUpdateUIForItem;
}
@end

@implementation MBFormSelectListViewController
RFInitializingRootForUIViewController

- (void)onInit {
    self.clearsSelectionOnViewWillAppear = NO;
    self.autoSearchTimeInterval = 0.6;
}

- (void)afterInit {
}

#pragma mark - Items

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUIForItemIfNeeded];
}

- (void)setItems:(NSArray *)items {
    if (_items != items) {
        _items = items;

        if (self.isViewLoaded) {
            [self updateUIForItem];
        }
        else {
            [self setNeedsUpdateUIWithSegue:nil];
        }
    }
}

- (void)updateUIForItem {
    _needsUpdateUIForItem = NO;

    NSArray *selectedItems = self.selectedItems;
    UITableView *tableView = self.tableView;
    [tableView reloadData];

    for (id item in selectedItems) {
        NSUInteger idx = [self.filteredItems indexOfObject:item];
        if (idx == NSNotFound) {
            continue;
        }

        [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (IBAction)setNeedsUpdateUIWithSegue:(UIStoryboardSegue *)sender {
    _needsUpdateUIForItem = YES;
}

- (void)updateUIForItemIfNeeded {
    if (_needsUpdateUIForItem) {
        [self updateUIForItem];
    }
}

#pragma mark - Return

- (IBAction)onSaveButtonTapped:(id)sender {
    [self callbackThenReturn];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.returnWhenSelected) {
        [self callbackThenReturn];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!self.requireUserPressSave && !self.returnWhenSelected) {
        [self performResultCallBack];
    }

    if (self.autoSearchTimer) {
        [self.autoSearchTimer invalidate];
        self.autoSearchTimer = nil;
    }
}

- (void)callbackThenReturn {
    [self performResultCallBack];
    [self finishSelection];
}

- (void)finishSelection {
    switch (self.returnType) {
        case MBFormSelectListReturnTypePop:
            [self.navigationController popViewControllerAnimated:YES];
            break;

        case MBFormSelectListReturnTypeDismiss:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;

        case MBFormSelectListReturnTypeNoAction:
        default:
            break;
    }
}

- (void)performResultCallBack {
    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    for (NSIndexPath *indexPath in indexPaths) {
        [indexSet addIndex:indexPath.row];
    }
    NSArray *selectedItems = [self.filteredItems objectsAtIndexes:indexSet];
    dout_debug(@"列表选中：%@", selectedItems);

    if (self.didEndSelection) {
        self.didEndSelection(self, selectedItems);
    }
}

#pragma mark - Clear selection

- (IBAction)onClearSelection:(id)sender {
    [self.tableView deselectRows:YES];
}

- (IBAction)onClearSelectionAndReturn:(id)sender {
    [self.tableView deselectRows:YES];
    [self callbackThenReturn];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<MBFormSelectTableViewCell> cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    RFAssert([cell conformsToProtocol:@protocol(MBFormSelectTableViewCell)], @"MBFormSelectListViewController 的 cell 必须符合 MBFormSelectTableViewCell 协议");
    cell.value = self.filteredItems[indexPath.row];
    return (id)cell;
}

#pragma mark - 筛选基础支持

- (NSArray *)filteredItems {
    return _filteredItems?: self.items;
}

#pragma mark - Search

- (void)setAutoSearchTimeInterval:(float)autoSearchTimeInterval {
    _autoSearchTimeInterval = autoSearchTimeInterval;
    if (autoSearchTimeInterval <= 0) {
        [self.autoSearchTimer invalidate];
    }
    else {
        self.autoSearchTimer.timeInterval = autoSearchTimeInterval;
    }
}

- (RFTimer *)autoSearchTimer {
    if (!_autoSearchTimer && self.autoSearchTimeInterval > 0) {
        _autoSearchTimer = [RFTimer new];
        _autoSearchTimer.timeInterval = self.autoSearchTimeInterval;

        @weakify(self);
        [_autoSearchTimer setFireBlock:^(RFTimer *timer, NSUInteger repeatCount) {
            @strongify(self);
            [self autoSearch];
        }];
    }
    return _autoSearchTimer;
}

- (void)autoSearch {
    self.autoSearchTimer.suspended = YES;

    NSString *keyword = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _douto(keyword)

    if (![keyword isEqualToString:self.searchingKeyword]) {
        [self doSearchWithKeyword:keyword];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.autoSearchTimer.suspended = YES;
    self.autoSearchTimer.suspended = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *keyword = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self doSearchWithKeyword:keyword];
}

- (void)doSearchWithKeyword:(NSString *)keyword {
    if (![self.searchingKeyword isEqualToString:keyword]) {
        self.searchOperation = nil;
    }
    self.searchingKeyword = keyword;

    // 请求并更新结果
}

- (void)setSearchOperation:(NSOperation *)searchOperation {
    if (_searchOperation) {
        [_searchOperation cancel];
    }

    _searchOperation = searchOperation;
}

@end

@implementation MBFormSelectTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    self.accessoryType = selected? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    [super setSelected:selected animated:animated];
}

- (void)setValue:(id)value {
    _value = value;
    [self displayForValue:value];
}

- (void)displayForValue:(id<MBItemExchanging>)value {
    if ([value respondsToSelector:@selector(displayString)]) {
        self.valueDisplayLabel.text = value.displayString;
    }
    else {
        self.valueDisplayLabel.text = [NSString stringWithFormat:@"%@", value];
    }
}

@end
