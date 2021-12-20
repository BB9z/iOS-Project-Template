/*!
 MBCodeSendButton
 
 Copyright © 2018, 2020 RFUI.
 Copyright © 2014 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/BB9z/iOS-Project-Template
 
 The MIT License
 https://opensource.org/licenses/MIT
 */

#import "MBButton.h"

// @MBDependency:3
/**
 短信发送按钮
 
 对刷新逻辑进行了封装。推荐使用方式：
 
 1. IB 中设置按钮类
 2. 设置 normal 状态的文字，如「发送」
 3. 设置 disabled 状态的文字，如「%d 秒后重发」
 4. 可选设置 frozeSecond
 5. 短信发送成功后调用 froze 方法
 
 */
@interface MBCodeSendButton : MBButton

/**
 发送短信后显示的文字
 
 必须包含 %d 或其他整型格式化字符，例如：@"%d 秒后重发"
 默认设置为 interface builder 中 disabled 状态的标题
 */
@property (nullable) NSString *disableNoticeFormat;

/**
 短信发送后按钮禁用的时长
 
 默认 60s
 */
@property (nonatomic) IBInspectable NSUInteger frozeSecond;

/**
 短信发送后按钮解禁的时间，timeIntervalSinceReferenceDate
 */
@property NSTimeInterval unfreezeTime;

/**
 标记往服务器的请求正在发送中

 同时禁用按钮，并设置禁用文字标题

 @param sendingMessage 即将显示的文本，如果为空，尝试取 selected 状态的文本
 */
- (void)markSending:(nullable NSString *)sendingMessage NS_SWIFT_NAME( markSending(message:) );

/**
 冻结按钮，进入倒计时
 
 在短信发送成功后调用
 */
- (void)froze;

/**
 请求成功后焦点转移到下一个
 */
@property (weak, nullable) IBOutlet UIResponder *nextField;

@end
