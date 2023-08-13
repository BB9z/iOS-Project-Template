
#import "MBEntitiesTableView.h"
#import "MBGeneralItemExchanging.h"
#import "MBGeneralCellResponding.h"

@implementation MBEntitiesTableView
RFInitializingRootForUIView

- (void)onInit {
    self.dataSource = self;
    if (!self.delegate) {
        self.delegate = self;
    }
}

- (void)afterInit {
    // Nothing
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell<MBGeneralItemExchanging> *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (self.cellConfigBlock) {
        self.cellConfigBlock(cell, self.items[indexPath.item]);
    }
    else {
        cell.item = self.items[indexPath.item];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(onCellSelected)]) {
        [(id<MBGeneralCellResponding>)cell onCellSelected];
    }
}

- (void)setItems:(NSArray *)items {
    if (_items != items) {
        _items = items;
        [self reloadData];
    }
}

- (void)appendItem:(id)item {
    if (!item) return;
    if (![_items isKindOfClass:NSMutableArray.class]) {
        _items = [NSMutableArray.alloc initWithArray:_items];
    }
    [(NSMutableArray *)_items addObject:item];
    [self insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:_items.count - 1 inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)removeItem:(id)item {
    if (!item) return;
    NSInteger idx = [self.items indexOfObject:item];
    if (idx == NSNotFound) return;
    if (![_items isKindOfClass:NSMutableArray.class]) {
        _items = [NSMutableArray.alloc initWithArray:_items];
    }
    [(NSMutableArray *)_items removeObjectAtIndex:idx];
    [self deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForItem:idx inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
