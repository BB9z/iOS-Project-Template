/*!
 MBUserDefaultsMakeProperty
 MBAppKit
 
 Copyright © 2018 RFUI.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 
 在 MBUserDefaults 中生成存储属性
 
 NSUserDefaults 原生支持的类型，可以用 _makeXXXProperty 实现属性，属性声明应用 (nullable, copy) 修饰。
 _makeCachedModelProperty 和 _makeCachedModelArrayProperty 用于生成 JSONModel 对象，默认会缓存结果，需要用 (nonatomic, nullable, strong) 修饰。
 
 @warning _makeCachedModelProperty 和 _makeCachedModelArrayProperty 生成的结果不是 copy 的，意味着如果你修改 model，其他地方访问到的结果也会跟着变。但是 NSUserDefaults 的存储不会变
 
 自己写的 selector 其属性声明要看具体是如何实现的，NSUserDefaults 是线程安全的，如果实现中有非原子操作则需要标明是 nonatomic 的，nullability 正常看实现标。
 */

// 默认的 NSUserDefaults 会自动同步，而我们建的不会自动同步
#define ClassSynchronize \
    if ([self isMemberOfClass:NSAccountDefaults.class]) {\
        [self setNeedsSynchronized];\
    }

#define _makeString(...) @#__VA_ARGS__
#define _makeKey(NAME) _makeString(_ ## NAME)

#define _makeBoolProperty(NAME, SETTER) \
    @dynamic NAME;\
    - (BOOL)NAME {\
        return [self boolForKey:_makeKey(NAME)];\
    }\
    - (void)SETTER:(BOOL)NAME {\
        [self setBool:NAME forKey:_makeKey(NAME)];\
        ClassSynchronize\
    }

#define _makeIntegerProperty(NAME, SETTER) \
    @dynamic NAME;\
    - (NSInteger)NAME {\
        return [self integerForKey:_makeKey(NAME)];\
    }\
    - (void)SETTER:(NSInteger)NAME {\
        [self setInteger:NAME forKey:_makeKey(NAME)];\
        ClassSynchronize\
    }

#define _makeObjectProperty(NAME, SETTER) \
    @dynamic NAME;\
    - (id)NAME {\
        return [self objectForKey:_makeKey(NAME)];\
    }\
    - (void)SETTER:(id)NAME {\
        [self setObject:NAME forKey:_makeKey(NAME)];\
        ClassSynchronize\
    }

#define _makeURLProperty(NAME, SETTER) \
    @dynamic NAME;\
    - (id)NAME {\
        return [self URLForKey:_makeKey(NAME)];\
    }\
    - (void)SETTER:(id)NAME {\
        [self setURL:NAME forKey:_makeKey(NAME)];\
        ClassSynchronize\
    }

#define _makeModelProperty(NAME, SETTER, MODEL_CLASS) \
    @dynamic NAME;\
    - (MODEL_CLASS *)NAME {\
        NSData *json = [self dataForKey:_makeKey(NAME)];\
        if (json) {\
            return [[MODEL_CLASS alloc] initWithData:json error:nil];\
        }\
        return nil;\
    }\
    - (void)SETTER:(MODEL_CLASS *)NAME {\
        NSData *json = [NAME toJSONData];\
        [self setObject:json forKey:_makeKey(NAME)];\
        ClassSynchronize\
    }

#define _makeCachedModelProperty(NAME, IVAR, SETTER, MODEL_CLASS) \
    @synthesize NAME = IVAR;\
    - (MODEL_CLASS *)NAME {\
        if (IVAR) return IVAR;\
        NSData *json = [self dataForKey:_makeKey(NAME)];\
        if (json) {\
            IVAR = [[MODEL_CLASS alloc] initWithData:json error:nil];\
        }\
        return IVAR;\
    }\
    - (void)SETTER:(MODEL_CLASS *)NAME {\
        IVAR = NAME;\
        NSData *json = [NAME toJSONData];\
        [self setObject:json forKey:_makeKey(NAME)];\
        ClassSynchronize\
    }

#define _makeModelArrayProperty(NAME, SETTER, MODEL_CLASS) \
    @dynamic NAME;\
    - (NSArray<MODEL_CLASS *> *)NAME {\
        NSArray *json = [self objectForKey:_makeKey(NAME)];\
        return [MODEL_CLASS arrayOfModelsFromDictionaries:json error:nil];\
    }\
    - (void)SETTER:(NSArray<MODEL_CLASS *> *)NAME {\
        NSArray *json = [MODEL_CLASS arrayOfDictionariesFromModels:NAME];\
        [self setObject:json forKey:_makeKey(NAME)];\
        ClassSynchronize\
    }

#define _makeCachedModelArrayProperty(NAME, IVAR, SETTER, MODEL_CLASS) \
    @synthesize NAME = IVAR;\
    - (NSArray<MODEL_CLASS *> *)NAME {\
        if (IVAR) return IVAR;\
        NSArray *json = [self objectForKey:_makeKey(NAME)];\
        IVAR = [MODEL_CLASS arrayOfModelsFromDictionaries:json error:nil];\
        return IVAR;\
    }\
    - (void)SETTER:(NSArray<MODEL_CLASS *> *)NAME {\
        IVAR = NAME;\
        NSArray *json = [MODEL_CLASS arrayOfDictionariesFromModels:NAME];\
        [self setObject:json forKey:_makeKey(NAME)];\
        ClassSynchronize\
    }
