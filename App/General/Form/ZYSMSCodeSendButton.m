
#import "ZYSMSCodeSendButton.h"
#import <RFAlpha/RFTimer.h>

@interface ZYSMSCodeSendButton ()
@property RFTimer *timer;
@end

@implementation ZYSMSCodeSendButton

- (NSUInteger)frozeSecond {
    if (_frozeSecond <= 0) {
        _frozeSecond = 60;
    }
    return _frozeSecond;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    if (!self.disableNoticeFormat) {
        self.disableNoticeFormat = [self titleForState:UIControlStateDisabled];
    }
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self invalidateIntrinsicContentSize];
}

- (void)froze {
    self.enabled = NO;
    if (self.timer.isScheduled) return;

    NSString *initTitle = [NSString stringWithFormat:self.disableNoticeFormat, self.frozeSecond];
    [self setTitle:initTitle forState:UIControlStateDisabled];
    self.unfreezeTime = [NSDate timeIntervalSinceReferenceDate] + self.frozeSecond;

    @weakify(self);
    self.timer = [RFTimer scheduledTimerWithTimeInterval:1 repeats:YES fireBlock:^(RFTimer *timer, NSUInteger repeatCount) {
        @strongify(self);
        NSInteger left = self.unfreezeTime - [NSDate timeIntervalSinceReferenceDate];
        if (left <= 0) {
            [self.timer invalidate];
            self.timer = nil;
            self.enabled = YES;
        }
        else {
            [self setTitle:[NSString stringWithFormat:self.disableNoticeFormat, left] forState:UIControlStateDisabled];
        }
    }];
}

@end
