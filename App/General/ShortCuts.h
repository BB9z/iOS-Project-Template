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

/// 编译环境，Debug、Alpha、Release
FOUNDATION_EXPORT NSString *AppBuildConfiguration(void);

@class MBEnvironment;
/// 状态依赖
FOUNDATION_EXPORT MBEnvironment *AppEnv(void);

@class ApplicationDelegate;
/// 快速访问 application delegate 实例
FOUNDATION_EXPORT ApplicationDelegate *__nonnull AppDelegate(void);

@class RootViewController;
/// 全局根视图
FOUNDATION_EXPORT RootViewController *_Nullable AppRootViewController(void);

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

@class API;
/// 应用接口
FOUNDATION_EXPORT API *AppAPI(void);

//@class BadgeManager;
/// 全局红点管理器
//FOUNDATION_EXPORT BadgeManager *__nonnull AppBadge(void);

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

@class AccountEntity;
FOUNDATION_EXPORT AccountEntity *_Nullable AppUserInformation(void);

#pragma mark - 存储

/// 应用级别的配置项
FOUNDATION_EXPORT NSUserDefaults *AppUserDefaultsShared(void);

@class NSAccountDefaults;
/// 当前用户的配置项
FOUNDATION_EXPORT NSAccountDefaults *_Nullable AppUserDefaultsPrivate(void);

#pragma mark - 特殊标记

/// 应用已进入前台，但不包括应用启动和前后台切换过程中
FOUNDATION_EXPORT BOOL AppActive(void);

/// 应用处于后台
FOUNDATION_EXPORT BOOL AppInBackground(void);

NS_ASSUME_NONNULL_END
