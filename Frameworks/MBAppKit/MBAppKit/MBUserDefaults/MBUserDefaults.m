
#import "MBUserDefaults.h"
#import "MBGeneralSetNeedsDoSomthing.h"
#import "MBUserDefaultsMakeProperty.h"

@implementation NSUserDefaults (Sync)
MBSynthesizeSetNeedsDelayMethodUsingAssociatedObject(setNeedsSynchronized, synchronize, 0.01);

- (BOOL)synchronizeBlock:(NS_NOESCAPE void (^_Nonnull)(__kindof NSUserDefaults *_Nonnull u))block {
    if (!block) return YES;
    block(self);
    return self.synchronize;
}

@end


@implementation NSAccountDefaults

- (BOOL)synchronizeBlock:(NS_NOESCAPE void (^)(NSAccountDefaults *))block {
    return [super synchronizeBlock:block];
}

@end
