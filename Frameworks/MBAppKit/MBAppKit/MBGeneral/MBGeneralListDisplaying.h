/*!
 MBGeneralListDisplaying
 MBAppKit

 Copyright © 2018 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <RFKit/RFRuntime.h>

/*!
 统一的列表界面
 */

@protocol MBGeneralListDisplaying <NSObject>
@optional

- (id)listView;

- (void)refresh;

@end
