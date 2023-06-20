/*
 MBTableViewController
 
 Copyright © 2018 RFUI.
 Copyright © 2015 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import "MBTableView.h"
#import "MBGeneral.h"

// @MBDependency:3
/**
 比普通 UIViewController + MBTableView 多了以下特性：

 - MBGeneralListDisplaying 协议支持
 - tableView:didSelectRowAtIndexPath: 时尝试执行 cell 的 onCellSelected 方法
 - 视图显示时取消选中单元
 - 适合 table view 的 segue 准备方法
 */
@interface MBTableViewController : UIViewController <
    MBGeneralListDisplaying
>
@property (weak, nonatomic) IBOutlet MBTableView *listView;

@end
