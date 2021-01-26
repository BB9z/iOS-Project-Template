
#import "MBValueMapPickerViewController.h"
#import <MBAppKit/MBGeneralItemExchanging.h>

@interface MBValueMapPickerViewController () <
    UIPickerViewDelegate,
    UIPickerViewDataSource
>
@end

@implementation MBValueMapPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUIForValuesChanged];
}

- (void)setValues:(NSArray *)values {
    _values = values;
    if (!self.isViewLoaded) return;
    [self updateUIForValuesChanged];
}

- (void)updateUIForValuesChanged {
    NSArray *values = self.values;
    self.emptyLabel.hidden = (values.count > 0);
    if (values.count == 0) return;
    NSInteger idx = [values indexOfObject:self.selectedVaule];
    if (idx == NSNotFound) {
        self.selectedVaule = values.firstObject;
        idx = 0;
    }
    RFAssert(self.pickerView, @"view not set properly");
    [self.pickerView selectRow:idx inComponent:0 animated:NO];
}

- (NSString *)displayStringWithValue:(id)value {
    if (self.valueDisplayString) {
        return self.valueDisplayString(value);
    }
    if (self.valueDisplayMap
        && [self.values containsObject:value]) {
        return self.valueDisplayMap[value];
    }
    if ([value respondsToSelector:@selector(displayString)]) {
        return [(id<MBItemExchanging>)value displayString];
    }
    return [NSString stringWithFormat:@"%@", value];
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self displayStringWithValue: self.values[row]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedVaule = self.values[row];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.values.count;
}

#pragma mark -

- (IBAction)onSave:(id)sender {
    if (self.didEndSelection) {
        self.didEndSelection(self, self.selectedVaule);
        self.didEndSelection = nil;
    }
    [self dismissAnimated:YES completion:nil];
}

- (IBAction)onCancel:(id)sender {
    if (self.didEndSelection) {
        self.didEndSelection(self, nil);
        self.didEndSelection = nil;
    }
    [self dismissAnimated:YES completion:nil];
}

@end
