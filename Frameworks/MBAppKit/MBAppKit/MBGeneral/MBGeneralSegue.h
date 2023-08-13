/*!
 MBGeneralSegue
 MBAppKit
 
 Copyright © 2018 RFUI.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Information Technology Co., Ltd.
 https://github.com/RFUI/MBAppKit
 
 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */
#import <RFKit/RFRuntime.h>

/*!
 UIViewController 基类的 prepareForSegue:sender: 方法已被重载为符合 MBGeneralItemExchanging、MBGeneralListItemExchanging 的通用实现。
 
 通用实现大概是：
 
 * 如果 destinationViewController 通过 item 传值，依次从以下来源寻找 item 传递
    1. source vc 的 itemForSegue:sender:
    2. sender 的 item
    3. sender 各级父 view（直到 vc 的 view）的 item
    4. vc 的 item
 
 * 如果 destinationViewController 通过 items 传值，依次从以下来源寻找 item 传递
    1. sender 的 items
    2. sender 各级父 view（直到 vc 的 view）的 items
    3. vc 的 items
 
 如果默认实现传递的对象不符合业务，可以在业务 vc 中重写 prepareForSegue:sender: 或者 itemForSegue:sender: 方法。
 
 一般情况下，因为已有默认实现，MBSynthesize 宏可以不用了。
 */

@protocol MBGeneralSegue <NSObject>
@required

- (nullable id)itemForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender;

@end

@interface UIViewController (MBGeneralSegue)
@end

/**
 prepareForSegue:sender: 的实现现在是统一的，item 的提供现在有 itemForSegue:sender: 方法
 */
#define MBSynthesizePrepareForSegue \
    - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {\
        id<MBGeneralItemExchanging> dvc = (id)segue.destinationViewController;\
        if ([dvc respondsToSelector:@selector(setItem:)]) {\
            id item = [self itemForSegue:segue sender:sender];\
            [dvc setItem:item];\
            return;\
        }\
        [super prepareForSegue:segue sender:sender];\
    }

/**
 生成适合普通 view controller 的 itemForSegue:sender:
 */
#define MBSynthesizeItemForSegue \
    - (nullable id)itemForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender {\
        return MBGeneralSegueItem(segue, sender, nil, self);\
    }

/**
 生成适合含有 table view 的 view controller 的 itemForSegue:sender:
 */
#define MBSynthesizeTableViewItemForSegue \
    - (nullable id)itemForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender {\
        return MBGeneralSegueItem(segue, sender, [UITableViewCell class], self);\
    }

/**
 生成适合含有 collection view 的 view controller 的 itemForSegue:sender:
 */
#define MBSynthesizeCollectionViewItemForSegue \
    - (nullable id)itemForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender {\
        return MBGeneralSegueItem(segue, sender, [UICollectionView class], self);\
    }


/**
 一般的 itemForSegue:sender: 实现
 
 @param cellClass sender 可能是 table view cell 或 collection view cell 中的 view，如果传入会尝试调用 itemFromSender: 确定 item
 @param viewController 如果 sender 和 cell 上都没有找到 item，尝试从这个参数找，一般传当前界面的 view controller
 */
FOUNDATION_EXPORT id _Nullable MBGeneralSegueItem(UIStoryboardSegue *_Nonnull segue, id _Nullable sender, Class _Nullable cellClass, id _Nullable viewController);


/**
 prepareForSegue:sender: 默认传递方法

 首先检查 destinationViewController 是否可以设置 item 属性，如果可以会依次检查 sender 和 self 是否有 item 属性可以传递
 */
#define MBEntityExchangingPrepareForSegue \
    MBSynthesizeItemForSegue\
    MBSynthesizePrepareForSegue

#define MBEntityExchangingPrepareForTableViewSegue \
    MBSynthesizeTableViewItemForSegue\
    MBSynthesizePrepareForSegue

#define MBEntityExchangingPrepareForCollectionViewSegue \
    MBSynthesizeCollectionViewItemForSegue\
    MBSynthesizePrepareForSegue
