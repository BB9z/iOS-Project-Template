
#import "MBFormFieldVerifyControl.h"
#import "MBTextField.h"
#import <RFKit/UIView+RFKit.h>

@interface MBFormFieldVerifyControl ()
@property (nonatomic) NSNumber *MBFormFieldVerifyControl_lastVaild;
@end

@implementation MBFormFieldVerifyControl

- (void)setTextFields:(NSArray *)textFields {
    if ([_textFields isEqualToArray:textFields]) return;
    for (MBTextField *f in _textFields) {
        [f removeTarget:self action:@selector(MBFormFieldVerifyControl_textEdit:) forControlEvents:UIControlEventEditingChanged];
    }
    _textFields = textFields;
    for (MBTextField *f in textFields) {
        [f addTarget:self action:@selector(MBFormFieldVerifyControl_textEdit:) forControlEvents:UIControlEventEditingChanged];
    }
    [self MBFormFieldVerifyControl_updateVaild];
}

- (void)MBFormFieldVerifyControl_textEdit:(UITextField *)sender {
    [self MBFormFieldVerifyControl_updateVaild];
}

- (void)updateValidation {
    [self MBFormFieldVerifyControl_updateVaild];
}

- (BOOL)isValid {
    return self.MBFormFieldVerifyControl_lastVaild.boolValue;
}

- (void)MBFormFieldVerifyControl_updateVaild {
    if (!self.textFields) {
        return;
    }
    BOOL v = YES;
    BOOL hasViableField = NO;
    for (MBTextField *f in self.textFields) {
        if (self.validationSkipsHiddenFields) {
            if (!f.isVisible) continue;
            hasViableField = YES;
        }
        if (!f.isFieldVaild) {
            v = NO;
            break;
        }
    }
    // 从 nib 初始化时所有输入框都不可见，不能当验证通过更新
    if (self.validationSkipsHiddenFields && !hasViableField) return;
    self.MBFormFieldVerifyControl_lastVaild = @(v);
}

- (void)setMBFormFieldVerifyControl_lastVaild:(NSNumber *)value {
    if ([value isEqual:_MBFormFieldVerifyControl_lastVaild]) return;
    _MBFormFieldVerifyControl_lastVaild = value;
    bool v = value.boolValue;
    [(UIControl *)self.submitButton setEnabled:v];
    [self MBFormFieldVerifyControl_updateSumitButtonLink];
}

#pragma mark - Buttons

- (void)setSubmitButton:(id)submitButton {
    _submitButton = submitButton;
    [(UIControl *)self.submitButton setEnabled:self.isValid];
    [self MBFormFieldVerifyControl_updateSumitButtonLink];
}
- (void)setInvalidSubmitButton:(id)invalidSubmitButton {
    _invalidSubmitButton = invalidSubmitButton;
    [self MBFormFieldVerifyControl_updateSumitButtonLink];
}

- (void)MBFormFieldVerifyControl_updateSumitButtonLink {
    id invalidControl = self.invalidSubmitButton;
    if (!invalidControl) return;
    BOOL v = self.isValid;
    for (MBTextField *f in self.textFields) {
        if (!f.nextField) continue;
        if (f.nextField == self.submitButton || f.nextField == invalidControl) {
            f.nextField = v ? self.submitButton : invalidControl;
        }
    }
}

@end
