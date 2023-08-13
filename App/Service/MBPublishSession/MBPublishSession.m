
#import "MBPublishSession.h"
#import "Common.h"
#import "MBErrorCode.h"
#import "ShortCuts.h"
#import <RFKit/NSError+RFKit.h>

#if __has_include("API+FileUpload.h")
#import "API+FileUpload.h"
#define _mb_has_file_upload 1
#endif

#if _mb_has_file_upload
/// 上传成功的文件缓存
static NSMutableDictionary<NSURL *, NSURL *> *_uploadCache;
/// 缓存读取
static NSURL *__nullable UploadCache(NSURL *fileURL) {
    return _uploadCache[fileURL];
}
/// 缓存写入
static void UploadCacheSet(NSURL *fileURL, NSURL *remoteURL) {
    if (!fileURL || !remoteURL) return;
    if (!_uploadCache) {
        _uploadCache = [NSMutableDictionary.alloc initWithCapacity:10];
    }
    _uploadCache[fileURL] = remoteURL;
}
#endif

@interface MBPublishSession ()
#if _mb_has_file_upload
/// key 是本地文件地址，obj 若为 NSURL 则是上传好的地址，如果是 NSNumber 代表重试剩余的次数
@property NSMutableDictionary<NSURL *, id> *filesUploadMap;
@property NSURL *_fileUploading;
@property id<MBFileUploadTask> _uploadingTask;
@property BOOL _continuePublishAfterFileUpload;
#endif
@property NSError *lastError;
/// 发布进行中标识位
@property BOOL _publishing;
@end

@implementation MBPublishSession

- (instancetype)init {
    self = super.init;
    if (self) {
        #if _mb_has_file_upload
        _filesUploadMap = [NSMutableDictionary.alloc initWithCapacity:10];
        #endif
    }
    return self;
}

#pragma mark -

#if _mb_has_file_upload
- (void)addFilesNeedsUpload:(NSArray<NSURL *> *)files {
    [files enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.filesUploadMap[obj]) return;
        if (!obj.isFileURL) {
            // 非文件 URL 认为已经是最终地址了
            self.filesUploadMap[obj] = obj;
        }
        else {
            self.filesUploadMap[obj] = UploadCache(obj) ?: @(2);
        }
    }];
    [self _uploadFileIfNeeded];
}

- (void)cancelFilesNeedsUpload:(NSArray<NSURL *> *)files {
    if ([files containsObject:self._fileUploading]) {
        self._fileUploading = nil;
        [self._uploadingTask cancel];
    }
    [files enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.filesUploadMap[obj]) {
            @synchronized (self.filesUploadMap) {
                [self.filesUploadMap removeObjectForKey:obj];
            }
        }
    }];
}

- (void)_uploadFileIfNeeded {
    if (self._fileUploading) return;
    [self.filesUploadMap enumerateKeysAndObjectsUsingBlock:^(NSURL * _Nonnull fileURL, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:NSNumber.class]) return;
        NSNumber *count = obj;
        if (count.intValue > 0) {
            [self _uploadFile:fileURL];
            *stop = YES;
        }
    }];
}

- (void)_uploadFile:(NSURL *)fileURL {
    NSParameterAssert(fileURL);
    self._fileUploading = fileURL;
    @weakify(self);
    self._uploadingTask = [Current.api uploadFile:fileURL callback:^(BOOL success, NSURL *item, NSError * _Nullable error) {
        @strongify(self);
        // 如果此时不在可能被取消了
        NSNumber *count = self.filesUploadMap[fileURL];
        if (count) {
            if (success) {
                // 只要成功 url 一定有
                self.filesUploadMap[fileURL] = item;
                UploadCacheSet(fileURL, item);
            }
            else {
                dout_error(@"后台上传 %@ 出错 %@", fileURL, error);
                self.filesUploadMap[fileURL] = @(count.intValue - 1);
                if (self._publishing) {
                    // 没正式开始，后台上传错误静默
                    self.lastError = error;
                }
            }
        }
        [self _onFileUpload];
    }];
}

- (void)_onFileUpload {
    self._fileUploading = nil;
    [self _uploadFileIfNeeded];
    
    if (self._continuePublishAfterFileUpload) {
        if (self._fileUploading) return;
        [self _doPublish];
    }
}
#endif

#pragma mark -

- (void)start {
    if (self._publishing) return;
    self._publishing = YES;
    [Current.hud showActivityIndicatorWithIdentifier:@"loading" groupIdentifier:@"MBPublishSession" model:YES message:@""];
    #if _mb_has_file_upload
    // 已经上传失败的再来最后一次
    [self.filesUploadMap enumerateKeysAndObjectsUsingBlock:^(NSURL * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:NSNumber.class]) return;
        NSNumber *count = obj;
        if (count.intValue == 0) {
            self.filesUploadMap[key] = @(1);
        }
    }];
    
    [self _uploadFileIfNeeded];
    if (self._fileUploading) {
        self._continuePublishAfterFileUpload = YES;
        return;
    }
    #endif
    [self _doPublish];
}

- (void)_doPublish {
    #if _mb_has_file_upload
    // 确保文件均已成功上传
    for (id obj in self.filesUploadMap.objectEnumerator) {
        if (![obj isKindOfClass:NSURL.class]) {
            MBGeneralCallback cb = self.publishCallback;
            if (cb) {
                cb(NO, nil, self.lastError);
                self.publishCallback = nil;
            }
            self._publishing = NO;
            [Current.hud hideWithGroupIdentifier:@"MBPublishSession"];
            return;
        }
    }
    #endif
    
    NSDictionary *p = self.parameters;
    #if _mb_has_file_upload
    if (self.finalizeParametersForUploadFiles) {
        p = self.finalizeParametersForUploadFiles(self.filesUploadMap.copy);
    }
    #endif

    [API requestName:self.APIName context:^(RFAPIRequestConext *c) {
        c.parameters = p;
        c.loadMessageShownModal = YES;
#if _mb_has_file_upload
        c.success = ^(id<RFAPITask>  _Nonnull task, id  _Nullable responseObject) {
            self.finalizeParametersForUploadFiles = nil;
        };
#endif
        c.finished = ^(id<RFAPITask>  _Nullable task, BOOL success) {
            MBGeneralCallback cb = self.publishCallback;
            if (cb) {
                cb(success, task.responseObject, task.error);
                self.publishCallback = nil;
            }
            self._publishing = NO;
            [Current.hud hideWithGroupIdentifier:@"MBPublishSession"];
        };
    }];
}

- (void)debug {
}

@end
