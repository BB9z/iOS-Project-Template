
#import "MBTableViewDataSource.h"
#if __has_include("MBListDateItem.h")
#import "MBListDateItem.h"
#endif
#import <MBAppKit/MBGeneralItemExchanging.h>
#import <RFKit/NSArray+RFKit.h>
#import <RFKit/UIView+RFAnimate.h>

@implementation MBTableViewDataSource
@dynamic delegate;

- (void)fetchItemsFromViewController:(id)viewController nextPage:(BOOL)nextPage success:(void (^)(MBTableViewDataSource *, NSArray *))success completion:(void (^)(MBTableViewDataSource *))completion {
    @autoreleasepool {
        @weakify(self);
        [super fetchItemsFromViewController:viewController nextPage:nextPage success:^(MBListDataSource *dateSource, NSArray *fetchedItems) {
            @strongify(self);
            if (self.animationReload) {
                if (nextPage) {
                    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:fetchedItems.count];
                    NSUInteger rowCount = dateSource.items.count;
                    [fetchedItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        [indexPaths rf_addObject:[NSIndexPath indexPathForRow:rowCount - idx -1 inSection:0]];
                    }];
                    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                else {
                    if (self.animationReloadDisabledOnFirstPage) {
                        [self.tableView reloadData];
                    }
                    else {
                        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                }
            }
            else {
                [self.tableView reloadData];
            }

            if (success) {
                success((id)dateSource, fetchedItems);
            }
        } completion:(id)completion];
    }
}

- (void)clearData {
    [self prepareForReuse];
    [self.tableView reloadData];
}

- (NSString * _Nonnull (^)(UITableView * _Nonnull, NSIndexPath * _Nonnull, id _Nonnull))cellReuseIdentifier {
    if (!_cellReuseIdentifier) {
        _cellReuseIdentifier = ^NSString *(UITableView *tableView, NSIndexPath *indexPath, id item) {
            return @"Cell";
        };
    }
    return _cellReuseIdentifier;
}

- (void (^)(UITableView * _Nonnull, id _Nonnull, NSIndexPath * _Nonnull, id _Nonnull))configureCell {
    if (!_configureCell) {
        _configureCell = ^(UITableView *tableView, id cell, NSIndexPath *indexPath, id item) {
            if (![cell respondsToSelector:@selector(setItem:)]) return;
#if __has_include("MBListDateItem.h")
            if ([item isKindOfClass:MBListDataItem.class]) {
                item = [(MBListDataItem *)item item];
            }
#endif
            [cell setItem:item];
        };
    }
    return _configureCell;
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self itemAtIndexPath:indexPath];
    NSString *reuseIdentifier = self.cellReuseIdentifier(tableView, indexPath, item);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    RFAssert(cell, @"找不到 reuse identifier 为 %@ 的 cell", reuseIdentifier);
    self.configureCell(tableView, cell, indexPath, item);
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView cellReuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellReuseIdentifier(tableView, indexPath, [self itemAtIndexPath:indexPath]);
}

#pragma mark -

- (void)reconfigVisableCells {
    UITableView *tb = self.tableView;
    for (UITableViewCell *cell in tb.visibleCells) {
        NSIndexPath *ip = [tb indexPathForCell:cell];
        if (!ip) continue;
        self.configureCell(tb, cell, ip, [self itemAtIndexPath:ip]);
    }
}

- (void)removeItem:(id)item withRowAnimation:(UITableViewRowAnimation)animation {
    NSIndexPath *ip = [self indexPathForItem:item];
    if (!ip) return;
    [self.items removeObjectAtIndex:ip.row];
    if (self.items.count == 0 && self.pageEnd) {
        self.empty = YES;
    }
    [self.tableView deleteRowsAtIndexPaths:@[ ip ] withRowAnimation:animation];
}

- (NSIndexPath *)appendItem:(id)item withRowAnimation:(UITableViewRowAnimation)animation {
    if (!item) return nil;
    NSIndexPath *ip = [self indexPathForItem:item];
    if (ip) return nil;
    [self.items addObject:item];
    ip = [self indexPathForItem:item];
    NSAssert(ip, nil);
    if (self.empty) {
        self.empty = NO;
    }
    if (!self.tableView.window) {
        animation = UITableViewRowAnimationNone;
    }
    [self.tableView insertRowsAtIndexPaths:@[ ip ] withRowAnimation:animation];
    return ip;
}

- (void)setItemsWithRawData:(id)responseData {
    [super setItemsWithRawData:responseData];
    [self.tableView reloadData];
}

@end
