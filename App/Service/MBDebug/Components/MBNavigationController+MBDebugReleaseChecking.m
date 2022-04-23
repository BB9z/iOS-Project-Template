
#if RFDEBUG
#import "MBNavigationController+MBDebugReleaseChecking.h"
#import <RFAlpha/RFSwizzle.h>
#import <MBAppKit/MBAppKit.h>
#import "debug.h"

@implementation MBNavigationController (MBDebugReleaseChecking)

+ (void)load {
    RFSwizzleInstanceMethod(MBNavigationController.class, @selector(didRemoveViewControllers:), @selector(_MBDebug_didRemoveViewControllers:));
}

- (void)_MBDebug_didRemoveViewControllers:(nonnull NSArray<UIViewController *> *)vcs {
    [self _MBDebug_didRemoveViewControllers:vcs];
#if DEBUG
    [self debugCheckReleaseWithViewControllers:vcs];
#endif
}

- (void)debugCheckReleaseWithViewControllers:(nonnull NSArray<UIViewController *> *)vcs {
    NSHashTable *hashTable = [NSHashTable weakObjectsHashTable];
    for (UIViewController<MBGeneralListDisplaying> *vc in vcs) {
        if ([self respondsToSelector:@selector(debugShouldIgnoralCheckReleaseForViewController:)]) {
            if ([(id<MBDebugNavigationReleaseChecking>)self debugShouldIgnoralCheckReleaseForViewController:vc]) {
                continue;
            }
        }

        [hashTable addObject:vc];
        for (id cvc in vc.childViewControllers) {
            [hashTable addObject:cvc];
        }
        if (!vc.isViewLoaded) continue;
        [hashTable addObject:vc.view];
        
        if (![vc respondsToSelector:@selector(listView)]) continue;
        id lv = vc.listView;
        [hashTable addObject:lv];
        
        if (![lv respondsToSelector:@selector(visibleCells)]) continue;
        for (UIView *cell in [(UITableView *)lv visibleCells]) {
            [hashTable addObject:cell];
        }
    }
    
    dispatch_block_t checkBlock = ^{
        NSArray *liveObjects = hashTable.allObjects;
        if ([liveObjects containsObject:self.topViewController]) {
            // 导航操作取消了
            return;
        }
        if (liveObjects.count) {
            NSMutableString *leakInfo = [NSMutableString new];
            for (id obj in liveObjects) {
                [leakInfo appendFormat:@"\n%@", [obj class]];
            }
            dout_warning(@"可能的泄漏对象:\n%@", liveObjects);
            DebugLog(YES, @"NavigationDetectLeak", @"侦测到可能的内存泄漏，泄漏对象\n%@", leakInfo);
        }
    };
    
    id<UIViewControllerTransitionCoordinator> tcontext = self.transitionCoordinator;
    if (!tcontext) {
        dispatch_after_seconds(1, checkBlock);
    }
    else if (tcontext.isInteractive) {
        [tcontext notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            dispatch_after_seconds(1, checkBlock);
        }];
    }
    else {
        dispatch_after_seconds(tcontext.transitionDuration + 1, checkBlock);
    }
    return;
}

@end

#endif
