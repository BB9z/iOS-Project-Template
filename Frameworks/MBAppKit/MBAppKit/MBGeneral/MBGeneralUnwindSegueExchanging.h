/*!
 MBGeneralUnwindSegueExchanging
 MBAppKit
 
 Copyright © 2018 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 Copyright © 2014 Chinamobo Co., Ltd.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <RFKit/RFRuntime.h>

/**
 TEST

 用在 unwind segue 的 sourceViewController 上
 然后在 destinationViewController 的 IBAction 中取道传过来的量
 */
@protocol MBUnwindSegueExchanging <NSObject>
@optional
@property (nonatomic) NSKeyValueChange unwindChangeType;
@property (nonatomic, nullable, strong) id unwindChangeItem;

// destinationViewController 推荐 IBAction 方法名
// - (IBAction)MBReturnWithUnwindSegue:(UIStoryboardSegue *)segue;
@end

/**
 TEST

 跟 MBUnwindSegueExchanging 相反

 destinationViewController 实现这些属性，在 sourceViewController 中先拿到 destinationViewController 实例并设置这些属性，然后执行返回

 之后 destinationViewController 在显示前（通常是 viewWillApear 中）更新界面
 */
@protocol MBEntityReturnExchanging <NSObject>
@optional
@property (nonatomic) NSKeyValueChange unwindChangeType;
@property (nonatomic, nullable, strong) id unwindChangeItem;

@end
