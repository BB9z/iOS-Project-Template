/*
 MBSingleSectionCollectionView
 
 Copyright © 2018 RFUI.
 Copyright © 2015-2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFKit/RFRuntime.h>
#import <RFDelegateChain/UICollectionViewDataSourceChain.h>
#import <RFDelegateChain/UICollectionViewDelegateFlowLayoutChain.h>

// @MBDependency:1
/**
 利用 RFDelegateChain 实现 dataSource 和 delegate 的灵活配置从而便于复用的 CollectionView
 
 注意：因为 collection view 会缓存代理可响应的方法，增减 dataSource / delegate 的实现方法时需要重新设置一下 dataSource / delegate 属性
 
 默认使用自带的一个数组作为数据源
 
 在 Swift 中需要用 typealias 声明一下，直接带 generic type IB 的表现会异常
 */
@interface MBSingleSectionCollectionView<ObjectType> : UICollectionView <
    RFInitializing
>

#pragma mark - 数据源访问
/**
 默认带了 UICollectionViewDataSource 必需方法的实现

 单元默认 reuse identifier 取 "Cell"，尝试 setItem: 赋值
 */
@property (weak, nonatomic) IBOutlet UICollectionViewDataSourceChain *dataSource;

@property (strong, nonatomic) NSArray<ObjectType> *items;

- (ObjectType)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForItem:(ObjectType)item;

#pragma mark - 选中对象

/**
 选中 item，提供了两个优化

 1. 直接获取当前选中单元对应位置的 item
 2. 重载数据时保持对应单元的选中状态
 */
@property (strong, nonatomic) ObjectType selectedItem;

/**
 执行 reloadData 时保持已选择单元的选中状态
 */
@property (nonatomic) IBInspectable BOOL keepItemSelectionAfterReload;


/**
 默认没有附带任何代理的实现
 */
@property (weak, nonatomic) IBOutlet UICollectionViewDelegateFlowLayoutChain *delegate;

/**
 动画刷新数据并修改相应状态
 */
- (void)updateItems;

@end
