
#import "MBTextField.h"
#import "MBGeneralItemExchanging.h"
#import <RFDelegateChain/UITextFiledDelegateChain.h>
#import <RFKit/RFGeometry.h>
#import <RFKit/UIResponder+RFKit.h>

@interface MBTextField ()
@property BOOL appearanceSetupDone;
@property (nonatomic) UITextFiledDelegateChain *trueDelegate;
@end

@implementation MBTextField
@dynamic _textEdgeInsets;
RFInitializingRootForUIView

- (void)onInit {
    // 文字距边框设定
    self.textEdgeInsets = UIEdgeInsetsMake(7, 10, 7, 10);
    [super setDelegate:self.trueDelegate];
}

- (void)afterInit {
    // 修改 place holder 文字样式
    if (self.placeholder) {
        self.placeholder = self.placeholder;
    }

    if (self.returnKeyType == UIReturnKeyDefault
        && self.nextField) {
        [self MBTextField_setupReturnKeyType];
    }

    [self addTarget:self action:@selector(updateUIForTextChanged) forControlEvents:UIControlEventEditingChanged];
    [self _setupAppearance];
    
    if (self.backgroundHighlightedImage) {
        [self MBTextField_updateBackgroundForHighlighted:self.isFirstResponder];
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    [self _setupAppearance];
    
    if (self.formItemKey) {
        id<MBGeneralItemExchanging> vc = (id)self.viewController;
        if (newWindow) {
            id v = [vc.item valueForKey:self.formItemKey];
            if (v) {
                self.text = v;
            }
        }
        else {
            [vc.item setValue:self.text forKey:self.formItemKey];
        }
    }
}

#pragma mark - Style Appearance

- (void)awakeFromNib {
    [super awakeFromNib];
    // 焦点自动设置
    if (self.backgroundHighlightedImage) {
        if (!self.backgroundImage) {
            self.backgroundImage = self.background;
        }
        self.borderStyle = UITextBorderStyleNone;
    }
    [self _setupAppearance];
}

- (void)_setupAppearance {
    if (self.appearanceSetupDone) return;
    self.appearanceSetupDone = YES;
    if (!self.skipAppearanceSetup) {
        [self setupAppearance];
    }
    [self updateUIForTextChanged];
}

- (void)setupAppearance {
    // for overwrite
}

#pragma mark - 修改 place holder 文字样式
- (void)setPlaceholder:(NSString *)placeholder {
    // iOS 6 无效果
    if (self.placeholderTextAttributes) {
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:self.placeholderTextAttributes];
    }
    else {
        [super setPlaceholder:placeholder];
    }
}

- (void)setPlaceholderTextAttributes:(NSDictionary *)placeholderTextAttributes {
    _placeholderTextAttributes = placeholderTextAttributes;
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:self.placeholderTextAttributes];
}

#pragma mark - 修改默认文字框最低高度
- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    size.height = MAX(size.height, 36);
    return size;
}

#pragma mark - 文字距边框设定

- (CGRect)_textEdgeInsets {
    return [NSValue valueWithUIEdgeInsets:self.textEdgeInsets].CGRectValue;
}
- (void)set_textEdgeInsets:(CGRect)_textEdgeInsets {
    self.textEdgeInsets = [NSValue valueWithCGRect:_textEdgeInsets].UIEdgeInsetsValue;
}

- (void)setTextEdgeInsets:(UIEdgeInsets)textEdgeInsets {
    if (UIEdgeInsetsEqualToEdgeInsets(_textEdgeInsets, textEdgeInsets)) return;
    _textEdgeInsets = textEdgeInsets;
    [self setNeedsLayout];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return UIEdgeInsetsInsetRect(bounds, self.textEdgeInsets);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

#pragma mark - 获取焦点自动高亮
- (BOOL)becomeFirstResponder {
    BOOL can = [super becomeFirstResponder];
    if (can) {
        [self MBTextField_updateBackgroundForHighlighted:YES];
    }
    return can;
}

- (BOOL)resignFirstResponder {
    BOOL can = [super resignFirstResponder];
    if (can) {
        [self MBTextField_updateBackgroundForHighlighted:NO];
    }
    return can;
}

- (void)MBTextField_updateBackgroundForHighlighted:(BOOL)highlighted {
    if (!self.backgroundHighlightedImage) return;
    self.background = highlighted? self.backgroundHighlightedImage : self.backgroundImage;
}

#pragma mark - 自动获取焦点

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window && self.autoBecomeFirstResponder) {
        [self becomeFirstResponder];
    }
}

#pragma mark - 表单

- (BOOL)isFieldVaild {
    return YES;
}

- (void (^)(UITextField *, id))MBTextField_didEndEditing {
    return ^(UITextField *aTextField, id<UITextFieldDelegate> delegate) {
        MBTextField *textField = (id)aTextField;
        if (textField.formItemKey) {
            id<MBGeneralItemExchanging> vc = (id)textField.viewController;
            RFAssert([vc respondsToSelector:@selector(item)], @"MBTextField has formItemKey sets but it's vc not have an item");
            [vc.item setValue:textField.text forKey:textField.formItemKey];
        }
        if ([delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
            [delegate textFieldDidEndEditing:aTextField];
        }
    };
}

#pragma mark - Next Filed

- (void)setNextField:(id)nextField {
    _nextField = nextField;
    if (self.appearanceSetupDone) {
        [self MBTextField_setupReturnKeyType];
    }
}

- (void)MBTextField_setupReturnKeyType {
    if ([self.nextField isKindOfClass:UITextField.class] || [self.nextField isKindOfClass:UITextView.class]) {
        self.returnKeyType = UIReturnKeyNext;
    }
    else if ([self.nextField isKindOfClass:UIBarButtonItem.class]) {
        self.returnKeyType = UIReturnKeyDone;
    }
    else {
        self.returnKeyType = UIReturnKeySend;
    }
}

- (BOOL (^)(UITextField *, id))MBTextField_shouldReturn {
    return ^BOOL(UITextField *aTextField, id<UITextFieldDelegate> delegate) {
        MBTextField *textField = (id)aTextField;
        if ([delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
            if (![delegate textFieldShouldReturn:textField]) {
                return NO;
            }
        }
        if (![textField isKindOfClass:MBTextField.class]) return YES;
        
        id next = textField.nextField;
        if ([next isKindOfClass:UIControl.class]) {
            UIControl *c = next;
            if (c.isEnabled) {
                [textField resignFirstResponder];
                [c sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
        if ([next isKindOfClass:UIBarButtonItem.class]) {
            UIBarButtonItem *bi = (UIBarButtonItem *)next;
            if (bi.isEnabled) {
                [textField resignFirstResponder];
                [UIApplication.sharedApplication sendAction:bi.action to:bi.target from:bi forEvent:nil];
            }
        }
        
        if ([next respondsToSelector:@selector(canBecomeFirstResponder)]) {
            if ([next canBecomeFirstResponder]) {
                [next becomeFirstResponder];
            }
        }
        return YES;
    };
}

#pragma mark - 文本变化

- (void)updateUIForTextChanged {
    [self MBTextField_onTextFieldChanged:self];
}

- (void)MBTextField_onTextFieldChanged:(UITextField *)textField {
    if (self.iconImageView) {
        BOOL on = textField.text.length;
        if (!self.isFieldVaild) {
            on = NO;
        }
        self.iconImageView.highlighted = on;
    }
    if (self.contentAccessoryView) {
        self.contentAccessoryView.hidden = !textField.text.length;
    }
    if (!self.maxLength) return;

    // Skip multistage text input
    if (textField.markedTextRange) return;

    NSString *text = textField.text;
    NSInteger maxLegnth = self.maxLength;
    if (text.length > maxLegnth) {
        NSRange rangeIndex = [text rangeOfComposedCharacterSequenceAtIndex:maxLegnth];
        if (rangeIndex.length == 1) {
            textField.text = [text substringToIndex:maxLegnth];
        }
        else {
            NSRange rangeRange = [text rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, maxLegnth)];
            textField.text = [text substringWithRange:rangeRange];
        }
    }
}

- (BOOL (^)(UITextField *, NSRange, NSString *, id))MBTextField_shouldChangeCharacters {
    return ^BOOL(UITextField *aTextField, NSRange inRange, NSString *replacementString, id<UITextFieldDelegate> delegate) {
        MBTextField *textField = (id)aTextField;

        if (textField.maxLength) {
            // Needs limit length, skip multistage text input
            if (!inRange.length
                && !textField.markedTextRange) {
                if (replacementString.length + textField.text.length > textField.maxLength) {
                    return NO;
                }
            }
        }

        if ([delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
            return [delegate textField:aTextField shouldChangeCharactersInRange:inRange replacementString:replacementString];
        }
        return YES;
    };
}

#pragma mark - Delegate

- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
    if (delegate != self.trueDelegate) {
        self.trueDelegate.delegate = delegate;
        self.delegate = self.trueDelegate;
    }
}

- (UITextFiledDelegateChain *)trueDelegate {
    if (_trueDelegate) return _trueDelegate;
    _trueDelegate = UITextFiledDelegateChain.new;
    [_trueDelegate setShouldReturn:self.MBTextField_shouldReturn];
    [_trueDelegate setDidEndEditing:self.MBTextField_didEndEditing];
    [_trueDelegate setShouldChangeCharacters:self.MBTextField_shouldChangeCharacters];
    return _trueDelegate;
}
@end
