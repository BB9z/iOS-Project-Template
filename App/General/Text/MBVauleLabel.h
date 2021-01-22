/*
 MBVauleLabel
 
 Copyright © 2018, 2020 RFUI.
 Copyright © 2015-2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <RFKit/RFRuntime.h>
#import <RFInitializing/RFInitializing.h>

// @MBDependency:1
/**
 设置 value，格式化显示
 */
@interface MBVauleLabel : UILabel
@property (nullable, nonatomic) id value;

/// 重写或设置 block 改变展示方式
- (nullable NSString *)displayStringForVaule:(nullable id)value;
@property (nullable) NSString*__nullable (^valueFormatBlock)(__kindof MBVauleLabel *__nonnull label, id __nullable value);
@end

// @MBDependency:2
/**
 支持占位符替换数值的富文本
 */
@interface MBVauleAttributedLabel : UILabel <
    RFInitializing
>
@property (nullable, nonatomic) id value;

/// 空值时显示的文本
@property (nullable) IBInspectable NSString *nullValueDisplayString;

/// 空数字显示空值文本
@property IBInspectable BOOL treatZeroNumberAsNull;

/// awakeFromNib 时设置，代码创建需要手动赋值
@property (nullable) NSAttributedString *attributedFormatString;

/// 重写或设置 block 改变展示方式
- (nullable NSAttributedString *)displayAttributedStringForVaule:(nullable id)value;
@property (nullable) NSAttributedString*__nullable (^valueFormatBlock)(__kindof MBVauleAttributedLabel *__nonnull label, id __nullable value);
@end
