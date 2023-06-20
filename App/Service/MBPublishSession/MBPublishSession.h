/*
 MBPublishSession
 
 Copyright © 2018 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

#import <RFKit/RFRuntime.h>
#import "MBGeneralCallback.h"

/**
 复杂上传管理
 
 典型场景：
 - 多步骤上传，可通过 session 对象管理状态、传递信息
 - 多文件上传，支持后台静默上传
 
 内部不是线程安全的，外部必须持有 session 对象
 */
@interface MBPublishSession : NSObject

#pragma mark - 信息

/// 上传接口
@property (copy, nullable) NSString *APIName;
/// 参数
@property (copy, nullable) NSDictionary *parameters;

#pragma mark - 文件上传

#if __has_include("API+FileUpload.h")

/**
 添加需要单独上传的本地文件
 
 添加后会在后台静默上传，URL 如果是非文件地址，认为是已上传好的
 */
- (void)addFilesNeedsUpload:(nullable NSArray<NSURL *> *)files;
- (void)cancelFilesNeedsUpload:(nullable NSArray<NSURL *> *)files;

/**
 开始发布后待文件全部上传后调用，用于更新上传参数
 
 发布成功后自动置空
 */
@property (nullable) NSDictionary *__nullable (^finalizeParametersForUploadFiles)(NSDictionary<NSURL *, NSURL *> *__nonnull fileToUploadURLMap);

#endif

#pragma mark -

/// 开始发布
- (void)start;

/**
 发布结果的回调
 
 调用后自动置空
 */
@property (nullable) MBGeneralCallback publishCallback;

- (void)debug;

@end
