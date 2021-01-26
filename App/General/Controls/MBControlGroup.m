
#import "MBControlGroup.h"

@interface MBControlGroup ()
@property (nonatomic) CGFloat MBControlGroup_intrinsicContentWidth;
@property CFAbsoluteTime _MBControlGroup_lastChangeTime;
@end

@implementation MBControlGroup
@dynamic selectIndex;
@dynamic _itemInsets;
RFInitializingRootForUIView

- (void)onInit {
    _selectionNoticeOnlySendWhenButtonTapped = YES;
    _MBControlGroup_intrinsicContentWidth = UIViewNoIntrinsicMetric;
}

- (void)afterInit {
    // nothing
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; selectedControl = %@; controls = %@>", self.class, self, self.selectedControl, self.controls];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (!self.controls) {
        NSMutableArray *controls = [NSMutableArray arrayWithCapacity:self.subviews.count];
        __block NSInteger selectIndex = NSNotFound;
        __block UIControl *prevSelectedControl = nil;
        NSArray *subviews = self.stackLayoutView ? self.stackLayoutView.arrangedSubviews : self.subviews;
        [subviews enumerateObjectsUsingBlock:^(UIControl *v, NSUInteger idx, BOOL *stop) {
            if ([v isKindOfClass:[UIControl class]]) {
                [controls addObject:v];
                
                if (v.selected) {
                    selectIndex = idx;
                    
                    if (prevSelectedControl) {
                        prevSelectedControl.selected = NO;
                    }
                    prevSelectedControl = v;
                }
            }
        }];
        
        self.controls = controls;
        if (selectIndex != NSNotFound) {
            self.selectIndex = selectIndex;
        }
    }
}

#pragma mark - Controls Set

- (void)setControls:(NSArray *)controls {
    _controls = controls;
    for (UIControl *c in controls) {
        [self MBControlGroup_setupItemAction:c];
    }
}

- (void)MBControlGroup_setupItemAction:(UIControl *)item {
    SEL action = @selector(MBControlGroup_onSubControlTapped:);
    NSString *actionString = NSStringFromSelector(action);
    for (NSString *obj in [item actionsForTarget:self forControlEvent:UIControlEventTouchUpInside]) {
        if ([obj isEqualToString:actionString]) {
            return;
        }
    }
    [item addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Selection

- (void)MBControlGroup_onSubControlTapped:(UIControl *)sender {
    if (self.deselectWhenSelection
        && self.selectedControl == sender) {
        if (self.minimumSelectionChangeInterval
            && CFAbsoluteTimeGetCurrent() - self._MBControlGroup_lastChangeTime < self.minimumSelectionChangeInterval) {
            return;
        }
        // 点击已选中控件取消
        self.selectedControl = nil;
        if (self.selectionNoticeOnlySendWhenButtonTapped) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
        return;
    }

    if (self.minimumSelectionChangeInterval
        && CFAbsoluteTimeGetCurrent() - self._MBControlGroup_lastChangeTime < self.minimumSelectionChangeInterval) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(controlGroup:shouldSelectControlAtIndex:)]) {
        NSInteger idx = [self.controls indexOfObject:sender];
        if (![self.delegate controlGroup:self shouldSelectControlAtIndex:idx]) {
            return;
        }
    }

    [self setSelectedControl:sender animated:YES];
    if (self.selectionNoticeOnlySendWhenButtonTapped) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)setSelectedControl:(UIControl *)selectedControl {
    if (_selectedControl != selectedControl) {
        if (_selectedControl) {
            [self deselectControl:_selectedControl];
            _selectedControl.selected = NO;
        }
        _selectedControl = selectedControl;
        self._MBControlGroup_lastChangeTime = CFAbsoluteTimeGetCurrent();
        if (selectedControl) {
            [self selectControl:selectedControl];
            selectedControl.selected = YES;
        }
    }
    if (!self.selectionNoticeOnlySendWhenButtonTapped) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)setSelectedControl:(UIControl *)selectedControl animated:(BOOL)animated {
    self.selectedControl = selectedControl;
}

#pragma mark Index

+ (NSSet *)keyPathsForValuesAffectingSelectIndex {
    return [NSSet setWithObjects:@keypathClassInstance(MBControlGroup, selectedControl), nil];
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    [self setSelectIndex:selectIndex animated:NO];
}

- (void)setSelectIndex:(NSInteger)selectIndex animated:(BOOL)animated {
    UIControl *c = [self.controls rf_objectAtIndex:selectIndex];
    [self setSelectedControl:c animated:animated];
}

- (NSInteger)selectIndex {
    return [self.controls indexOfObject:self.selectedControl];
}

#pragma mark Effect

- (void)selectControl:(UIControl *)control {
}

- (void)deselectControl:(UIControl *)control {
}

- (BOOL)canBecomeFocused {
    return NO;
}

#pragma mark - Layout

- (void)updateConstraints {
    [super updateConstraints];
    if (!self.selfLayoutEnabled) return;

    // 去除子控件相对自己的布局约束
    NSMutableArray *removes = nil;
    for (NSLayoutConstraint *lc in self.constraints) {
        _dout_debug(@"%@ %@ %@ %f", lc, [lc.firstItem class], [lc.secondItem class], lc.multiplier)
        if ([lc.className hasPrefix:@"NSAutoresizingMask"]) continue;
        // 相对自己的约束需要满足

        UIView *firstItem = lc.firstItem;
        UIView *secondItem = lc.secondItem;
        BOOL firstIsControl = [self.controls containsObject:firstItem];
        BOOL secondIsControl = [self.controls containsObject:secondItem];

        if ((firstIsControl || secondIsControl)
            && !(firstItem == self && secondItem == self)) {
            // 需要移除的约束是至少有一个涉及控件且 firstItem 或 secondItem 只中有一个是自己
            if (!removes) {
                removes = [NSMutableArray arrayWithCapacity:20];
            }
            [removes addObject:lc];
        }
    }

    if (removes) {
        for (UIView *c in self.controls) {
            RFAssert(c.superview == self, @"%@ 管理的控件必需是其子 view", self.class);
            if (!c.translatesAutoresizingMaskIntoConstraints) {
                c.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
                c.translatesAutoresizingMaskIntoConstraints = YES;
            }
        }

        _douto(removes)
        [self removeConstraints:removes];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.stackLayoutView || !self.selfLayoutEnabled) return;
    if (CGRectEqualToRect(self.bounds, CGRectZero)) return;
    [self updateSelfLayout];
}

- (void)updateSelfLayout {
    UIEdgeInsets itemInset = self.itemInsets;
    CGFloat itemSpacing = self.itemSpacing;
    NSArray<UIView *> *controls = self.controls;

    CGRect contentFrame = UIEdgeInsetsInsetRect(self.bounds, itemInset);

    CGFloat x = CGRectGetMinX(contentFrame);
    CGFloat y = CGRectGetMinY(contentFrame);
    CGFloat itemHeight = contentFrame.size.height;

    for (UIView *v in controls) {
        CGFloat itemWidth = [v systemLayoutSizeFittingSize:contentFrame.size].width;
        if (itemWidth == UIViewNoIntrinsicMetric) {
            itemWidth = v.width;
        }
        CGRect frame = CGRectMake(x, y, itemWidth, itemHeight);
        v.frame = frame;
        _dout_rect(v.frame)
        x += itemWidth + itemSpacing;
    }

    CGFloat contentWidth = x - (controls.count? itemSpacing : 0) + itemInset.right;
    self.MBControlGroup_intrinsicContentWidth = contentWidth;
}

- (CGRect)_itemInsets {
    return [NSValue valueWithUIEdgeInsets:self.itemInsets].CGRectValue;
}
- (void)set_itemInsets:(CGRect)_itemInsets {
    self.itemInsets = [NSValue valueWithCGRect:_itemInsets].UIEdgeInsetsValue;
}

#pragma mark Content Size

- (void)setMBControlGroup_intrinsicContentWidth:(CGFloat)width {
    if (_MBControlGroup_intrinsicContentWidth != width) {
        _MBControlGroup_intrinsicContentWidth = width;
        [self invalidateIntrinsicContentSize];
    }
}

- (CGSize)intrinsicContentSize {
    if (self.stackLayoutView) {
        return self.stackLayoutView.intrinsicContentSize;
    }
    CGSize size = [super intrinsicContentSize];
    if (self.MBControlGroup_intrinsicContentWidth != UIViewNoIntrinsicMetric) {
        size.width = self.MBControlGroup_intrinsicContentWidth;
    }
    if (size.width == UIViewNoIntrinsicMetric) {
        size.width = self.width;
    }
//    if (size.height == UIViewNoIntrinsicMetric) {
//        size.height = self.height;
//    }
    return size;
}

@end
