/*!
 MBFormFieldVerifyControl

 Copyright © 2018, 2020 RFUI.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFKit/RFRuntime.h>

@class MBTextField;

// @MBDependency:2
/**
 关联一组输入框和按钮，如果都验证通过使按钮 enable，否则 disable
 */
@interface MBFormFieldVerifyControl : NSObject

/// 需要监听的输入框
@property (nullable, nonatomic) IBOutletCollection(MBTextField) NSArray *textFields;

/// 验证跳过隐藏的输入框，默认关闭
/// 通过 isVisible 扩展检查，应该能覆盖大部分情形
@property IBInspectable BOOL validationSkipsHiddenFields;

/// 更新验证，在输入框隐藏切换时需调用
- (void)updateValidation;

/// 是否通过验证
@property (readonly) BOOL isValid;

/// 正常的提交按钮
/// UIControl 或 bar button item
@property (weak, nullable, nonatomic) IBOutlet id submitButton;

/**
 验证不通过时点击的按钮

 如果设置，当有输入框的 nextField 指向 submitButton 时，会更新该指向
 */
@property (weak, nullable, nonatomic) IBOutlet id invalidSubmitButton;

@end
