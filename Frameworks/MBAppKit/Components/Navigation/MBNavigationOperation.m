
#import "MBNavigationOperation.h"
#import "MBNavigationController.h"


@implementation MBNavigationOperation
RFInitializingRootForNSObject

- (void)onInit {
}

- (void)afterInit {
}

- (NSString *)debugDescription {
    NSMutableString *des = [NSMutableString stringWithFormat:@"<%@: %p; ", self.class, (void *)self];
    NSString *subDes = self.subClassPropertyDescription;
    if (subDes) {
        [des appendString:subDes];
    }
    [des appendFormat:@"; %@ = %@; %@ = %@>",
     @keypath(self, animating), self.animating? @"YES" : @"NO",
     @keypath(self, topViewControllers), self.topViewControllers];
    return des;
}

+ (instancetype)operationWithConfiguration:(NS_NOESCAPE void (^)(__kindof MBNavigationOperation * _Nonnull))configBlock {
    MBNavigationOperation *ins = self.new;
    configBlock(ins);
    if (![ins validateConfiguration]) {
        return nil;
    }
    return ins;
}

- (BOOL)validateConfiguration {
    return YES;
}

- (NSString *)subClassPropertyDescription {
    return nil;
}

- (BOOL)perform:(MBNavigationController *)controller {
    if (self.performBlock) {
        return self.performBlock(self, controller);
    }
    return NO;
}

@end

@implementation MBPopNavigationOperation

- (BOOL)perform:(MBNavigationController *)controller {
    [controller popViewControllerAnimated:self.animating];
    return YES;
}

@end

@implementation MBAlertNavigationOperation

- (BOOL)validateConfiguration {
    if (!super.validateConfiguration) return NO;
    if (!self.alertController) return NO;
    return YES;
}

- (NSString *)subClassPropertyDescription {
    return [NSString stringWithFormat:@"alert = %@", self.alertController];
}

- (BOOL)perform:(MBNavigationController *)controller {
    [controller presentViewController:self.alertController animated:self.animating completion:nil];
    return YES;
}

@end
