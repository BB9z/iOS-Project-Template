
#import "debug.h"

void DebugLog(BOOL fatal, NSString *_Nullable recordID, NSString *_Nonnull format, ...) {
    va_list args;
    va_start(args, format);
    NSLogv(format, args);
    va_end(args);

    if (fatal) {
        @try {
            @throw [NSException exceptionWithName:@"pause" reason:nil userInfo:nil];
        }
        @catch (NSException *exception) { }
    }
}

void DebugLogSwift(BOOL fatal, NSString *_Nullable recordID, NSString *__nonnull message) {
    DebugLog(fatal, recordID, @"%@", message);
}

BOOL RFAssertKindOfClass(id obj, Class aClass) {
    if (obj
        && ![obj isKindOfClass:aClass]) {
        RFAssert(false, @"Expected kind of %@, actual is %@", aClass, [obj class]);
        return NO;
    }
    return YES;
}

BOOL RFAssertIsMainThread() {
    if (![NSThread isMainThread]) {
        RFAssert(false, @"thread mismatch");
        return NO;
    }
    return YES;
}

BOOL RFAssertNotMainThread() {
    if ([NSThread isMainThread]) {
        RFAssert(false, @"thread mismatch");
        return NO;
    }
    return YES;
}

#import <mach/mach.h>

unsigned long long MBApplicationMemoryUsed(void) {
    struct mach_task_basic_info info;
    mach_msg_type_number_t size = MACH_TASK_BASIC_INFO_COUNT;
    task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &size);
    return info.resident_size;
}

unsigned long long MBApplicationMemoryAll(void) {
    return [NSProcessInfo processInfo].physicalMemory;
}
