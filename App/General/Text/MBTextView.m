
#import "MBTextView.h"
#import <RFDelegateChain/UITextViewDelegateChain.h>
#import <RFKit/UIView+RFAnimate.h>


// TODO 限制行数
// REF: https://developer.apple.com/library/mac/documentation/cocoa/conceptual/TextLayout/Tasks/CountLines.html#//apple_ref/doc/uid/20001810-CJBGBIBB

@interface MBTextView ()

@property (nonatomic) UITextViewDelegateChain *trueDelegate;
@property (nonatomic) UILabel *placeholderLabel;
@property CGSize currentSize;

@end


@implementation MBTextView
RFInitializingRootForUIView

#pragma mark - Life Cycle Methods

- (void)onInit {
    [super setDelegate:self.trueDelegate];
    self.scrollsToTop = NO;

    if (!self.placeholderTextColor) {
        self.placeholderTextColor = [UIColor colorNamed:@"placeholder"];
    }
    
    /// 使 TextView 和 backgroundImageView 无缝贴着
    self.textContainerInset = UIEdgeInsetsMake(10, 7, 5, 6);
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_textDidChange) name:UITextViewTextDidChangeNotification object:self];
}

- (void)afterInit {
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if (!self.placeholder) {
        self.placeholder = self.text;
        self.text = nil;
    }
}

- (void)dealloc{
    [NSNotificationCenter.defaultCenter removeObserver:UITextViewTextDidChangeNotification];
}

#pragma mark -监听文字改变

/// UITextViewTextDidChangeNotification 通知回调
- (void)_textDidChange {
    self.placeholderLabel.hidden = self.hasText;
}

- (BOOL)becomeFirstResponder {
    self.backgroundImageView.highlighted = YES;
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    self.backgroundImageView.highlighted = NO;
    return [super resignFirstResponder];
}

#pragma mark - Place Holder

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (CGSizeEqualToSize(self.currentSize, self.bounds.size)) return;
    UIEdgeInsets inset = self.textContainerInset;
    inset.left += 5;
    inset.right += 5;
    CGRect frame = UIEdgeInsetsInsetRect(self.bounds, inset);
    CGSize size = [self.placeholderLabel sizeThatFits:frame.size];
    frame.size.height = size.height;
    self.placeholderLabel.frame = frame;
    self.currentSize = self.bounds.size;
}

- (UILabel *)placeholderLabel {
    if (_placeholderLabel) return _placeholderLabel;
    
    UILabel *placeholderLabel = [[UILabel alloc] init];
    placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:placeholderLabel];
    
    placeholderLabel.text = self.placeholder;
    placeholderLabel.font = self.font;
    placeholderLabel.textColor = self.placeholderTextColor;
    placeholderLabel.numberOfLines = 0;
    _placeholderLabel = placeholderLabel;
    
    return _placeholderLabel;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.placeholderLabel.text = placeholder;
}

- (void)setPlaceholderTextColor:(UIColor *)placeholderTextColor {
    _placeholderTextColor = placeholderTextColor;
    self.placeholderLabel.textColor = placeholderTextColor;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self _textDidChange];
}

- (void)setAttributedText:(NSAttributedString*)attributedText {
    [super setAttributedText:attributedText];
    [self _textDidChange];
}

#pragma mark -

- (CGSize)intrinsicContentSize {
    if (self.autoExpandWhenInput) {
        // 这里要找 _UITextContainerView，根据它的大小返回
        // 直接使用 contentSize 在置空时更新不及时
        for (UIView *view in self.subviews) {
            if ([view.className containsString:@"UITextContainerView"]) {
                return view.size;
            };
        }
    }
    return [super intrinsicContentSize];
}

#pragma mark - Delegate

- (void)setDelegate:(id<UITextViewDelegate>)delegate {
    self.trueDelegate.delegate = delegate;
}

- (UITextViewDelegateChain *)trueDelegate {
    if (!_trueDelegate) {
        _trueDelegate = UITextViewDelegateChain.new;

        [_trueDelegate setDidBeginEditing:^(UITextView *textView, id<UITextViewDelegate> delegate) {
            if ([delegate respondsToSelector:@selector(textViewDidBeginEditing:)]) {
                [delegate textViewDidBeginEditing:textView];
            }
        }];

        [_trueDelegate setDidEndEditing:^(UITextView *textView, id<UITextViewDelegate> delegate) {
            if ([delegate respondsToSelector:@selector(textViewDidEndEditing:)]) {
                [delegate textViewDidEndEditing:textView];
            }
        }];

        [_trueDelegate setShouldChangeTextInRange:^BOOL(UITextView *aTextView, NSRange range, NSString *replacementText, id<UITextViewDelegate> delegate) {
            MBTextView *textView = (id)aTextView;
            _douto(replacementText)
            _douto(NSStringFromRange(range))
            _douto(NSStringFromRange(textView.selectedRange))
            if (textView.singleLineMode && [replacementText containsString:@"\n"]) {
                // Single character input
                if ([replacementText isEqualToString:@"\n"]) {
                    return NO;
                }

                // Paste
                NSString *singleLineString = [replacementText stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

                // Check maxLength limit
                if (textView.maxLength
                    && (textView.text.length + singleLineString.length - range.length > textView.maxLength)) {
                    return NO;
                }

                // Replace textView's text
                NSMutableString *updatedText = [[NSMutableString alloc] initWithString:textView.text];
                [updatedText replaceCharactersInRange:textView.selectedRange withString:singleLineString];
                textView.text = updatedText;

                // Move cursor at end of inserted text
                textView.selectedRange = NSMakeRange(range.location + singleLineString.length, 0);
                return NO;
            }

            if (textView.maxLength
                && !textView.markedTextRange) {
                // Needs limit length
                if (replacementText.length + textView.text.length - range.length > textView.maxLength) {
                    return NO;
                }
            }

            if ([delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
                return [delegate textView:aTextView shouldChangeTextInRange:range replacementText:replacementText];
            }
            return YES;
        }];

        [_trueDelegate setDidChange:^(UITextView *aTextView, id<UITextViewDelegate> delegate) {
            MBTextView *textView = (id)aTextView;
            if (textView.autoExpandWhenInput) {
                [textView invalidateIntrinsicContentSize];
            }

            if (!!textView.maxLength
                && !textView.markedTextRange) {
                if (textView.text.length > textView.maxLength) {
                    textView.text = [textView.text substringToIndex:textView.maxLength];
                }
            }
            
            if ([delegate respondsToSelector:@selector(textViewDidChange:)]) {
                return [delegate textViewDidChange:textView];
            }
        }];
    }
    return _trueDelegate;
}

@end
