
#import "MBIndefiniteRotationImageView.h"
#import "CALayer+MBAnimationPersistence.h"

@implementation MBIndefiniteRotationImageView

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (newWindow) {
        [self addAnimationIfNeeded];
    }
}

- (void)setAnimationStopped:(BOOL)animationStopped {
    _animationStopped = animationStopped;
    if (animationStopped) {
        [self.layer removeAnimationForKey:@"rotate"];
    }
    else {
        if (self.window) {
            [self addAnimationIfNeeded];
        }
    }
}

- (void)addAnimationIfNeeded {
    if (self.animationStopped || [self.layer.animationKeys containsObject:@"rotate"]) return;
    
    NSTimeInterval animationDuration = self.rotateDuration > 0 ? self.rotateDuration : 1;
    CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    if (self.counterClockwiseDirection) {
        animation.fromValue = @(M_PI*2);
        animation.toValue = @0;
    }
    else {
        animation.fromValue = @0;
        animation.toValue = @(M_PI*2);
    }
    animation.duration = animationDuration;
    animation.timingFunction = linearCurve;
    animation.removedOnCompletion = NO;
    animation.repeatCount = INFINITY;
    animation.fillMode = kCAFillModeForwards;
    animation.autoreverses = NO;
    [self.layer addAnimation:animation forKey:@"rotate"];
    [self.layer MBPersistCurrentAnimations];
}

#pragma mark -

- (BOOL)isAnimating {
    return !self.animationStopped;
}

- (void)startAnimating {
    self.animationStopped = NO;
}

- (void)stopAnimating {
    self.animationStopped = YES;
}

@end
