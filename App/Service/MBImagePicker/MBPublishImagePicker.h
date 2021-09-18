/*
 MBPublishImagePicker
 
 Copyright © 2018, 2020-2021 BB9z.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/RFUI/MBAppKit
 
 The MIT License
 https://opensource.org/licenses/MIT
 */
#import <MBAppKit/MBAppKit.h>

// @MBDependency:3
/**
 通用图片选择器
 */
@interface MBPublishImagePicker : NSObject

/**
 选择图像并裁切，返回裁切好的图像

 @param title 选择从相册还是相机的标题
 @param size 头像裁切尺寸，像素
 @param completion 主线程回调，item 是 UIImage
 */
+ (void)pickAvatarImageWithCropSize:(CGSize)size actionSheetTitle:(nullable NSString *)title completion:(nonnull MBGeneralCallback)completion;

/**
 选择图像并返回

 @param configBlock 可以进行丰富的设置来控制流程
 @param completion 主线程回调，item 根据设置的不同可以是各种类型，一般如果上传会返回 图片URL，只选图片是 UIImage
 */
+ (void)pickImageWithConfiguration:(NS_NOESCAPE void (^__nullable)(MBPublishImagePicker *__nonnull instance))configBlock completion:(nonnull MBGeneralCallback)completion;

/// 弹出选择相册还是照相时的标题
@property (nullable) NSString *selectImagePickerSourceTitle;

/// 直接使用系统相机选图
@property BOOL onlyCameraPicker;

/// 直接使用系统相册选图
@property BOOL onlyLibraryPicker;

/// 开启后，使用系统图片选择器选中图片后立即返回，回调 item 是 NSDictionary
@property BOOL shouldReturnRawPickerInfoInsteadOfImageObject;

/// 选中图片后是否进行裁切
@property BOOL cropAfterImageSelected;

/// 裁切尺寸，如果裁切，尺寸不得小于 10x10
@property CGSize cropSize;

/// 选完图片自动进行上传，会强制转为 60% 质量的 JPEG 图片
@property BOOL autoUpload;

/// 上传时限制的图片像素尺寸，当非 CGSizeZero 时，上传前会缩小图片保证宽高都不会超过给定范围
@property CGSize uploadImageSizeLimit;

/// 上传图片时显示的模态进度文字
@property (nullable) NSString *loadingText;

/// 以下属性在 iPad 上使用
@property (nullable) UIBarButtonItem *popoverPresentationBarButtonItem;
@property (nullable) UIView *popoverPresentationSourceView;
@property CGRect popoverPresentationSourceRect;
@property (nullable) void (^popoverConfiguration)(UIPopoverPresentationController *__nonnull popover);

@property (class, readonly, nonnull) NSErrorDomain errorDomain;

@end
