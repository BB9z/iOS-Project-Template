/*
 MBCollectionViewColumnLayout
 
 Copyright © 2018-2020 BB9z.
 Copyright © 2014-2015 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import "MBCollectionViewFlowLayout.h"

// @MBDependency:3
/**
 按列布局，根据列数等比例调整 cell 的大小并保持 cell 的间距不变
 
 可以指定一个固定列数或一个 cell 的参考大小自动调整列数
 
 不支持通过 delegate 设置 itemSize。如果 delegate 返回了 itemSize，则列设置将失效。
 多 section 将根据第一个 section 的尺寸进行布局，不支持多 section 有不同的 itemSize。
 */
@interface MBCollectionViewColumnLayout : MBCollectionViewFlowLayout

/**
 根据宽度自适应调整列数

 开启时，外部设置的 columnCount 失效，将根据 itemSize 决定列数，能显示几列就显示几列。
 但跟原始的 UICollectionViewFlowLayout 不同之处在于会等比拉大 cell 保持最小间隙。

 默认 NO
 */
@property (nonatomic) IBInspectable BOOL autoColumnDecideOnItemMinimumWidth;

/// 列数量，默认 3
@property (nonatomic) IBInspectable NSInteger columnCount;

/**
 布局的参考 item size，这个类会修改实际 itemSize
 
 从 nib 里载入后会吧 itemSize 复制给这个属性，如果手动更新该属性需要手动调用重新布局的方法
 */
@property (nonatomic) CGSize referenceItemSize;

/**
 仅宽度自适应，保持高度
 */
@property IBInspectable BOOL onlyAdjustWidth;

@end
