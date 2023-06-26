
#import "MBTabController.h"
#import "Common.h"
#import "MBListDataSource.h"
#import "MBTableListDisplayer.h"

@interface MBTabController () <
    MBControlGroupDelegate
>
@property (nonatomic) NSString *pageAPIGroupIdentifier;
@end

@implementation MBTabController

- (void)onInit {
    [super onInit];
    self.delegate = self;
}

- (void)dealloc {
    self.pageAPIGroupIdentifier = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.tabControl.delegate) {
        self.tabControl.delegate = self;
    }
    self.pageViewController.APIGroupIdentifier = self.APIGroupIdentifier;
}

- (BOOL)controlGroup:(MBControlGroup *)controlGroup shouldSelectControlAtIndex:(NSInteger)index {
    if (self.isTransitioning) return NO;
    return YES;
}

- (BOOL)pageEventManual {
    return YES;
}

- (BOOL)manageAPIGroupIdentifierManually {
    return YES;
}

- (void)setPageAPIGroupIdentifier:(NSString *)pageAPIGroupIdentifier {
    if ([_pageAPIGroupIdentifier isEqualToString:pageAPIGroupIdentifier]) return;
    if (_pageAPIGroupIdentifier) {
        [API.global cancelOperationsWithGroupIdentifier:_pageAPIGroupIdentifier];
    }
    _pageAPIGroupIdentifier = pageAPIGroupIdentifier;
}

#pragma mark - 代码切换

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    UIViewController *vc = [self viewControllerAtIndex:newSelectedIndex];
    [self willSelectViewController:vc atIndex:newSelectedIndex animated:animated];

    @weakify(self);
    [super setSelectedIndex:newSelectedIndex animated:animated completion:^(BOOL finished) {
        @strongify(self);
        [self didSelectViewController:vc atIndex:newSelectedIndex animated:animated];
        self.isTapTabControlSwichPage = NO;
        if (completion) {
            completion(finished);
        }
    }];
    [self updatesForSelectedViewControllerChanged:vc animated:animated];
    if (self.tabControl.selectIndex != newSelectedIndex) {
        self.tabControl.selectIndex = newSelectedIndex;
    }
}

#pragma mark - Tab 切换

- (IBAction)onTabChanged:(MBTabControl *)sender {
    self.isTapTabControlSwichPage = YES;
    NSUInteger index = sender.selectIndex;
    @weakify(self);
    [self setSelectedIndex:index animated:YES completion:^(BOOL finished) {
        @strongify(self);
        self.isTapTabControlSwichPage = NO;
    }];
}

#pragma mark - 滑动切换

- (void)RFTabController:(RFTabController *)tabController willSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index {
    self.isTapTabControlSwichPage = NO;
    [self willSelectViewController:viewController atIndex:index animated:YES];
}
- (void)RFTabController:(RFTabController *)tabController didSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index {
    self.tabControl.selectIndex = index;
    [self didSelectViewController:viewController atIndex:index animated:YES];
    [self updatesForSelectedViewControllerChanged:viewController animated:YES];
}

#pragma mark - 统一切换响应

- (void)willSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index animated:(BOOL)animated {
    _doutwork()
}

- (void)didSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index animated:(BOOL)animated {
    _doutwork()
}

- (void)updatesForSelectedViewControllerChanged:(__kindof UIViewController *)selectedViewController animated:(BOOL)animated {
    _douto(selectedViewController)
    [self.viewControllers enumerateObjectsUsingBlock:^(id<MBGeneralListDisplaying> dc, NSUInteger idx, BOOL *stop) {
        UIScrollView *sv = ([dc respondsToSelector:@selector(listView)])? [dc listView] : nil;
        sv.scrollsToTop = NO;
        
        if (dc == selectedViewController) {
            sv.scrollsToTop = YES;
            if (![dc respondsToSelector:@selector(dataSource)]) return;
            
            MBListDataSource *ds = [(MBTableListDisplayer *)dc dataSource];
            if (![ds respondsToSelector:@selector(hasSuccessFetched)]) return;
            if (!ds.hasSuccessFetched) {
                [dc refresh];
            }
        }
    }];
    self.pageAPIGroupIdentifier = selectedViewController.APIGroupIdentifier;
    if (self.shouldSetNavigationBarButtonItemsToSelectedViewController) {
        [self.navigationItem setLeftBarButtonItems:selectedViewController.navigationItem.leftBarButtonItems animated:animated];
        [self.navigationItem setRightBarButtonItems:selectedViewController.navigationItem.rightBarButtonItems animated:animated];
    }
}

- (void)updateListWhenSelectedIndexChanged {
    [self updatesForSelectedViewControllerChanged:self.selectedViewController animated:NO];
}

#pragma mark - MBGeneralListDisplaying

- (UITableView *)listView {
    if ([self.selectedViewController respondsToSelector:@selector(listView)]) {
        return [(id<MBGeneralListDisplaying>)self.selectedViewController listView];
    }
    return nil;
}

- (void)refresh {
    if ([self.selectedViewController respondsToSelector:@selector(refresh)]) {
        [(id<MBGeneralListDisplaying>)self.selectedViewController refresh];
    }
}

@end
