
#import <UIKit/UIKit.h>

/**
 当应用包含 FLEX 时 https://github.com/FLEXTool/FLEX ，以下方法可用
 */
@interface MBFlexInterface : NSObject

/// 显示 FLEX 浮窗
+ (void)showFlexExplorer;

/// 创建查看 object 的 vc
+ (nullable UIViewController *)explorerViewControllerForObject:(nullable id)object;

/// 创建用于浏览数据库文件的 vc，注意只有特定文件后缀才支持，详见 FLEXTableListViewController 的实现
+ (nullable UIViewController *)databaseViewControllerWithPath:(nullable NSString *)path;

@end
