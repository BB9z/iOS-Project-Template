/*!
 MBEntityExchanging
 MBAppKit
 
 Copyright © 2018 RFUI.
 Copyright © 2014-2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 Copyright © 2014 Chinamobo Co., Ltd.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <RFKit/RFRuntime.h>

/**
 标准视图间 model 交换协议
 */
@protocol MBGeneralItemExchanging <NSObject>
@required
@property (nonatomic, nullable, strong) id item;

@optional

/// 期望的 item 类型
- (nonnull Class)preferredItemClass;

@end

/**
 如果 destination 符合 MBGeneralItemExchanging 声明，就把 value 赋值给 destination 的 item 并返回 YES。否则返回 NO
 
 便于在 Swift 中非显式声明协议传值困难
 */
FOUNDATION_EXTERN BOOL MBGeneralItemPassValue(id __nullable destination, id __nullable value);


/**
 item 的可选协议
 */
@protocol MBItemExchanging <NSObject>
@optional
- (NSString *_Nullable)displayString;
@end
