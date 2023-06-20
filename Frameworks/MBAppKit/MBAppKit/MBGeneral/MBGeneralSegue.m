
#import "MBGeneralSegue.h"
#import "MBGeneralItemExchanging.h"
#import "MBGeneralListExchanging.h"
#import <RFKit/UIResponder+RFKit.h>

id _Nullable MBGeneralSegueItem(UIStoryboardSegue *_Nonnull segue, id _Nullable sender, Class _Nullable cellClass, id _Nullable viewController) {
    id item;
    if ([sender respondsToSelector:@selector(item)]) {
        item = [(id<MBGeneralItemExchanging>)sender item];
    }
    else if (cellClass) {
        if ([cellClass respondsToSelector:@selector(itemFromSender:)]) {
            item = [cellClass itemFromSender:sender];
        }
    }

    if (!item) {
        if ([viewController respondsToSelector:@selector(item)]) {
            item = [(id<MBGeneralItemExchanging>)viewController item];
        }
    }
    return item;
}

#import <RFAlpha/RFSwizzle.h>

@implementation UIViewController (MBGeneralSegue)

+ (void)load {
    RFSwizzleInstanceMethod(UIViewController.class, @selector(prepareForSegue:sender:), @selector(RFPrepareForSegue:sender:));
}

- (void)RFPrepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
#if TARGET_OS_OSX
    id dvc = segue.destinationController;
#else
    __kindof UIViewController *dvc = segue.destinationViewController;
#endif
    if ([dvc respondsToSelector:@selector(setItem:)]) {
        UIViewController<MBGeneralItemExchanging> *vc = dvc;
        if ([self respondsToSelector:@selector(itemForSegue:sender:)]) {
            vc.item = [(id<MBGeneralSegue>)self itemForSegue:segue sender:sender];
            return;
        }
        if ([sender respondsToSelector:@selector(item)]) {
            vc.item = [(id<MBGeneralItemExchanging>)sender item];
            return;
        }
        UIView *v = sender;
        if ([v respondsToSelector:@selector(viewController)]
            && v.viewController == self) {
            while ((v = v.superview)) {
                if ([v respondsToSelector:@selector(item)]) {
                    vc.item = [(id<MBGeneralItemExchanging>)v item];
                    return;
                }
                if (v == self.view) break;
            }
        }
        if ([self respondsToSelector:@selector(item)]) {
            vc.item = [(id<MBGeneralItemExchanging>)self item];
            return;
        }
    }
    else if ([dvc respondsToSelector:@selector(setItems:)]) {
        UIViewController<MBGeneralListItemExchanging> *vc = dvc;
        if ([sender respondsToSelector:@selector(items)]) {
            vc.items = [(id<MBGeneralListItemExchanging>)sender items];
            return;
        }
        UIView *v = sender;
        if ([v respondsToSelector:@selector(viewController)]
            && v.viewController == self) {
            while ((v = v.superview)) {
                if ([v respondsToSelector:@selector(items)]) {
                    vc.items = [(id<MBGeneralListItemExchanging>)v items];
                    return;
                }
                if (v == self.view) break;
            }
        }
        if ([self respondsToSelector:@selector(items)]) {
            vc.items = [(id<MBGeneralListItemExchanging>)self items];
            return;
        }
    }
}

@end
