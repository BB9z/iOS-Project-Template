
#import "MBDebugMenuViewController.h"

@implementation MBDebugMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (IBAction)onRestartAppTapped:(id)sender {
    [NSUserDefaults.standardUserDefaults synchronize];
    exit(EXIT_SUCCESS);
}

@end
