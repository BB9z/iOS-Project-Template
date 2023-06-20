/*!
 MBGeneralListExchanging
 MBAppKit
 
 Copyright © 2018 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <RFKit/RFRuntime.h>

/**
 
 */
@protocol MBGeneralListItemExchanging <NSObject>
@optional
@property (nonatomic, nullable, strong) NSArray *items;
@end

/**
 如果 destination 符合 MBGeneralListItemExchanging 声明，且 value 是数组，就把 value 赋值给 destination 的 items 并返回 YES。否则返回 NO
 
 便于在 Swift 中非显式声明协议传值困难
 */
FOUNDATION_EXTERN BOOL MBGeneralListItemPassValue(id __nullable destination, id __nullable value);

/**
 可选协议，标明 sender 有 item 属性

 一般用在 cell 上
 */
@protocol MBSenderEntityExchanging <NSObject>
@required
@property (nonatomic, nullable, strong) id item;

@optional
- (void)setItem:(id _Nullable)item offscreenRendering:(BOOL)offscreenRendering;

@end


/**
 
 */
@protocol MBGeneralListExchanging <NSObject>

@optional

+ (nullable id)itemFromSender:(nullable id)sender;

@end

#if !TARGET_OS_OSX
@interface UITableViewCell (MBGeneralListExchanging) <
    MBGeneralListExchanging
>
@end

@interface UICollectionViewCell (MBGeneralListExchanging) <
    MBGeneralListExchanging
>
@end
#endif
