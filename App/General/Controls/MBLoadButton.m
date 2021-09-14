
#import "MBLoadButton.h"
#import "RFKVOWrapper.h"

@interface MBLoadButton ()
@property (strong, nonatomic) id loadingObserver;
@property (readwrite, nonatomic) BOOL observing;
@property (weak, readwrite) id observeTarget;
@property (copy, readwrite) NSString *observeKeypath;
@property (copy, nonatomic) BOOL (^evaluateBlock)(id evaluatedVaule);
@end

@implementation MBLoadButton

- (void)onInit {
}

- (void)setupAppearance {
//    [self setImage:[UIImage animatedIndicator] forState:UIControlStateDisabled];
}

- (void)evaluateEnableStatus {
    id value = [self.observeTarget valueForKeyPath:self.observeKeypath];
    if (self.evaluateBlock) {
        self.enabled = !self.evaluateBlock(value);
    }
    else {
        self.enabled = ![value boolValue];
    }
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (!enabled) {
        self.selected = NO;
    }
    if (self.hidesWhenCompletion) {
        self.hidden = (enabled && !self.selected);
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (self.hidesWhenCompletion && selected) {
        self.hidden = NO;
    }
}

- (void)setLoadding:(BOOL)loadding {
    self.enabled = !loadding;
}

- (void)setSuccess:(BOOL)success {
    self.selected = !success;
}

- (void)observeTarget:(id)target forKeyPath:(NSString *)keypath evaluateBlock:(BOOL (^)(id evaluatedVaule))ifProcessingBlock {
    if (self.observing) {
        dout_warning(@"MBLoadButton already observing %@", self.observeTarget);
        return;
    }
    self.observing = YES;

    self.observeTarget = target;
    self.observeKeypath = keypath;
    self.evaluateBlock = ifProcessingBlock;

    self.loadingObserver = [target RFAddObserver:self forKeyPath:keypath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial queue:nil block:^(MBLoadButton *observer, NSDictionary *change) {
        [observer evaluateEnableStatus];
    }];
}

- (void)stopObserve {
    [self.observeTarget RFRemoveObserverWithIdentifier:self.loadingObserver];
    self.observing = NO;
    self.observeTarget = nil;
    self.observeKeypath = nil;
    self.evaluateBlock = nil;
}

@end
