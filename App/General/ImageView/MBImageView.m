
#import "MBImageView.h"
#import "debug.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIView+WebCacheOperation.h>

@interface MBImageView ()
@property NSOperation *_dowloadOperation;
@property (nonatomic) NSString *_downloadingImageURL;
@property NSString *_completedImageURL;
@property MBGeneralCallback completion;
@property NSURL *_urlForDownloadFinishCallbackVerifying;
@end

@implementation MBImageView
RFInitializingRootForUIView

- (void)onInit {
    self.clipsToBounds = YES;
    self.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)afterInit {
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if (self.image) {
        self.placeholderImage = self.image;
    }
    else if (self.placeholderImage) {
        self.image = self.placeholderImage;
    }
}

- (void)setPlaceholderImage:(UIImage *)placeholderImage {
    _placeholderImage = placeholderImage;
    if (self._completedImageURL) return;
    if (self._downloadingImageURL || !self.imageURL) {
        self.image = placeholderImage;
    }
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.disableDownloadPauseWhenRemoveFromWindow) return;
    if (self.window) {
        if (self._completedImageURL != self.imageURL) {
            self._downloadingImageURL = self.imageURL;
        }
    }
    else {
        self._downloadingImageURL = nil;
    }
}

- (void)fetchImageWithImageURL:(NSString *)imageURL complete:(MBGeneralCallback)completion {
    // 回调覆盖什么的先简单处理
    self.completion = completion;
    self.imageURL = imageURL;
}

- (void)setImageURL:(NSString *)imageURL {
    if ([_imageURL isEqualToString:imageURL]) return;
    if (_imageURL) {
        self._completedImageURL = nil;
    }
    _imageURL = imageURL.copy;
    self.image = self.placeholderImage;
    if (imageURL) {
        if (self.window) {
            self._downloadingImageURL = imageURL;
        };
    }
    if (self._downloadingImageURL != imageURL) {
        self._downloadingImageURL = nil;
    }
}

- (void)set_downloadingImageURL:(NSString *)imageURL {
    if ([__downloadingImageURL isEqualToString:imageURL]) return;

    if (__downloadingImageURL) {
        if (imageURL == self.imageURL) {
            // 新值和 imageURL 相同，意味着传入的是新图片，应该通知旧的图片已取消
            if (self.completion) {
                self.completion(NO, nil, nil);
                self.completion = nil;
            }
        }
        [self._dowloadOperation cancel];
    }
    __downloadingImageURL = imageURL;
    if (imageURL) {
        [self loadImageFromRemoteWithURL:imageURL];
    }
}

- (void)loadImageFromRemoteWithURL:(NSString *)imageURL {
    NSURL *url = [NSURL.alloc initWithString:imageURL];
    self._urlForDownloadFinishCallbackVerifying = url;

    @weakify(self);
    self._dowloadOperation = (id)[SDWebImageManager.sharedManager loadImageWithURL:url options:(SDWebImageOptions)self.sdImageLoadOptions progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        @strongify(self);
        if (!self) return;

        dispatch_async_on_main(^{
            if ([imageURL isEqual:self._urlForDownloadFinishCallbackVerifying]) {
                self._urlForDownloadFinishCallbackVerifying = nil;
                self._completedImageURL = self.imageURL;
                if (image) {
                    self.image = image;
                }
                else if (self.failureImage) {
                    self.image = self.failureImage;
                }
                else if (self.placeholderImage) {
                    self.image = self.placeholderImage;
                }
            }

            if (self.completion) {
                self.completion(finished, image, error);
                self.completion = nil;
            }
        });
    }];
}

- (NSUInteger)sdImageLoadOptions {
    return self.imageLoadInLowPriority ? SDWebImageLowPriority : SDWebImageHighPriority;
}

#pragma mark - 尺寸修正

- (void)setBounds:(CGRect)bounds {
    if (self.intrinsicContentSizeFixEnabled) {
        if (CGRectGetWidth(self.bounds) != CGRectGetWidth(bounds)) {
            [self invalidateIntrinsicContentSize];
        }
    }
    [super setBounds:bounds];
}

- (CGSize)intrinsicContentSize {
    CGSize osize = [super intrinsicContentSize];
    if (!self.intrinsicContentSizeFixEnabled) {
        return osize;
    }

    CGSize imageSize = self.image.size;
    CGFloat width = self.bounds.size.width;
    if (imageSize.width <= 0
        || imageSize.height <= 0
        || width == 0) {
        return osize;
    }
    switch (self.contentMode) {
        case UIViewContentModeScaleAspectFit: {
            if (width > imageSize.width) {
                return CGSizeMake(width, imageSize.height);
            }
            // Else continue as fill
        }
        case UIViewContentModeScaleToFill:
        case UIViewContentModeScaleAspectFill: {
            return CGSizeMake(width, imageSize.height/imageSize.width*width);
        }

        default:
            return CGSizeMake(width, imageSize.height);
    }
}

@end
