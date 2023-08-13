/*!
 MBGeneralCellResponding
 MBAppKit

 Copyright © 2018 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <RFKit/RFRuntime.h>

@protocol MBGeneralCellResponding <NSObject>
@optional

/**
 一般在 table view cell 或 collection view cell 上实现

 delegate 在实现时先检查其返回值，如果是 YES 不继续执行 delegate 的后续逻辑
 */
- (BOOL)respondsCellSelection;

/**
 cell 点击事件
 */
- (void)onCellSelected;

@end

#if !TARGET_OS_OSX

/**
 一般响应逻辑的 table view 实现
 
 @code
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (MBGeneralCellRespondingTableViewDidSelectImplementation(tableView, indexPath)) {
        return;
    }
    // 其他自定义逻辑
 }
 @endcode

 @return 如果执行了 cell 的选择逻辑返回 YES，如果 cell 不响应，返回 NO
 */
BOOL MBGeneralCellRespondingTableViewDidSelectImplementation(UITableView *__nonnull tableView, NSIndexPath *__nonnull indexPath);

BOOL MBGeneralCellRespondingCollectionViewDidSelectImplementation(UICollectionView *__nonnull collectionView, NSIndexPath *__nonnull indexPath);

#endif
