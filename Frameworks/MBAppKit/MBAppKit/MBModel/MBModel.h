/*!
 MBModel
 MBAppKit
 
 Copyright © 2018 RFUI.
 Copyright © 2015-2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/RFUI/MBAppKit

 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 
 JSONModel 封装，线程安全，工具等
 */
#import <RFKit/RFRuntime.h>
#import <JSONModel/JSONModel.h>
#import "MBGeneralType.h"

#pragma mark - MBModel

/**
 默认属性全部可选
 */
@interface MBModel : JSONModel

/// 用另一个模型更新当前模型（另一个模型的空字段不作为新数据）
- (BOOL)mergeFromModel:(nullable __kindof JSONModel *)anotherModel;

+ (nullable NSData *)dataFromModels:(nonnull NSArray<JSONModel *> *)models;

@end

/**
 @define MBModelIgnoreProperties
 
 生成定义忽略规则
 
 如果属性已经用 <Ignore> 标记了，可以不定义在这里
 */
#define MBModelIgnoreProperties(CLASS, ...) \
    + (BOOL)propertyIsIgnored:(NSString *)propertyName {\
        static NSArray *map;\
        if (!map) {\
            CLASS *this;\
            map = @[\
                    metamacro_foreach_cxt(_mbmodel_makeArray, , , __VA_ARGS__)\
                    ];\
        }\
        if ([map containsObject:propertyName]) {\
            return YES;\
        }\
        return [super propertyIsIgnored:propertyName];\
    }

#define _mbmodel_makeArray(INDEX, CONTEXT, VAR) \
    @keypath(this, VAR),


/**
 @define MBModelKeyMapper
 
 支持对父类KeyMapper的继承
 */
#define MBModelKeyMapper(CLASS, ...)\
    + (JSONKeyMapper *)keyMapper {\
        CLASS *this;\
        JSONKeyMapper *sm = [super keyMapper];\
        if (sm) {\
            return [JSONKeyMapper baseMapper:sm withModelToJSONExceptions:[NSDictionary dictionaryWithObjectsAndKeys:__VA_ARGS__, nil]];\
        }\
        else {\
            return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:[NSDictionary dictionaryWithObjectsAndKeys:__VA_ARGS__, nil]];\
        }\
    }

/**
 @define MBModelKeyMpperForSnakeCase

 默认将下划线命名转化为驼峰命名
 不支持对父类KeyMapper的继承
 */
#define MBModelKeyMpperForSnakeCase(CLASS, ...)\
    + (JSONKeyMapper *)keyMapper {\
        CLASS *this;\
        return [JSONKeyMapper baseMapper:[JSONKeyMapper mapperForSnakeCase] withModelToJSONExceptions:[NSDictionary dictionaryWithObjectsAndKeys:__VA_ARGS__, nil]];\
}

#pragma mark 忽略

@protocol MBModel <NSObject>

/// 标记这个对象在处理时应该被忽略
- (BOOL)ignored;
@end

#pragma mark - 完备性

/**
 完备性支持
 */
@protocol MBModelCompleteness <NSObject>
@required
/// 信息不完整标记，需要获取详情
@property (nullable, nonatomic) NSNumber<Ignore> *incompletion;

@optional

/// 从缓存补全模型的可选方法
- (nullable id)completeEntityFromCache;

@end

typedef NS_ENUM(int, MBModelSyncFlag) {
    MBModelSyncFlagNormal   = 0,
    MBModelSyncFlagFinished = -1,
    MBModelSyncFlagDeleted  = -2,
    MBModelSyncFlagInvalid  = -3,
};

#pragma mark - 更新通知

/**
 UI 更新支持
 */
@protocol MBModelUpdating <NSObject>
@optional

@property (readonly, nonnull, nonatomic) NSHashTable<Ignore> *displayers;

- (void)addDisplayer:(nullable id)displayer;
- (void)removeDisplayer:(nullable id)displayer;

@end

/**
 displayers 生成方法
 */
#define MBModelUpdatingImplementation \
    - (NSHashTable *)displayers {\
        if (!_displayers) {\
            _displayers = [NSHashTable weakObjectsHashTable];\
        }\
        return _displayers;\
    }\
    - (void)addDisplayer:(id)displayer {\
        [self.displayers addObject:displayer];\
    }\
    - (void)removeDisplayer:(id)displayer {\
        [self.displayers removeObject:displayer];\
    }

/**
 通知生成方法
 */
#define MBModelStatusUpdatingMethod(METHODNAME, PROTOCOL, PROTOCOL_SELECTOR) \
    - (void)METHODNAME {\
        NSArray *all = [self.displayers allObjects];\
        for (id<PROTOCOL> displayer in all) {\
            if ([displayer respondsToSelector:@selector(PROTOCOL_SELECTOR:)]) {\
                [displayer PROTOCOL_SELECTOR:self];\
            }\
        }\
    }

#pragma mark - UID

/**

 */
@protocol MBModelUID <NSObject>
@property (nonatomic) MBID uid;
@end

/**
 是否相同

 uid 整形
 */
#define MBModelUIDEqual \
    - (BOOL)isEqual:(id)other {\
        if (other == self) return YES;\
        if (![other isMemberOfClass:self.class]) return NO;\
        return (self.uid == [(id<MBModelUID>)other uid]);\
    }\
    - (NSUInteger)hash {\
        return self.uid;\
    }

/**
 是否相同

 uid 是 NSObject
 */
#define MBModelUIDObjectEqual \
    - (BOOL)isEqual:(id)other {\
        if (other == self) return YES;\
        if (![other isMemberOfClass:[self class]]) return NO;\
        __typeof(&*self) obj = other;\
        return [self.uid isEqual:obj.uid];\
    }\
    - (NSUInteger)hash {\
        return self.uid.hash;\
    }


#pragma mark - 其他

/**
 前置引用语法糖
 
 @code
 @importModel(aModelClass)
 @endcode
 */
#define importModel(KIND)\
class KIND; @protocol KIND;

#define PropertyProtocol(PROPERTY)\
    @protocol PROPERTY <NSObject>\
    @end
