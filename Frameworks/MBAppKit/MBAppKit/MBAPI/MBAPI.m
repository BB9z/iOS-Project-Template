
#import "MBAPI.h"
#import "MBGeneralCallback.h"
#import <RFAPI/RFAPIDefineConfigFile.h>
#import <RFMessageManager/RFMessageManager+RFDisplay.h>
#import <RFMessageManager/RFNetworkActivityMessage.h>

MBAPI *MBAPI_global_ = nil;

@interface MBAPI ()
@property (nonatomic, nonnull) NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSDate *> *> *requestIntervalRecord;
@end

@implementation MBAPI

+ (MBAPI *)global {
    @synchronized(self) {
        return MBAPI_global_;
    }
}

+ (void)setGlobal:(__kindof MBAPI *)global {
    @synchronized(self) {
        MBAPI_global_ = global;
    }
}

- (void)setupAPIDefineWithPlistPath:(NSString *)path {
    NSDictionary *rules = [[NSDictionary alloc] initWithContentsOfFile:path];
    RFAssert(rules, @"Cannot get api define rules at path: %@", path);
    [self.defineManager setDefinesWithRulesInfo:rules];
}

#pragma mark - 请求管理

+ (id<RFAPITask>)requestName:(NSString *)APIName context:(NS_NOESCAPE void (^)(RFAPIRequestConext * _Nonnull))c {
    MBAPI *instance = self.global;
    NSAssert(instance, @"⚠️ MBAPI global instance has not been set.");
    return [instance requestWithName:APIName context:c];
}

+ (id<RFAPITask>)requestWithName:(NSString *)APIName parameters:(NSDictionary *)parameters viewController:(UIViewController *)viewController loadingMessage:(NSString *)message modal:(BOOL)modal success:(RFAPIRequestSuccessCallback)success completion:(RFAPIRequestFinishedCallback)completion {
    return [self requestName:APIName context:^(RFAPIRequestConext *c) {
        c.parameters = parameters;
        c.groupIdentifier = viewController.APIGroupIdentifier;
        c.loadMessage = message;
        c.loadMessageShownModal = modal;
        c.success = success;
        c.finished = completion;
    }];
}

+ (id<RFAPITask>)requestWithName:(NSString *)APIName parameters:(NSDictionary *)parameters viewController:(UIViewController *)viewController forceLoad:(BOOL)forceLoad loadingMessage:(NSString *)message modal:(BOOL)modal success:(RFAPIRequestSuccessCallback)success failure:(RFAPIRequestFailureCallback)failure completion:(RFAPIRequestFinishedCallback)completion {
    id<RFAPITask> task = [self requestName:APIName context:^(__kindof RFAPIRequestConext *c) {
        c.parameters = parameters;
        c.loadMessage = message;
        c.loadMessageShownModal = modal;
        c.identifier = APIName;
        c.groupIdentifier = viewController.APIGroupIdentifier;
        c.success = success;
        c.failure = failure;
        c.finished = completion;
    }];
    return task;
}

+ (nullable id<RFAPITask>)requestWithName:(nonnull NSString *)APIName parameters:(nullable NSDictionary *)parameters viewController:(nullable UIViewController *)viewController loadingMessage:(nullable NSString *)message modal:(BOOL)modal completion:(nullable void (^)(BOOL success, id __nullable responseObject, NSError *__nullable error))completion {
    id<RFAPITask> task = [self requestName:APIName context:^(__kindof RFAPIRequestConext *c) {
        c.parameters = parameters;
        c.loadMessage = message;
        c.loadMessageShownModal = modal;
        c.identifier = APIName;
        c.groupIdentifier = viewController.APIGroupIdentifier;
        if (completion) {
            c.finished = ^(id<RFAPITask>  _Nullable task, BOOL success) {
                completion(success, task.responseObject, task.error);
            };
        }
    }];
    return task;
}

+ (void)backgroundRequestWithName:(NSString *)APIName parameters:(NSDictionary *)parameters completion:(void (^)(BOOL success, id responseObject, NSError *error))completion {
    [self requestName:APIName context:^(__kindof RFAPIRequestConext *c) {
        c.parameters = parameters;
        c.identifier = APIName;
        if (completion) {
            c.combinedCompletion = ^(id<RFAPITask>  _Nullable task, id  _Nullable responseObject, NSError * _Nullable error) {
                BOOL success = !error && !!responseObject;
                completion(success, responseObject, error);
            };
        }
    }];
}

+ (void)cancelOperationsWithViewController:(UIViewController *)viewController {
    if (!viewController) return;
    [self.global cancelOperationsWithGroupIdentifier:viewController.APIGroupIdentifier];
}

#pragma mark - RequestInterval

- (NSMutableDictionary *)requestIntervalRecord {
    if (!_requestIntervalRecord) {
        _requestIntervalRecord = [NSMutableDictionary.alloc initWithCapacity:4];
    }
    return _requestIntervalRecord;
}

- (NSMutableDictionary<NSString *, NSDate *> *)requestIntervalRecordForVC:(UIViewController *)vc {
    return self.requestIntervalRecord[vc.APIGroupIdentifier];
}

- (void)enableRequestIntervalForViewController:(UIViewController *)viewController APIName:(NSString *)name {
    if (!viewController || !name) return;
    NSMutableDictionary<NSString *, NSDate *> *r = [self requestIntervalRecordForVC:viewController];
    if (!r) {
        r = [NSMutableDictionary.alloc initWithCapacity:2];
        self.requestIntervalRecord[viewController.APIGroupIdentifier] = r;
    }
    if (!r[name]) {
        r[name] = NSDate.distantPast;
    }
}

- (void)setRequestIntervalForViewController:(UIViewController *)viewController APIName:(NSString *)name {
    if (!viewController || !name) return;
    doutwork()
    NSMutableDictionary<NSString *, NSDate *> *r = [self requestIntervalRecordForVC:viewController];
    if (!r || !r[name]) return;
    r[name] = NSDate.date;
}

- (BOOL)shouldRequestForViewController:(UIViewController *)viewController minimalInterval:(NSTimeInterval)interval {
    NSMutableDictionary<NSString *, NSDate *> *r = [self requestIntervalRecordForVC:viewController];
    NSDate *now = NSDate.date;
    for (NSDate *d in r.objectEnumerator) {
        if (fabs([now timeIntervalSinceDate:d]) < interval) {
            return NO;
        }
    }
    NSArray *names = r.allKeys;
    for (id<RFAPITask> op in [self operationsWithGroupIdentifier:viewController.APIGroupIdentifier]) {
        if ([names containsObject:op.identifier]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)shouldRequestForViewController:(id)viewController APIName:(NSString *)APIName minimalInterval:(NSTimeInterval)interval {
    if (!APIName) {
        return [self shouldRequestForViewController:viewController minimalInterval:interval];
    }
    NSMutableDictionary<NSString *, NSDate *> *r = [self requestIntervalRecordForVC:viewController];
    NSDate *now = NSDate.date;
    if (fabs([now timeIntervalSinceDate:r[APIName]]) < interval) {
        return NO;
    }
    return YES;
}

- (void)clearRequestIntervalForViewController:(UIViewController *)viewController {
    if (!viewController) return;
    NSMutableDictionary<NSString *, NSDate *> *r = [self requestIntervalRecordForVC:viewController];
    NSMutableDictionary<NSString *, NSDate *> *copy = r.mutableCopy;
    for (NSString *key in r) {
        copy[key] = NSDate.distantPast;
    }
    [r setDictionary:copy];
}

@end

#import <objc/runtime.h>

static char UIViewController_APIControl_CateogryProperty;

@implementation UIViewController (MBAPIControl)

- (NSString *)APIGroupIdentifier {
    id value = objc_getAssociatedObject(self, &UIViewController_APIControl_CateogryProperty);
    if (value) return value;
    return [NSString.alloc initWithFormat:@"vc:%p", (void *)self];
}

- (void)setAPIGroupIdentifier:(NSString *)APIGroupIdentifier {
    objc_setAssociatedObject(self, &UIViewController_APIControl_CateogryProperty, APIGroupIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)manageAPIGroupIdentifierManually {
    return NO;
}

@end
