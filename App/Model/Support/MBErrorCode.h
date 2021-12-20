

#pragma once

#import <RFKit/NSError+RFKit.h>

/**
 定义应用共享错误码

 20000-30000
 
 一共五位数，用途如下
 
 |     1    |     2    |     3    |     4    |       5      |
 | App 空间 | 错误大类 | 错误大类 | 何种错误 | 错误处理区分 |

 @warning 定好的数字不应随意调整
 */
typedef NS_ENUM(NSInteger, MBErrorCode) {

    //-- 数据错误 (1XXX)
    /// 数据格式错误，无法处理，需要扔掉
    MBErrorDataInvalid                  = 21010,

    /// 数据不支持，提示新版本
    MBErrorDataNotSupport               = 21020,

    /// 因数据来源问题，数据不可用
    MBErrorDataNotAvailable             = 21100,
    
    /// 对象找不到
    MBErrorObjectNotFound               = 21400,

    //-- 操作错误 (2XXX)
    /// 重复操作，提示用户稍候再试
    MBErrorOperationRepeat              = 22010,

    /// 操作取消
    MBErrorOperationCanceled            = 22020,
    
    /// 操作超时
    MBErrorOperationTimeout             = 22023,

    /// 网络原因操作失败
    MBErrorOperationNetworkFail         = 22100,
    
    /// 操作未完成
    MBErrorOperationUnfinished          = 22400,

    //-- 特性错误 (3xxx)
    /// 特性不可用，因为需要更高系统版本
    MBErrorOSRequiredHigher             = 23110,

    /// 特性不可用，因为设备特性缺失
    MBErrorLackDeviceCapability         = 23210,

    //-- 权限错误 (4xxx)
    /// 权限被禁用
    MBErrorAuthorizationDenied          = 24100,

    /// 未授权
    MBErrorAuthorizationNotDetermined   = 24200,

    //-- 文件错误 (5xxx)
    /// 无效的路径
    MBErrorPathInvalid                  = 25010,

    /// 文件不存在
    MBErrorFileNotExist                 = 25300,

    //-- 其他错误 (8xxx)
    /// 时钟错误
    MBErrorClockIncorrect               = 28100,

    //-- 意外的错误 (9xxx)
    /// 未知错误
    MBErrorUnknow                       = 29000,

    /// 未捕获的代码异常
    MBErrorUncaughtException            = 29100,
};
