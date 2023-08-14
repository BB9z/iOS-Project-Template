
#import "UIImage+MBImageSet.h"

@implementation UIImage (MBImageSet)

+ (nullable UIImage *)imageWithSetName:(nonnull NSString *)set identifier:(nonnull id)identifier {
    NSParameterAssert(set);
    NSParameterAssert(identifier);
    NSAssert([set hasPrefix:@"zs_"], @"集合名请加 zs 前缀");

    NSString *IDString = nil;
    if ([identifier isKindOfClass:[NSString class]]) {
        IDString = identifier;
    }
    else if ([identifier isKindOfClass:[NSNumber class]]) {
        IDString = [NSString stringWithFormat:@"%ld", [identifier longValue]];
    }
    else {
        NSAssert(false, @"imageWithSetName:identifier: 标识只能是 string 或 number");
        return nil;
    }

    NSString *fullName = [NSString stringWithFormat:@"%@_%@", set, IDString];
    UIImage *image = [UIImage imageNamed:fullName];
    if (!image) {
        NSLog(@"找不到名为 %@ 的图片", fullName);
    }
    return image;
}

@end
