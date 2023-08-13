
#import "MBGeneralCallback.h"

MBGeneralCallback _Nonnull MBSafeCallback(MBGeneralCallback _Nullable callback) {
    return ^(BOOL success, id _Nullable item, NSError *_Nullable error) {
        if (!callback) return;
        dispatch_sync_on_main(^{
            if (callback) {
                callback(success, item, error);
            }
        });
    };
}

MBGeneralCallback _Nonnull MBSafeCallbackExecutedOnDispatchQueue(MBGeneralCallback _Nullable callback, dispatch_queue_t _Nonnull queue) {
    return ^(BOOL success, id _Nullable item, NSError *_Nullable error) {
        if (!callback) return;
        dispatch_async(queue, ^{
            if (callback) {
                callback(success, item, error);
            }
        });
    };
}
