/*
 MBSearchViewController
 
 Copyright © 2018 RFUI.
 Copyright © 2014-2015, 2017 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <MBAppKit/MBAppKit.h>
#import "MBSearchTextField.h"

// @MBDependency:2
/**
 通用沉浸式搜索界面
 
 用来替代 UISearchDisplayController
 */
@interface MBSearchViewController : UIViewController <
    UISearchBarDelegate
>
@property (nonatomic, weak) IBOutlet MBSearchTextField *searchTextField;
@property (nonatomic, weak) IBOutlet UIView *container;
@property IBInspectable BOOL focusSearchBarWhenAppear;

/**
 键盘消隐时会自动设置 constant 为键盘在 container 视图中的高度
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint  *keyboardAdjustLayoutConstraint;

/**
 供取消按钮绑定
 
 默认会做以下事情：
 
 - 清空已键入的文本，收起键盘；
 - 如果 MBSearchTextField 正在搜索，且 APIName 已设置，会尝试结束对应的请求并标记搜索停止；
 - 调用时如果有键盘焦点且已输入文本，则不会自动退出页面，否则会导航退出页面。
 
 */
- (IBAction)onCancel:(id)sender;

@end


