
#import "MBGeneralCellResponding.h"

#if !TARGET_OS_OSX
BOOL MBGeneralCellRespondingTableViewDidSelectImplementation(UITableView *__nonnull tableView, NSIndexPath *__nonnull indexPath) {
    UITableViewCell<MBGeneralCellResponding> *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (![cell respondsToSelector:@selector(respondsCellSelection)]) {
        return NO;
    }
    if (cell.respondsCellSelection) {
        [cell onCellSelected];
        return YES;
    }
    return NO;
}

BOOL MBGeneralCellRespondingCollectionViewDidSelectImplementation(UICollectionView *__nonnull collectionView, NSIndexPath *__nonnull indexPath) {
    UICollectionViewCell<MBGeneralCellResponding> *cell = (__kindof UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (![cell respondsToSelector:@selector(respondsCellSelection)]) {
        return NO;
    }
    if (cell.respondsCellSelection) {
        [cell onCellSelected];
        return YES;
    }
    return NO;
}
#endif
