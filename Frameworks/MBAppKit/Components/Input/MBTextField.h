/*!
 MBTextField
 MBAppKit
 
 Copyright © 2018, 2021 RFUI.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <RFKit/RFRuntime.h>
#import <RFInitializing/RFInitializing.h>

/**
 TextField 封装
 
 特性：

 - placeholder 样式调整
 - 调整了 TextField 的默认高度
 - 通过 textEdgeInsets 属性，可以修改文字与边框的距离
 - 获得焦点后自动设置高亮背景
 - 编辑内容自动同步到 vc 的 item
 - 用户按换行可以自动切换到下一个输入框或执行按钮操作，只需设置 nextField 属性，键盘的 returnKeyType 如果是默认值则还会自动修改
 - 可以限制用户输入长度，超出限制长度表现为不可增加字符
 
 注意：
 
 - 原生的 borderStyle 属性会在初始化之后被重新设定为 UITextBorderStyleNone 以便定义外观
 
 */
@interface MBTextField : UITextField <
    RFInitializing
>

#pragma mark - 外观

/**
 样式名，以便让同一个按钮类支持多个样式
 
 一般在 setupAppearance 根据 styleName 做相应配置
 */
@property (nullable) IBInspectable NSString *styleName;
@property IBInspectable BOOL skipAppearanceSetup;
@property (readonly) BOOL appearanceSetupDone;
- (void)setupAppearance;

/**
 文字与边框的边距
 
 默认上下 7pt，左右 10pt
 */
@property (nonatomic) UIEdgeInsets textEdgeInsets;
@property (nonatomic) IBInspectable CGRect _textEdgeInsets;

/// 非空时，text filed 获取/失去键盘焦点时会在 backgroundHighlightedImage 和 backgroundImage 之间切换
@property (nonatomic, nullable) IBInspectable UIImage *backgroundHighlightedImage;

/// 默认背景图，从 nib 载入时如果 backgroundHighlightedImage 非空，会自动拷贝 background 的属性
@property (nonatomic, nullable) IBInspectable UIImage *backgroundImage;

@property (nonatomic, nullable) NSDictionary *placeholderTextAttributes;

/**
 文字变更时调用
 
 用户通过键盘改变文字时会自动调用，程序通过 setText: 需要手动调用以便更新 UI
 */
- (void)updateUIForTextChanged;

#pragma mark - 附加 view

/// 内容非空时设置状态为 highlighted
@property (nonatomic, nullable, weak) IBOutlet UIImageView *iconImageView;

/// 文字非空时显示的 view，布局交给外部，text field 不进行管理
@property (nonatomic, nullable, weak) IBOutlet UIView *contentAccessoryView;

#pragma mark - 表单

/**
 在添加到 window 时自动获取键盘
 */
@property IBInspectable BOOL autoBecomeFirstResponder;

/**
 供子类重载，内容类型，可用于验证和配置
 */
@property (nullable) IBInspectable NSString *formContentType;

/**
 若非空，在 textFieldDidEndEditing: 时尝试用 KVO 修改其 view controler 中 item 对应属性
 
 @warning 如果点按按钮时没有显示取消焦点，此时 textFieldDidEndEditing 尚未出发因而数据是不全的
 */
@property (nonatomic, nullable) IBInspectable NSString *formItemKey;

/**
 按键盘上的 return 需跳转到的控件
 */
@property (nonatomic, nullable, weak) IBOutlet id nextField;

#pragma mark - 验证

/**
 供子类重载，判断输入是否正确，默认 YES
 */
@property (readonly) BOOL isFieldVaild;

/**
 限制最大输入长度
 */
@property IBInspectable NSUInteger maxLength;

@end
