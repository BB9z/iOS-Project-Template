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
