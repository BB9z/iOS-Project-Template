/*
 MBKeyboardAdjustScrollView

 Copyright © 2020, 2022 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

#import <RFKit/RFRuntime.h>

// @MBDependency:2
/**
 帮助简化键盘处理的 UIScrollView 类
 A UIScrollView subclass to simplify keyboard handling

 它可以自动帮助你：

 - 根据键盘高度调整 content inset，保证键盘出现时所有内容滚动可见（底部不会被键盘遮住）
 - 如果获取焦点的输入框在 scroll view 中（无论层级），尝试以最好的效果（考虑选中范围，视图大小）调整可视区域

 It automatically helps you:

 - Adjust content inset according to keyboard height to make all content scrolling visible.
 - If any view in this scroll view becomes the first responder. It will try to adjust the scroll position to make it visible with the best effect (considering the selection range, view size)
 */
@interface MBKeyboardAdjustScrollView : UIScrollView
@end
