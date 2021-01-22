
#import "MBDebugHelpers.h"
#import "MBFlexInterface.h"
#import "ShortCuts.h"
#import <RFAlpha/RFBlockSelectorPerform.h>
#import <RFKit/NSString+RFKit.h>
@import ObjectiveC;

@implementation UITableView (MBDebugVisableItemInspecting)

- (void)mbdebug_showVisableItemMenu {
    DebugUIInspecteObjects(@"检查 cell", [self visibleCells], ^NSString *(id<MBGeneralItemExchanging> cell) {
        id item = ([cell respondsToSelector:@selector(item)]) ? [cell item] : nil;
        return [NSString stringWithFormat:@"%@(%@)", cell.class, DebugItemDescription(item)];
    }, ^(id<MBGeneralItemExchanging> cell) {
        DebugUIInspecteModel([cell item]);
    });
}

@end


@implementation UICollectionView (MBDebugVisableItemInspecting)

- (void)mbdebug_showVisableItemMenu {
    DebugUIInspecteObjects(@"检查 cell", [self visibleCells], ^NSString *(id<MBGeneralItemExchanging> cell) {
        id item = ([cell respondsToSelector:@selector(item)]) ? [cell item] : nil;
        return [NSString stringWithFormat:@"%@(%@)", cell.class, DebugItemDescription(item)];
    }, ^(id<MBGeneralItemExchanging> cell) {
        DebugUIInspecteModel([cell item]);
    });
}

@end

UIBarButtonItem *DebugMenuItem(NSString *title, id target, SEL action) {
    return [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:action];
}

UIBarButtonItem *_Nonnull DebugMenuItem2(NSString *_Nonnull title, dispatch_block_t _Nonnull actionBlock) {
    // 这里强转一下，否则 item 的 target 可能会变成空的，这可能跟编译器优化有关
    id target = actionBlock;
    UIBarButtonItem *bi = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:@selector(rf_performBlockSelector)];
    objc_setAssociatedObject(bi, __PRETTY_FUNCTION__, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return bi;
}

NSString *DebugItemDescription(id item) {
    if ([item respondsToSelector:@selector(uid)]) {
        return [NSString stringWithFormat:@"%@(%@)", [item class], [item valueForKey:@"uid"]];
    }
    return [NSString stringWithFormat:@"%@(%p)", [item class], item];
}

void DebugUIInspecteModel(NSObject *model) {
    UIViewController *vc = [MBFlexInterface explorerViewControllerForObject:model];
    if (vc) {
        [(UINavigationController *)AppNavigationController() pushViewController:vc animated:YES];
        return;
    }
    UIAlertController *as = [UIAlertController alertControllerWithTitle:model.debugDescription message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [as addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    UIViewController *vp = (UIViewController *)AppRootViewController();
    UIPopoverPresentationController *ppc = as.popoverPresentationController;
    if (ppc) {
        ppc.sourceView = vp.view;
        ppc.sourceRect = (CGRect){ CGPointOfRectCenter(vp.view.bounds), CGSizeZero };
        ppc.permittedArrowDirections = 0;
    }
    [vp presentViewController:as animated:YES completion:nil];
}

void DebugUIInspecteObjects(NSString *_Nonnull title, NSArray<id> *_Nonnull objects, NSString * (^_Nullable titleDisplay)(id _Nonnull), void (^_Nullable inspectBlock)(id _Nonnull))
{
    if (!titleDisplay) {
        titleDisplay = ^(id obj) {
            return [[obj description] stringByTrimmingToLength:40 withTruncationToken:@"..."];
        };
    }
    if (!inspectBlock) {
        inspectBlock = ^(id obj) {
            DebugUIInspecteModel(obj);
        };
    }
    UIAlertController *as = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (id obj in objects) {
        NSString *actionTitle = titleDisplay(obj);
        [as addAction:[UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            inspectBlock(obj);
        }]];
    }
    [as addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    UIViewController *vp = (UIViewController *)AppRootViewController();
    UIPopoverPresentationController *ppc = as.popoverPresentationController;
    if (ppc) {
        ppc.sourceView = vp.view;
        ppc.sourceRect = (CGRect){ CGPointOfRectCenter(vp.view.bounds), CGSizeZero };
        ppc.permittedArrowDirections = 0;
    }
    [vp presentViewController:as animated:YES completion:nil];
}
