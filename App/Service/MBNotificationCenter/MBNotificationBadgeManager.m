
#import "MBNotificationBadgeManager.h"
#import <RFTimer.h>
#import "MBUser.h"

RFDefineConstString(MBNotificatioBadgeChangedNotification);

@interface MBNotificationBadgeManager ()
@property RFTimer *_MBNotificationBadgeManager_pollingTimer;
@end

static MBNotificationBadgeManager *_badge_sharedInstance;

@implementation MBNotificationBadgeManager
RFInitializingRootForNSObject;

+ (instancetype)defaultManager {
    @synchronized(self) {
        if (!_badge_sharedInstance) {
            _badge_sharedInstance = [self.alloc init];
        }
        return _badge_sharedInstance;
    }
}

+ (void)setDefaultManager:(__kindof MBNotificationBadgeManager *)defaultManager {
    @synchronized(self) {
        _badge_sharedInstance = defaultManager;
    }
}

- (void)onInit {
    self.requiresUser = YES;
}

- (void)afterInit {
    if (self.requiresUser) {
        @weakify(self);
        [MBUser addCurrentUserChangeObserver:self initial:YES callback:^(MBUser *_Nullable currentUser) {
            @strongify(self);
            self.pollingEnabled = !!currentUser;
            if (!currentUser) {
                [self _MBNotificationBadgeManager_postStatusChanged];
                dispatch_after_seconds(0, ^{
                    // 退出销毁
                    [self.class setDefaultManager:nil];
                });
            }
        }];
    }
}

- (void)setPollingEnabled:(BOOL)pollingEnabled {
    _pollingEnabled = pollingEnabled;

    // 禁用简单暂停
    if (!pollingEnabled) {
        self._MBNotificationBadgeManager_pollingTimer.suspended = YES;
        return;
    }

    if (!self._MBNotificationBadgeManager_pollingTimer) {
        @weakify(self);
        NSTimeInterval timeInterval = 10;
        NSTimeInterval setInterval = self.pollingInterval;
        if (setInterval > 0) {
            if (setInterval < 5) {
                NSLog(@"⚠️ pollingInterval 设置过小，建议十秒以上");
            }
            timeInterval = setInterval;
        }
        self._MBNotificationBadgeManager_pollingTimer = [RFTimer scheduledTimerWithTimeInterval:timeInterval repeats:YES fireBlock:^(RFTimer *timer, NSUInteger repeatCount) {
            @strongify(self);
            [self statusPolling];
        }];
        self._MBNotificationBadgeManager_pollingTimer.tolerance = timeInterval * 0.4;
    }
    self._MBNotificationBadgeManager_pollingTimer.suspended = NO;
    [self._MBNotificationBadgeManager_pollingTimer fire];
}

- (void)statusPolling {
    // for overwrite
}

MBSynthesizeSetNeedsMethodUsingAssociatedObject(setNeedsPostStatusChangedNotification, _MBNotificationBadgeManager_postStatusChanged, 0.1)

- (void)_MBNotificationBadgeManager_postStatusChanged {
    [NSNotificationCenter.defaultCenter postNotificationName:MBNotificatioBadgeChangedNotification object:self userInfo:nil];
}

@end
