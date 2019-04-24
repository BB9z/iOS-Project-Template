/*
 API+FileUpload
 
 Copyright © 2018 RFUI.
 https://github.com/BB9z/iOS-Project-Template
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */

#import "API.h"

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
- (id<MBFileUploadTask>)uploadImageWithData:(NSData *)jpegData callback:(MBGeneralCallback)callback;

/**
 文件上传
 
 @param callback item 是上传好的 URL 地址
 */
- (id<MBFileUploadTask>)uploadFile:(NSURL *)fileURL callback:(MBGeneralCallback)callback;

@end
