
#import "MBCodeSendButton.h"
#import <RFAlpha/RFTimer.h>

@interface MBCodeSendButton ()
@property RFTimer *timer;
@end

@implementation MBCodeSendButton

- (void)dealloc {
    [self.timer invalidate];
}

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

- (void)markSending:(NSString *)sendingMessage {
    NSString *message = sendingMessage ?: [self titleForState:UIControlStateSelected];
    [self setTitle:message ?: @"发送中" forState:UIControlStateDisabled];
    self.enabled = NO;
}

- (void)froze {
    self.enabled = NO;
    if (self.nextField) {
        [self.nextField becomeFirstResponder];
    }
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
