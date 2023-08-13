
#import "MBModel.h"

@interface JSONModel (/* Private */)
- (BOOL)__importDictionary:(NSDictionary*)dict withKeyMapper:(JSONKeyMapper*)keyMapper validation:(BOOL)validation error:(NSError**)err;
@end

@implementation MBModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    // MBModel 默认全部字段可选
    return YES;
}

- (BOOL)__importDictionary:(NSDictionary *)dict withKeyMapper:(JSONKeyMapper *)keyMapper validation:(BOOL)validation error:(NSError *__autoreleasing *)err {
    // 多线程解析 model 防崩溃
    @synchronized(self) {
        return [super __importDictionary:dict withKeyMapper:keyMapper validation:validation error:err];
    }
}

- (BOOL)mergeFromModel:(nullable MBModel *)anotherModel {
    if (!anotherModel) return YES;
    
    if (![anotherModel isMemberOfClass:[self class]]) {
        RFAssert(false, @"相同类型的模型才能merge");
        return NO;
    }
    NSMutableDictionary *base = [self toDictionary].mutableCopy;
    NSDictionary *addition = [anotherModel toDictionary];
    [addition.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        base[obj] = addition[obj];
    }];
    NSError *e;
    [self mergeFromDictionary:base useKeyMapping:YES error:&e];
    if (e) {
        return NO;
    }
    return YES;
}

+ (NSData *)dataFromModels:(NSArray<JSONModel *> *)models {
    NSArray *json = [JSONModel arrayOfDictionariesFromModels:models];
    return [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
}

@end
