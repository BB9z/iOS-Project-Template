/*!
 MBCollectionViewCarouselLayout
 
 Copyright © 2018 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */

#import "MBCollectionViewFlowLayout.h"

/**
 像 iCarousel 线性的效果
 
 内部做了什么：
 - 通过调整 sectionInset，使列表头尾可以自然对齐中心
 - 处理滚动的终止位置，以使 cell 始终对齐中心
 
 */
@interface MBCollectionViewCarouselLayout : MBCollectionViewFlowLayout

/**
 非空时代表的是 cell 与 collection view 边缘的距离，此时 itemSize 会根据 collection view 的大小做调整
 */
@property (nonatomic) IBInspectable CGFloat fixedCellPadding;

@end
