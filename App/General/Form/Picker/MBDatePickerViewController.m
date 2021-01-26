
#import "MBDatePickerViewController.h"

@interface MBDatePickerViewController ()
@end

@implementation MBDatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.datePickerConfiguration) {
        self.datePickerConfiguration(self.datePicker);
        self.datePickerConfiguration = nil;
    }
}

#pragma mark -

- (IBAction)onSave:(id)sender {
    if (self.didEndSelection) {
        self.didEndSelection(self.datePicker, NO);
        self.didEndSelection = nil;
    }
    [self dismissAnimated:YES completion:nil];
}

- (IBAction)onCancel:(id)sender {
    if (self.didEndSelection) {
        self.didEndSelection(self.datePicker, YES);
        self.didEndSelection = nil;
    }
    [self dismissAnimated:YES completion:nil];
}

@end
