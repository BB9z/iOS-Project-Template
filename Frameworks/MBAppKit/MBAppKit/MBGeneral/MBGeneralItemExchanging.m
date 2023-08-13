
#import "MBGeneralItemExchanging.h"

BOOL MBGeneralItemPassValue(id destination, id value) {
    id<MBGeneralItemExchanging> dst = destination;
    if (![dst respondsToSelector:@selector(setItem:)]) {
        return NO;
    }
    Class exceptClass = nil;
    if ([destination respondsToSelector:@selector(preferredItemClass)]) {
        exceptClass = dst.preferredItemClass;
    }
    if (exceptClass && value) {
        if (![value isKindOfClass:exceptClass]) {
            return NO;
        }
    }
    dst.item = value;
    return YES;
}
