//
//  ShortCuts
//  App
//
#import <MBAppKit/MBModel.h>

/**
 快速访问一些全局对象

 用函数而不是直接暴露全局变量，为了便于根据情况处理返回值，
 为日后解决模块间初始化依赖做铺垫，还利于调试（设置断点、打 log 都方便）
 
 函数替换为原始表达式也比变量替换更稳定
 
 缺点是补全有时候不好用，方括号的补全位置不对，剩下没有了吧
 
 关于命名
 ----
 所有快捷访问函数均以 App 开头

 */

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 应用配置/环境

@class NavigationController;
/// 全局导航
FOUNDATION_EXPORT NavigationController *__nullable AppNavigationController(void);

/**
 尝试获取当前视图上的 item

 @param exceptClass 可选，非空将检查 item 类型，只在符合时才返回
 @return 当前视图上的 item，会尝试遍历一层子 vc
 */
FOUNDATION_EXPORT id __nullable AppCurrentViewControllerItem(Class __nullable exceptClass);

//@class MBWorkerQueue;
/// 全局 worker 队列
//FOUNDATION_EXPORT MBWorkerQueue *AppWorkerQueue(void);

/// 后台 worker 队列，注意后台的意思是 perform 是在后台线程执行的
//FOUNDATION_EXPORT MBWorkerQueue *AppBackgroundWorkerQueue(void);

@class MessageManager;
FOUNDATION_EXPORT MessageManager *__nonnull AppHUD(void);

#pragma mark - 用户信息

@class Account;
/// 当前登录的用户，可以用来判断是否已登录
FOUNDATION_EXPORT Account *__nullable AppUser(void);

/// 当前用户的 ID
#if MBUserStringUID
FOUNDATION_EXPORT MBIdentifier __nullable AppUserID(void);
#else
FOUNDATION_EXPORT MBID AppUserID(void);

/// 总是非空
FOUNDATION_EXPORT NSNumber *AppUserIDNumber(void);
#endif

NS_ASSUME_NONNULL_END
