
#import "MBButton.h"
#import <RFKit/RFGeometry.h>

@interface MBButton ()
@property (readwrite) BOOL appearanceSetupDone;
@property BOOL _MBButton_blockTouchEventFlag;
@end

@implementation MBButton
@dynamic _touchHitTestExpandInsets;
RFInitializingRootForUIView

- (void)onInit {
}

- (void)afterInit {
    [self addTarget:self action:@selector(onButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self _setupAppearance];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self _setupAppearance];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    [self _setupAppearance];
}

- (void)_setupAppearance {
    if (self.appearanceSetupDone) return;
    self.appearanceSetupDone = YES;
    if (!self.skipAppearanceSetup) {
        [self setupAppearance];
    }
}

- (void)onButtonTapped {
    // For overwrite
}

- (void)setupAppearance {
    // For overwrite
}

- (void)setBounds:(CGRect)bounds {
    CGRect old = self.bounds;
    [super setBounds:bounds];
    if (!self.skipAppearanceSetup
        && !CGSizeEqualToSize(old.size, bounds.size)) {
        [self setupAppearanceAfterSizeChanged];
    }
}

- (void)setFrame:(CGRect)frame {
    CGRect old = self.frame;
    [super setFrame:frame];
    if (!self.skipAppearanceSetup
        && !CGSizeEqualToSize(old.size, frame.size)) {
        [self setupAppearanceAfterSizeChanged];
    }
}

- (void)setupAppearanceAfterSizeChanged {
    // For overwrite
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    UIEdgeInsets reversedInsets = UIEdgeInsetsReverse(self.touchHitTestExpandInsets);
    CGRect expandRect = UIEdgeInsetsInsetRect(self.bounds, reversedInsets);
    return CGRectContainsPoint(expandRect, point);
}

- (CGRect)_touchHitTestExpandInsets {
    return [NSValue valueWithUIEdgeInsets:self.touchHitTestExpandInsets].CGRectValue;
}
- (void)set_touchHitTestExpandInsets:(CGRect)_touchHitTestExpandInsets {
    self.touchHitTestExpandInsets = [NSValue valueWithCGRect:_touchHitTestExpandInsets].UIEdgeInsetsValue;
}

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    if (self.blockTouchEvent && event.type == UIEventTypeTouches) {
        if (!self._MBButton_blockTouchEventFlag) {
            self._MBButton_blockTouchEventFlag = YES;
            self.blockTouchEvent();
            @weakify(self);
            dispatch_after_seconds(0, ^{
                @strongify(self);
                self._MBButton_blockTouchEventFlag = NO;
            });
        }
        return;
    }
    [super sendAction:action to:target forEvent:event];
}

@end


@implementation MBControlTouchExpandContainerView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIControl *c in self.controls) {
        if ([c pointInside:[self convertPoint:point toView:c] withEvent:event]) {
            return YES;
        }
    }
    return [super pointInside:point withEvent:event];
}

@end
