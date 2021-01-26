
#import "MBRoundBarButtonItem.h"
#import "Common.h"
#import "MBButton.h"
#import <RFAlpha/RFDrawImage.h>

@interface MBRoundBarButtonItem ()
@property UIButton *buttonView;
@end

@implementation MBRoundBarButtonItem

- (void)awakeFromNib {
    [super awakeFromNib];
    [self _MBRoundBarButtonItem_setupCustomView];
}

- (void)_MBRoundBarButtonItem_setupCustomView {
    UIButton *contentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIColor *color = self.tintColor;
    UIColor *highlightColor = color.rf_darkerColor;
    CGFloat corners = 3;
    UIEdgeInsets imageInsets = UIEdgeInsetsMakeWithSameMargin(corners);
    CGSize imageSize = CGSizeMake(corners + corners + 1, corners + corners + 1);
    UIImage *backgrounImage = [RFDrawImage imageWithRoundingCorners:imageInsets size:imageSize fillColor:color strokeColor:nil strokeWidth:0 boxMargin:UIEdgeInsetsZero resizableCapInsets:imageInsets scaleFactor:0];
    UIImage *backgrounHighlightImage = [RFDrawImage imageWithRoundingCorners:imageInsets size:imageSize fillColor:highlightColor strokeColor:nil strokeWidth:0 boxMargin:UIEdgeInsetsZero resizableCapInsets:imageInsets scaleFactor:0];

    [contentButton setBackgroundImage:backgrounImage forState:UIControlStateNormal];
    [contentButton setBackgroundImage:backgrounHighlightImage forState:UIControlStateHighlighted];
    contentButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [contentButton setTitle:self.title forState:UIControlStateNormal];
    CGRect buttonFrame = ({
        CGRect frame = CGRectZero;
        CGSize preferSize = contentButton.intrinsicContentSize;
        preferSize.width += 10;
        preferSize.height = contentButton.titleLabel.font.pointSize + 10;
        frame.size = preferSize;
        frame;
    });
    contentButton.frame = buttonFrame;
    [contentButton addTarget:self action:@selector(_MBRoundBarButtonItem_buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.buttonView = contentButton;
    
    // 按钮相对于系统默认位置的偏移
    UIOffset offset = UIOffsetMake(6, 0);
    MBControlTouchExpandContainerView *layoutOffsetView = MBControlTouchExpandContainerView.new;
    layoutOffsetView.controls = @[contentButton];
    layoutOffsetView.bounds = ({
        CGRect bounds = buttonFrame;
        bounds.size.height -= offset.vertical * 2;
        bounds.size.width -= offset.horizontal;
        bounds;
    });
    [layoutOffsetView addSubview:contentButton];
    
    self.customView = layoutOffsetView;
}

- (void)_MBRoundBarButtonItem_buttonTapped:(UIButton *)button {
    [UIApplication.sharedApplication sendAction:self.action to:self.target from:self forEvent:nil];
}

@end
