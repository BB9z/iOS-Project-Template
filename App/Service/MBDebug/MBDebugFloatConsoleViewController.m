
#import "Common.h"
#import "MBFlexInterface.h"
#import "MBDebugHelpers.h"
#import "MBDebugViews.h"
#import "UIKit+App.h"
#import "debug.h"
#import <MBAppKit/MBRootViewController.h>
#import <RFAlpha/RFWindow.h>
#if __has_include("SDWebImage.h")
#import <SDWebImage/SDWebImage.h>
#endif

static unsigned long long LastMemoryUsed;


@interface MBDebugFloatConsoleViewController ()
@property (nonatomic) NSArray<UIBarButtonItem *> *buildInCommands;
@property (nonatomic) NSArray<UIBarButtonItem *> *contextCommands;
@end


@implementation MBDebugFloatConsoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UINavigationController *nav = (UINavigationController *)AppNavigationController();
    UIViewController *topVC = nav.visibleViewController;
    self.buildInCommands = ({
        NSMutableArray *m = [NSMutableArray arrayWithCapacity:10];

        id item = AppCurrentViewControllerItem(nil);
        if (item) {
            [m addObject:({
                NSString *itemDes = [NSString stringWithFormat:@"页面对象: %@", DebugItemDescription(item)];
                DebugMenuItem(itemDes, self, @selector(showCurrentPageItem));
            })];
        }
        [m addObject:({
            long double ud = MBApplicationMemoryUsed();
            long double changed = ud - LastMemoryUsed;
            NSString *itemDes = [NSString stringWithFormat:@"内存: %.2LfM/%.1LfM\n变化: %.2LfK", ud / 1024. / 1024.f, ((long double)MBApplicationMemoryAll()) / 1024. / 1024.f, changed / 1024.f];
            LastMemoryUsed = ud;
            DebugMenuItem(itemDes, nil, nil);
        })];

        id debugItem = self.buildListInspectorMenuItem;
        if (debugItem) {
            [m addObject:debugItem];
            [m addObject:DebugMenuItem(@"Item cell 重载", self, @selector(reloadItemCells))];
        }
        if ([topVC respondsToSelector:@selector(refresh)]) {
            [m addObject:DebugMenuItem(@"刷新列表", self, @selector(delayRefreshTopViewController))];
        }
        [m addObject:DebugMenuItem(@"跳转链接", self, @selector(openURL))];
        [m addObject:DebugMenuItem(@"重置网络存储", self, @selector(resetURLStorage))];
        [m addObject:DebugMenuItem(@"Crash now!", self, @selector(makeCrash))];
        m;
    });
    [self loadContextCommands];
}

- (void)loadContextCommands {
    UIViewController *vc = self.visibleViewController;
    NSMutableArray *commands = [NSMutableArray arrayWithCapacity:10];
    do {
        if ([vc respondsToSelector:@selector(debugCommands)]) {
            [commands addObjectsFromArray:[(id<MBDebugCommandItemSource>)vc debugCommands]];
        }
    } while ((vc = vc.parentViewController));
    self.contextCommands = commands;
    [self.contextList reloadData];
}

- (UIViewController *)visibleViewController {
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    UIView *currentView = [keyWindow hitTest:CGPointOfRectCenter(keyWindow.bounds) withEvent:nil];
    UIViewController *vc = currentView.viewController;
    return vc;
}

- (id)visibleListView {
    UIViewController *topVC = self.visibleViewController;
    if (![topVC respondsToSelector:@selector(listView)] && ![topVC respondsToSelector:@selector(tableView)] && ![topVC respondsToSelector:@selector(collectionView)]) {
        return nil;
    }
    
    id lv = nil;
    if ([topVC respondsToSelector:@selector(listView)]) {
        lv = [(id<MBGeneralListDisplaying>)topVC listView];
    } else if ([topVC respondsToSelector:@selector(tableView)]) {
        lv = [(UITableViewController *)topVC tableView];
    } else if ([topVC respondsToSelector:@selector(collectionView)]) {
        lv = [(UICollectionViewController *)topVC collectionView];
    }
    return lv;
}

#pragma mark - Buildin commands

- (void)showCurrentPageItem {
    id item = AppCurrentViewControllerItem(nil);
    DebugUIInspecteModel(item);
}

- (void)delayRefreshTopViewController {
    SEL refreshSel = @selector(refresh);
    UIViewController *vc = self.visibleViewController;
    if ([vc respondsToSelector:refreshSel]) {
        [vc performSelector:refreshSel withObject:nil afterDelay:1];
        return;
    }
    vc = vc.parentViewController;
    if ([vc respondsToSelector:refreshSel]) {
        [vc performSelector:refreshSel withObject:nil afterDelay:1];
        return;
    }
}

- (void)openURL {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"链接跳转测试" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"输入 URL";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.text = [NSUserDefaults.standardUserDefaults objectForKey:@"mbdebug.LastOpenURL"];
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"跳转" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *url = alert.textFields.firstObject.text;
        if (!url) return;
        [NSUserDefaults.standardUserDefaults setObject:url forKey:@"mbdebug.LastOpenURL"];
        [self _jumpURL:url];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"3s 后跳转" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *url = alert.textFields.firstObject.text;
        if (!url) return;
        [NSUserDefaults.standardUserDefaults setObject:url forKey:@"mbdebug.LastOpenURL"];
        dispatch_after_seconds(3, ^{
            [self _jumpURL:url];
        });
    }]];
    UIViewController *vp = (UIViewController *)AppRootViewController();
    UIPopoverPresentationController *ppc = alert.popoverPresentationController;
    if (ppc) {
        ppc.sourceView = vp.view;
        ppc.sourceRect = (CGRect){ CGPointOfRectCenter(vp.view.bounds), CGSizeZero };
        ppc.permittedArrowDirections = 0;
    }
    [vp presentViewController:alert animated:YES completion:nil];
}

- (void)_jumpURL:(NSString *)urlString {
    if (!urlString.length) return;
    NSURL *url = [NSURL.alloc initWithString:urlString];
    if (!url) return;
    [NavigationController jumpWithUrl:url context:nil];
}

- (void)resetURLStorage {
    [NSURLCache.sharedURLCache removeAllCachedResponses];
    NSURLCredentialStorage *aStorage = NSURLCredentialStorage.sharedCredentialStorage;
    [aStorage.allCredentials enumerateKeysAndObjectsUsingBlock:^(NSURLProtectionSpace * _Nonnull space, NSDictionary<NSString *,NSURLCredential *> * _Nonnull obj, BOOL * _Nonnull stop) {
        for (NSURLCredential *credential in obj.allValues) {
            [aStorage removeCredential:credential forProtectionSpace:space];
        }
    }];
    NSHTTPCookieStorage *cStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage;
    for (NSHTTPCookie *cookie in cStorage.cookies) {
        [cStorage deleteCookie:cookie];
    }
#if __has_include("SDWebImage.h")
    [SDImageCache.sharedImageCache clearMemory];
    [SDImageCache.sharedImageCache clearDiskOnCompletion:nil];
    [SDWebImageManager.sharedManager removeAllFailedURLs];
#endif
}

- (void)makeCrash {
    NSAssert(false, @"This is a crash for debug");
}

- (UIBarButtonItem *)buildListInspectorMenuItem {
    id lv = self.visibleListView;
    if ([lv respondsToSelector:@selector(mbdebug_showVisableItemMenu)]) {
        return DebugMenuItem(@"检查列表可视对象", lv, @selector(mbdebug_showVisableItemMenu));
    }
    else {
        return nil;
    }
}

- (void)reloadItemCells {
    id lv = self.visibleListView;
    if ([lv isKindOfClass:UITableView.class]) {
        UITableView *tb = lv;
        for (id<MBGeneralItemExchanging> cell in tb.visibleCells) {
            if (![cell respondsToSelector:@selector(item)]) continue;
            cell.item = cell.item;
        }
    }
    else if ([lv isKindOfClass:UICollectionView.class]) {
        UICollectionView *cv = lv;
        for (id<MBGeneralItemExchanging> cell in cv.visibleCells) {
            if (![cell respondsToSelector:@selector(item)]) continue;
            cell.item = cell.item;
        }
    }
}

#pragma mark - Table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.contextList) {
        return self.contextCommands.count;
    }
    return self.buildInCommands.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger idx = indexPath.row;
    UIBarButtonItem *command = (tableView == self.contextList) ? self.contextCommands[idx] : self.buildInCommands[idx];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = command.title;
    cell.textLabel.textColor = command.action ? UIColor.darkGrayColor : UIColor.lightGrayColor;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self onHide:nil];
    NSInteger idx = indexPath.row;
    UIBarButtonItem *command = (tableView == self.contextList) ? self.contextCommands[idx] : self.buildInCommands[idx];
    if (command.action) {
        [command.target performSelector:command.action withObject:nil afterDelay:0];
    }
}

@end
