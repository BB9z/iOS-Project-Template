
#import "MBListDataSource.h"
#import <RFAlpha/RFCallbackControl.h>
#import <RFKit/NSArray+RFKit.h>
#import <MBAppKit/MBAppKit.h>
#import <MBAppKit/MBAPI.h>
#import "MBListDateItem.h"

@interface MBListDataSourceFetchCompletionCallback : RFCallback
@end

@interface MBListDataSource ()
@property BOOL fetching;
@property (weak, nonatomic) id<RFAPITask> fetchOperation;
@property (nonatomic) RFCallbackControl<MBListDataSourceFetchCompletionCallback *> *fetchCompletionCallbacks;
@end

@implementation MBListDataSource

- (void)onInit {
    [super onInit];
    self.pageStartZero = self.class.defualtPageStartZero;
    self.page = self.pageStartZero ? - 1 : 0;
    self.pageSize = 10;
    self.items = [NSMutableArray.alloc initWithCapacity:40];
    self.pageEndDetectPolicy = MBDataSourcePageEndDetectPolicyStrict;
}

- (void)prepareForReuse {
    [self.items removeAllObjects];
    self.empty = NO;
    self.page = self.pageStartZero ? - 1 : 0;
    self.maxID = nil;
    self.pageEnd = NO;
    self.fetching = NO;
    self.hasSuccessFetched = NO;
    self.fetchOperation = nil;
    self.lastFetchError = nil;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSectionEnabled) {
        return [(MBListSectionDataItem *)self.items[indexPath.section] rows][indexPath.row];
    }
    return [self.items rf_objectAtIndex:indexPath.row];
}

- (nullable NSIndexPath *)indexPathForItem:(nullable id)item {
    if (self.isSectionEnabled) {
        __block NSIndexPath *indexPath = nil;
        [self.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger section, BOOL * _Nonnull stop) {
            NSInteger idx = [[(MBListSectionDataItem *)obj rows] indexOfObject:item];
            if (idx != NSNotFound) {
                indexPath = [NSIndexPath indexPathForRow:idx inSection:section];
                *stop = YES;
            }
        }];
        return indexPath;
    }
    NSInteger idx = [self.items indexOfObject:item];
    if (idx != NSNotFound) {
        return [NSIndexPath indexPathForRow:idx inSection:0];
    }
    return nil;
}

- (nonnull NSArray *)itemsForindexPaths:(nonnull NSArray *)indexPaths {
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *ip in indexPaths) {
        [items rf_addObject:[self itemAtIndexPath:ip]];
    }
    return items;
}

- (void)fetchItemsFromViewController:(nullable UIViewController *)viewController nextPage:(BOOL)nextPage success:(void (^)(__kindof MBListDataSource *dateSource, NSArray *fetchedItems))success completion:(void (^)(__kindof MBListDataSource *dateSource))completion {
    if (self.fetching) return;
    if (!self.fetchAPIName) {
        NSLog(@"❌ Datasource 的 fetchAPIName 未设置");
        return;
    }
    self.fetching = YES;

    // Reload from top, reset properties.
    if (!nextPage) {
        self.pageEnd = NO;
        self.maxID = nil;
    }

    self.page = nextPage? self.page + 1 : (self.pageStartZero ? 0 : 1);
    BOOL pagingEnabled = !self.pagingDisabled;
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithDictionary:self.fetchParameters];
    if (pagingEnabled) {
        if (self.pageStyle == MBDataSourceMAXIDPageStyle) {
            if (nextPage) {
                id item = self.items.lastObject;
                RFAssert(self.maxIDKeypath, @"MAX_ID keypath 未设置");
                self.maxID = [item valueForKey:self.maxIDKeypath];
                if (self.maxID) {
                    parameter[self.maxIDParameterName] = self.maxID;
                }
            }
        }
        else {
            parameter[self.pageParameterName] = @(self.page);
        }
        parameter[self.pageSizeParameterName] = @(self.pageSize);
    }
    
    self.fetchOperation = [MBAPI requestName:self.fetchAPIName context:^(RFAPIRequestConext *c) {
        c.parameters = parameter;
        c.groupIdentifier = viewController.APIGroupIdentifier;
        if (self.requestContextModify) {
            self.requestContextModify(c);
        }
        if (c.success || c.failure || c.finished) {
            NSLog(@"⚠️ 通过 requestContextModify 设置的回调会被忽略");
        }
        @weakify(self);
        c.success = ^(id<RFAPITask>  _Nonnull task, id  _Nullable responseObject) {
            @strongify(self);
            if (!self) return;
            if (task != self.fetchOperation) return;

            NSMutableArray *items = self.items;
            NSArray *responseArray = nil;
            if (self.processItems) {
                responseArray = self.processItems(nextPage? items.copy : nil, responseObject);
            }
            else if ([responseObject isKindOfClass:NSArray.class]) {
                responseArray = responseObject;
            }

            if (!nextPage) {
                [items removeAllObjects];
            }
            [self _MBListDataSource_handleResponseArray:responseArray items:items];
            if (!pagingEnabled) {
                self.pageEnd = YES;
            }
            if (success) {
                success(self, responseArray);
            }
            self.hasSuccessFetched = YES;
        };
        c.failure = ^(id<RFAPITask>  _Nullable task, NSError * _Nonnull error) {
            @strongify(self);
            if (!self) return;
            if (task != self.fetchOperation) return;

            // 请求失败的话分页应该减回去
            self.page--;
            self.lastFetchError = error;
            BOOL (^cb)(MBListDataSource *, NSError *) = self.class.defaultFetchFailureHandler;
            if (cb && cb(self, error)) {
                return;
            }
        };
        c.finished = ^(id<RFAPITask>  _Nullable task, BOOL success) {
            @strongify(self);
            if (!self) return;
            if (task != self.fetchOperation) return;

            self.fetching = NO;
            if (completion) {
                completion(self);
            }
            [self.fetchCompletionCallbacks performWithSource:self filter:nil];
        };
    }];
}

- (void)cancelFetching {
    self.fetchOperation = nil;
    self.fetching = NO;
}

- (void)setItemsWithRawData:(id)responseData {
    self.fetching = NO;
    self.fetchOperation = nil;
    self.page = 0;
    self.maxID = nil;
    
    NSMutableArray *items = self.items;
    [items removeAllObjects];
    NSArray *responseArray = nil;
    if (self.processItems) {
        responseArray = self.processItems(nil, responseData);
    }
    else if ([responseData isKindOfClass:NSArray.class]) {
        responseArray = responseData;
    }
    
    [self _MBListDataSource_handleResponseArray:responseArray items:items];
    self.pageEnd = YES;
    self.hasSuccessFetched = YES;
    self.lastFetchError = nil;
}

- (void)_MBListDataSource_handleResponseArray:(NSArray *)responseArray items:(NSMutableArray *)items {
    [responseArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        // Swift array may contains nil
        if (!obj) return;
        
        // Ignored
        if ([obj respondsToSelector:@selector(ignored)]) {
            if ([(id<MBModel>)obj ignored]) {
                return;
            }
        }
        
        // 不重复，直接加
        NSInteger existsIdx = [items indexOfObject:obj];
        if (existsIdx == NSNotFound) {
            [items addObject:obj];
            return;
        }
        
        // 处理重复
        switch (self.distinctRule) {
            case MBDataSourceDistinctRuleIgnore:
                break;
            case MBDataSourceDistinctRuleUpdate:
                items[existsIdx] = obj;
                break;
            case MBDataSourceDistinctRuleReplace:
                [items removeObjectAtIndex:existsIdx];
                [items addObject:obj];
                break;
            case MBDataSourceDistinctRuleDefault:
            default:
                [items addObject:obj];
                break;
        }
    }];
    
    self.empty = (items.count == 0 && responseArray.count == 0);
    if (self.pageEndDetectPolicy == MBDataSourcePageEndDetectPolicyEmpty) {
        self.pageEnd = (responseArray.count == 0);
    }
    else {
        self.pageEnd = (responseArray.count < self.pageSize);
    }
}

#pragma mark -

- (void)setFetchOperation:(id<RFAPITask>)fetchOperation {
    if (_fetchOperation == fetchOperation) return;
    if (_fetchOperation) {
        [_fetchOperation cancel];
        self.lastFetchError = nil;
    }
    _fetchOperation = fetchOperation;
}

static BOOL _globalPageStartZero = NO;
+ (BOOL)defualtPageStartZero {
    return _globalPageStartZero;
}
+ (void)setDefualtPageStartZero:(BOOL)pageStartZero {
    _globalPageStartZero = pageStartZero;
}

- (NSString *)pageParameterName {
    if (!_pageParameterName) {
        _pageParameterName = self.class.defaultPageParameterName ?: @"page";
    }
    return _pageParameterName;
}
- (NSString *)pageSizeParameterName {
    if (!_pageSizeParameterName) {
        _pageSizeParameterName = self.class.defaultPageSizeParameterName ?: @"page_size";
    }
    return _pageSizeParameterName;
}
- (NSString *)maxIDParameterName {
    if (!_maxIDParameterName) {
        _maxIDParameterName = self.class.defaultMaxIDParameterName ?: @"MAX_ID";
    }
    return _maxIDParameterName;
}

static NSString *_globalPageParameterName = nil;
+ (NSString *)defaultPageParameterName {
    return _globalPageParameterName;
}
+ (void)setDefaultPageParameterName:(NSString *)defaultPageParameterName {
    _globalPageParameterName = defaultPageParameterName;
}
static NSString *_globalPageSizeParameterName = nil;
+ (NSString *)defaultPageSizeParameterName {
    return _globalPageSizeParameterName;
}
+ (void)setDefaultPageSizeParameterName:(NSString *)defaultPageSizeParameterName {
    _globalPageSizeParameterName = defaultPageSizeParameterName;
}
static NSString *_globalMaxIDParameterName = nil;
+ (NSString *)defaultMaxIDParameterName {
    return _globalMaxIDParameterName;
}
+ (void)setDefaultMaxIDParameterName:(NSString *)defaultMaxIDParameterName {
    _globalMaxIDParameterName = defaultMaxIDParameterName;
}

#pragma mark -

static id _defaultFetchFailureHandler = nil;
+ (BOOL (^)(MBListDataSource * _Nonnull, NSError * _Nonnull))defaultFetchFailureHandler {
    return _defaultFetchFailureHandler;
}
+ (void)setDefaultFetchFailureHandler:(BOOL (^)(MBListDataSource * _Nonnull, NSError * _Nonnull))defaultFetchFailureHandler {
    _defaultFetchFailureHandler = defaultFetchFailureHandler;
}

- (RFCallbackControl *)fetchCompletionCallbacks {
    if (_fetchCompletionCallbacks) return _fetchCompletionCallbacks;
    RFCallbackControl *c = RFCallbackControl.new;
    c.objectClass = MBListDataSourceFetchCompletionCallback.class;
    _fetchCompletionCallbacks = c;
    return _fetchCompletionCallbacks;
}

- (void)addFetchCompletionCallback:(void (^)(__kindof MBListDataSource * _Nonnull, NSError * _Nullable))callback refrenceObject:(id)object {
    [self.fetchCompletionCallbacks addCallback:callback refrenceObject:object];
}

- (void)removeFetchCompletionCallbacksOnRefrenceObject:(id)object {
    [self.fetchCompletionCallbacks removeCallbackOfRefrenceObject:object];
}

@end

@implementation MBListDataSourceFetchCompletionCallback

- (void)perfromBlock:(nonnull id)block source:(MBListDataSource *)source {
    void (^cb)(__kindof MBListDataSource *__nonnull ds, NSError *__nullable error) = block;
    cb(source, source.lastFetchError);
}

@end
