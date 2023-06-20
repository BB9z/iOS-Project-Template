
#import "MBUser.h"
#import <RFKit/NSArray+RFKit.h>

@interface MBUserCurrentUserChangeObserver : NSObject
@property (weak) id observer;
@property MBUserCurrentUserChangeCallback callback;
@property MBIdentifier callbackUID;
@end

@implementation MBUserCurrentUserChangeObserver
@end

#pragma mark -

static MBUser *MBUserCurrentLogined;

@interface MBUser ()
@property MBIdentifier uid;
@property (readonly) NSMutableArray<MBUserCurrentUserChangeObserver *> *_MBUser_changeObservers;
@end

@implementation MBUser

#pragma mark - Current

+ (instancetype)currentUser {
    return MBUserCurrentLogined;
}

- (BOOL)isCurrent {
    return (self.class.currentUser == self);
}

+ (void)setCurrentUser:(nullable __kindof MBUser *)user {
    dispatch_sync_on_main(^{
        if (MBUserCurrentLogined == user) return;
        
        if (MBUserCurrentLogined) {
            [MBUserCurrentLogined onLogout];
        }
        RFAssert(![MBUserCurrentLogined.uid isEqualToString: user.uid], @"不支持重复设置 ID 相同的用户，可以简化当前用户的判断（直接使用 ==）");
        MBUserCurrentLogined = user;
        if (user) {
            [MBUserCurrentLogined onLogin];
        }
        [self onCurrentUserChanged:user];
        dispatch_after_seconds(0, ^{
            if (MBUserCurrentLogined != user) return;
            [self _MBUser_noticeUserChanged];
        });
    });
}

+ (void)_MBUser_noticeUserChanged {
    MBUser *user = self.currentUser;
    BOOL needsClean = NO;
    for (MBUserCurrentUserChangeObserver *obj in self._MBUser_changeObservers) {
        if (obj.observer
            && obj.callback) {
            if (![obj.callbackUID isEqualToString: user.uid]) {
                obj.callbackUID = user.uid;
                obj.callback(user);
            }
        }
        else {
            needsClean = YES;
        }
    }
    if (needsClean) {
        [self._MBUser_changeObservers removeObjectsPassingTest:^BOOL(MBUserCurrentUserChangeObserver *obj, NSUInteger idx, BOOL *stop) {
            return (!obj.observer || !obj.callback);
        }];
    }
}

+ (NSMutableArray *)_MBUser_changeObservers {
    @synchronized(self) {
        static NSMutableArray *table = nil;
        if (!table) {
            table = [NSMutableArray array];
        }
        return table;
    }
}

+ (void)addCurrentUserChangeObserver:(nonnull __weak id)observer initial:(BOOL)initial callback:(nonnull MBUserCurrentUserChangeCallback)callback {
    if (!observer || !callback) return;

    MBUserCurrentUserChangeObserver *obj = [MBUserCurrentUserChangeObserver new];
    obj.callbackUID = nil;
    obj.observer = observer;
    obj.callback = callback;
    if (initial) {
        MBUser *currentUser = self.currentUser;
        if (callback) {
            obj.callbackUID = currentUser.uid;
            callback(currentUser);
        }
    }
    [self._MBUser_changeObservers addObject:obj];
}

+ (void)removeCurrentUserChangeObserver:(nullable id)observer {
    [self._MBUser_changeObservers removeObjectsPassingTest:^BOOL(MBUserCurrentUserChangeObserver *obj, NSUInteger idx, BOOL *stop) {
        id objObserver = obj.observer;
        return (objObserver == observer || !objObserver || !obj.callback);
    }];
}

#pragma mark - init

- (nullable instancetype)initWithID:(MBIdentifier)uid {
    if (!uid.length) {
        return nil;
    }
    self = [super init];
    if (self) {
        _uid = uid;
        [self onInit];
        [self performSelector:@selector(afterInit) withObject:self afterDelay:0];
    }
    return self;
}

- (void)onInit {
}

- (void)afterInit {
}

#pragma mark - For overwrite

+ (void)onCurrentUserChanged:(__kindof MBUser *__nullable)currentUser {
    // for overwrite
}

- (void)onLogin {
    // for overwrite
}

- (void)onLogout {
    // for overwrite
}

@end
