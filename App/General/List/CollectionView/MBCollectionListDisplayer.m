
#import "MBCollectionListDisplayer.h"
#import "Common.h"
#import <MBAppKit/MBGeneralCellResponding.h>

@interface MBCollectionListDisplayer ()

@end

@implementation MBCollectionListDisplayer
RFInitializingRootForUIViewController

- (void)onInit {
}

- (void)afterInit {
}

- (void)dealloc {
    if (self.viewLoaded) {
        self.collectionView.delegate = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    MBCollectionViewDataSource *ds = self.collectionView.dataSource;
    NSAssert([self.collectionView isKindOfClass:MBCollectionView.class], @"");
    self.dataSource = ds;
    if (self.APIName) {
        ds.fetchAPIName = self.APIName;
    }
    [self setupDataSource:ds];
}

- (void)setupDataSource:(MBCollectionViewDataSource *)ds {
}

- (void)setAPIName:(NSString *)APIName {
    _APIName = APIName;
    self.dataSource.fetchAPIName = APIName;
}

- (NSString *)APIGroupIdentifier {
    return self.parentViewController.APIGroupIdentifier;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (MBGeneralCellRespondingCollectionViewDidSelectImplementation(collectionView, indexPath)) {
        return;
    }
}

#pragma mark - MBGeneralListDisplaying

- (id)listView {
    return self.collectionView;
}

- (void)refresh {
    [self.collectionView fetchItemsNextPage:NO success:nil completion:nil];
}

@end
