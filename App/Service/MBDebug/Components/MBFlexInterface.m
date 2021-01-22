
#import "MBFlexInterface.h"

@implementation MBFlexInterface

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

+ (void)showFlexExplorer {
    Class flex = NSClassFromString(@"FLEXManager");
    if (!flex) {
        NSLog(@"FLEX 未加载");
        return;
    }
    SEL selManager = NSSelectorFromString(@"sharedManager");
    SEL selShow = NSSelectorFromString(@"showExplorer");
    [[flex performSelector:selManager] performSelector:selShow];
}

+ (UIViewController *)explorerViewControllerForObject:(id)object {
    Class clsFactory = NSClassFromString(@"FLEXObjectExplorerFactory");
    if (!clsFactory) return nil;
    SEL sel = NSSelectorFromString(@"explorerViewControllerForObject:");
    return [clsFactory performSelector:sel withObject:object];
}

+ (UIViewController *)databaseViewControllerWithPath:(NSString *)path {
    Class clsController = NSClassFromString(@"FLEXTableListViewController");
    if (!clsController) return nil;
    SEL sel = NSSelectorFromString(@"initWithPath:");
    return [[clsController alloc] performSelector:sel withObject:path];
}

#pragma clang diagnostic pop

@end
