
#import "MBTableListDisplayer.h"
#import "Common.h"
#import "MBGeneralCellResponding.h"

@interface MBTableListDisplayer ()
@end

@implementation MBTableListDisplayer
RFInitializingRootForUIViewController
@dynamic tableView;

- (void)onInit {
}

- (void)afterInit {
}

- (void)dealloc {
    if (self.viewLoaded) {
        self.tableView.delegate = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    MBTableViewDataSource *ds = self.tableView.dataSource;
    self.dataSource = ds;
    if (self.APIName) {
        ds.fetchAPIName = self.APIName;
    }
    if (ds) {
        [self setupDataSource:ds];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.clearsSelectionOnViewWillAppear) {
        for (NSIndexPath *row in self.tableView.indexPathsForSelectedRows) {
            [self.tableView deselectRowAtIndexPath:row animated:animated];
        }
    }
}

- (void)setupDataSource:(MBTableViewDataSource *)ds {
}

- (void)setAPIName:(NSString *)APIName {
    _APIName = APIName;
    self.dataSource.fetchAPIName = APIName;
}

- (NSString *)apiGroupIdentifier {
    return self.parentViewController.apiGroupIdentifier;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (MBGeneralCellRespondingTableViewDidSelectImplementation(tableView, indexPath)) {
        return;
    }
}

#pragma mark - MBGeneralListDisplaying

- (id)listView {
    return self.tableView;
}

- (void)refresh {
    [self.tableView.pullToFetchController triggerHeaderProcess];
}

@end


@implementation MBTableListController

- (void)viewDidLoad {
    [super viewDidLoad];

    MBTableListDisplayer *dc = self.childViewControllers.lastObject;
    NSAssert([dc isKindOfClass:MBTableListDisplayer.class], @"Cannot get correct list displayer.");
    self.listDisplayer = dc;

    if (self.APIName) {
        dc.dataSource.fetchAPIName = self.APIName;
    }
    NSString *ci = self.cellIdentifier;
    if (ci) {
        [dc.dataSource setCellReuseIdentifier:^NSString *(UITableView *tb, NSIndexPath *ip, id item) {
            return ci;
        }];
    }

    [self setupDataSource:dc.dataSource];
    if (!self.disableAutoRefreshAfterViewLoadded) {
        [dc refresh];
    }
}

- (void)setupDataSource:(MBTableViewDataSource *)ds {
}

- (MBTableViewDataSource *)dataSource {
    return self.listDisplayer.dataSource;
}

#pragma mark - MBGeneralListDisplaying

- (UITableView *)listView {
    return self.listDisplayer.listView;
}

- (void)refresh {
    [self.listDisplayer refresh];
}

@end
