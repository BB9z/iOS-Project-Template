/*
 API+FileUpload
 
 Copyright © 2018, 2020-2021 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

#import "Common.h"

@protocol MBFileUploadTask <NSObject>
/// 取消请求
- (void)cancel;
@end

/**
 提供文件上传接口
 */
@interface API (MBFileUpload)

/**
 上传 JPEG 图像数据
 
 @param callback item 是上传好的 URL 地址
 */
- (nullable id<MBFileUploadTask>)uploadImageWithData:(nonnull NSData *)jpegData callback:(nonnull MBGeneralCallback)callback;

/**
 文件上传
 
 @param callback item 是上传好的 URL 地址
 */
- (nullable id<MBFileUploadTask>)uploadFile:(nonnull NSURL *)fileURL callback:(nonnull MBGeneralCallback)callback;

@end

