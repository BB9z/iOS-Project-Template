/*!
 MBCollectionListDisplayer

 Copyright © 2020 RFUI.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

#import "MBCollectionView.h"
#import "MBGeneralListDisplaying.h"

// @MBDependency:2
/**
专用于嵌在其他界面的列表

把显示、跳转可以封装在这里
处理了嵌套 vc 取消请求的问题
*/
@interface MBCollectionListDisplayer : UIViewController <
    RFInitializing,
    MBGeneralListDisplaying
>

@property (weak, nullable, nonatomic) IBOutlet MBCollectionView *collectionView;

@property (nullable, nonatomic) IBInspectable NSString *APIName;

@property (weak, nullable, nonatomic) MBCollectionViewDataSource *dataSource;

/// 默认不做什么
- (void)setupDataSource:(nonnull MBCollectionViewDataSource *)ds;

@end
