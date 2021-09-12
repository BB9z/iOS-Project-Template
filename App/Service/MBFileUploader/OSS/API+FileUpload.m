
#import "API+FileUpload.h"
#import "MBErrorCode.h"
#import "ShortCuts.h"
#import "OSSConfigEntity.h"
#import <RFKit/NSError+RFKit.h>
#import <RFKit/NSString+RFKit.h>

#if !__has_include(<OSSClient.h>)
#error Please import OSS SDK.
#warning CocoaPods: pod 'AliyunOSSiOS'
#else
#import <OSSClient.h>
#import <OSSModel.h>
#import <OSSTask.h>

static __weak OSSClient *_ossClient = nil;
static OSSConfigEntity *_ossConfig = nil;

/**
 通过阿里 OSS SDK 上传文件到云
 
 SDK 导入：pod 'AliyunOSSiOS'
 
 可能需要按需修改
 */
@implementation API (MBFileUpload)

- (id<MBFileUploadTask>)uploadImageWithData:(NSData *)jpegData callback:(MBGeneralCallback)callback {
    MBGeneralCallback cb = MBSafeCallback(callback);
    OSSPutObjectRequest *request = OSSPutObjectRequest.new;
    [self _doAfterOSSReady:^{
        request.uploadingData = jpegData;
        request.contentType = @"image/jpeg";
        [self _OSSUploadWithPutRequest:request callback:callback];
    } errorCallback:cb];
    return (id<MBFileUploadTask>)request;
}

- (id<MBFileUploadTask>)uploadFile:(NSURL *)fileURL callback:(MBGeneralCallback)callback {
    MBGeneralCallback cb = MBSafeCallback(callback);
    OSSPutObjectRequest *request = OSSPutObjectRequest.new;
    [self _doAfterOSSReady:^{
        NSString *mtype = [self MIMETypeFromExtension:fileURL.pathExtension];
        if (mtype) {
            request.contentType = mtype;
        }
        request.uploadingFileURL = fileURL;
        [self _OSSUploadWithPutRequest:request callback:callback];
    } errorCallback:cb];
    return (id<MBFileUploadTask>)request;
}

- (NSString *)MIMETypeFromExtension:(NSString *)ext {
    if ([ext isEqualToString:@"m4a"]) return @"audio/m4a";
    if ([ext isEqualToString:@"caf"]) return @"audio/x-caf";
    return nil;
}

#pragma mark -

- (nonnull NSString *)_objectKeyForPutRequest:(OSSPutObjectRequest *)request {
    NSString *dir = [NSString stringWithFormat:@"%lld%@", AppUserID(), NSDate.date.description].rf_MD5String;
    NSString *file = NSUUID.UUID.UUIDString;
    NSString *lastPathComponent = request.uploadingFileURL.lastPathComponent;
    if (lastPathComponent) {
        return [NSString stringWithFormat:@"user/%@/%@/%@", dir, file, lastPathComponent];
    }
    return [NSString stringWithFormat:@"user/%@/%@", dir, file];
}

- (void)_doAfterOSSReady:(dispatch_block_t)block errorCallback:(MBGeneralCallback)cb {
    if (_ossClient) {
        dout(@"OSS> upload use last client")
        block();
        return;
    }
    dout(@"OSS> Fetch config")
    [API backgroundRequestWithName:@"OSSConfig" parameters:nil completion:^(BOOL success, OSSConfigEntity *config, NSError * _Nullable error) {
        if (!success) {
            cb(NO, nil, error);
            return;
        }
        dout(@"OSS> uplodat after get config")
        _ossConfig = config;
        block();
    }];
}

- (void)_OSSUploadWithPutRequest:(OSSPutObjectRequest *)request callback:(MBGeneralCallback)callback {
    NSParameterAssert(request);
    OSSConfigEntity *config = _ossConfig;
    OSSClient *client = _ossClient;
    if (!config) {
        callback(NO, nil, [NSError errorWithDomain:API.errorDomain code:MBErrorObjectNotFound localizedDescription:@"配置异常"]);
        return;
    }
    NSString *objectKey = [self _objectKeyForPutRequest:request];
    NSURL *url = [config destinationURLWithObjectKey:objectKey];
    if (!url) {
        callback(NO, nil, [NSError errorWithDomain:API.errorDomain code:MBErrorDataInvaild localizedDescription:@"资源地址生成失败"]);
        return;
    }
    
    if (!client) {
        client = [OSSClient.alloc initWithEndpoint:config.endpoint credentialProvider:[OSSStsTokenCredentialProvider.alloc initWithAccessKeyId:config.accessKeyId secretKeyId:config.accessKeySecret securityToken:config.securityToken]];
        dout(@"OSS> Create client")
        _ossClient = client;
    }
    
    RFAssert(client, nil);
    if (!request.bucketName) {
        request.bucketName = config.bucket;
    }
    if (!request.objectKey) {
        request.objectKey = objectKey;
    }
    OSSTask *task = [client putObject:request];
    [task continueWithBlock:^id _Nullable(OSSTask * _Nonnull task) {
        dout(@"OSS> task finish")
        if (!task.error) {
            callback(YES, url, nil);
        }
        else {
            callback(NO, nil, task.error);
        }
        dispatch_after_seconds(10, ^{
            // 保持一段时间后销毁，这段时间有新的上传会重用
            __unused id _for_retain = client;
        });
        return nil;
    }];
}

@end

#endif  // END: __has_include OSS
