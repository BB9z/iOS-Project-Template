/*
 MBDatePickerViewController
 
 Copyright © 2018, 2020 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import "MBModalPresentSegue.h"

// @MBDependency:2
/**
 时间选择弹窗，使用 UIDatePicker
 
 备忘：使用实例的 - presentFromViewController:animated:completion: 方法弹出
 */
@interface MBDatePickerViewController : MBModalPresentViewController
@property (nonatomic, nullable, weak) IBOutlet UIDatePicker *datePicker;

#pragma mark - 设置

/// 调用后清除
@property (nonatomic, nullable, copy) void (^datePickerConfiguration)(UIDatePicker *__nonnull datePicker);

/// 选择结果的回调
@property (nonatomic, nullable, copy) void (^didEndSelection)(UIDatePicker *__nonnull datePicker, BOOL canceled);

@end
