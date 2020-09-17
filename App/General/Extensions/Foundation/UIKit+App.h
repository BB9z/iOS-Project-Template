/*
 UIKit+App
 */

/**
 全局引用常用扩展
 */

#import <RFKit/RFKit.h>
#import <RFKit/NSDate+RFKit.h>
#import <RFKit/NSDateFormatter+RFKit.h>

#pragma mark -

#if __has_include("NSArray+App.h")
#   import "NSArray+App.h"
#endif

#if __has_include("NSString+App.h")
#   import "NSString+App.h"
#endif

#if __has_include("NSURL+App.h")
#   import "NSURL+App.h"
#endif

#if !TARGET_OS_WATCH

#if __has_include("UICollectionView+App.h")
#   import "UICollectionView+App.h"
#endif

#if __has_include("UIImage+MBImageSet.h")
#   import "UIImage+MBImageSet.h"
#endif

#if __has_include("UITableView+App.h")
#   import "UITableView+App.h"
#endif

#import "UIViewController+App.h"

#endif // END: !TARGET_OS_WATCH
