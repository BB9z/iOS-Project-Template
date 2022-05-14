
#import "MBSearchTextField.h"
#import "Common.h"
#import <RFAlpha/RFTimer.h>
#import <RFDelegateChain/UITextFiledDelegateChain.h>
#import <MBAppKit/MBAPI.h>

@interface MBSearchTextField ()
@property (nonatomic) RFTimer *autoSearchTimer;
@property (nonatomic) UITextFiledDelegateChain *trueDelegate;
@end

@implementation MBSearchTextField
RFInitializingRootForUIView

- (void)onInit {
    self.autoSearchTimeInterval = 0.6;
}

- (void)afterInit {
    [super setDelegate:self.trueDelegate];
    self.returnKeyType = UIReturnKeySearch;
    [self addTarget:self action:@selector(MBTextField_onTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
}

- (void)dealloc {
    [_autoSearchTimer invalidate];
}

#pragma mark - Delegate

- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
    if (delegate != self.trueDelegate) {
        self.trueDelegate.delegate = delegate;
        self.delegate = self.trueDelegate;
    }
}

- (void)MBTextField_onTextFieldChanged:(UITextField *)textField {    
    if (textField.markedTextRange) return;
    NSString *s = textField.text;
    if (!s.length) {
        return;
    }
    self.autoSearchTimer.suspended = YES;
    if (self.APIName) {
        [MBApp.status.api cancelOperationWithIdentifier:self.APIName];
    }
    self.autoSearchTimer.suspended = NO;
}

- (UITextFiledDelegateChain *)trueDelegate {
    if (!_trueDelegate) {
        _trueDelegate = [UITextFiledDelegateChain new];
        @weakify(self);
        [_trueDelegate setShouldReturn:^BOOL(UITextField *aTextField, id<UITextFieldDelegate> delegate) {
            @strongify(self);
            MBSearchTextField *textField = (id)aTextField;
            if ([delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
                if (![delegate textFieldShouldReturn:textField]) {
                    return NO;
                }
            }
            if (!textField.text.length) {
                return NO;
            }
            [self MBSearchTextField_doSearchIsAuto:NO];
            return YES;
        }];
    }
    return _trueDelegate;
}

#pragma mark 搜索

- (RFTimer *)autoSearchTimer {
    if (!_autoSearchTimer && self.autoSearchTimeInterval > 0) {
        _autoSearchTimer = [RFTimer new];
        _autoSearchTimer.timeInterval = self.autoSearchTimeInterval;
        
        @weakify(self);
        [_autoSearchTimer setFireBlock:^(RFTimer *timer, NSUInteger repeatCount) {
            @strongify(self);
            [self MBSearchTextField_doSearchIsAuto:YES];
        }];
    }
    return _autoSearchTimer;
}

- (void)doSearchforce {
    [self MBSearchTextField_doSearchIsAuto:NO];
}
- (void)MBSearchTextField_doSearchIsAuto:(BOOL)isAuto {
    if ((self.disallowEmptySearch && !self.text.length)
        || self.text.length < self.autoSearchMinimumLength) {
        return;
    }
    if (self.doSearch) {
        self.isSearching = YES;
        self.doSearch(self.text, isAuto);
    }
}

@end
