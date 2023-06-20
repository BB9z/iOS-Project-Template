
#import "MBWorker.h"
#import "MBWorkerQueue.h"
#import "shadow.h"
#import "MBUser.h"

@interface MBWorkerQueue (/* Private */)
- (void)_endWorker:(MBWorker *)worker;
@end

@interface MBWorker ()

@end

@implementation MBWorker
RFInitializingRootForNSObject

- (void)onInit {

}

- (void)afterInit {
    // Nothing
}

- (NSString *)debugDescription {
    NSMutableString *text = [NSMutableString stringWithFormat:@"<%@: %@p", self.class, (void *)self];
    if (self.priority != MBWorkerPriorityNormal) {
        if (self.priority == MBWorkerPriorityIdle) {
            [text appendString:@"; priority = idle"];
        }
        else if (self.priority == MBWorkerPriorityImmediately) {
            [text appendString:@"; priority = immediately"];
        }
    }
    if (self.allowsBackgroundExecution) {
        [text appendString:@"; allow background"];
    }
    if (self.requiresUserContext) {
        [text appendFormat:@"; requires user: %@", self.userRequired.uid];
    }
    if (self.enqueueDelay) {
        [text appendFormat:@"; enqueueDelay = %f", self.enqueueDelay];
    }
    if (self.executeNoEarlierThan) {
        [text appendFormat:@"; executeNoEarlierThan = %@", self.executeNoEarlierThan];
    }
    [text appendString:@">"];
    return text;
}

- (BOOL)shouldSkipExecutionWithWorkersWillRemove:(NSArray<MBWorker *> *__autoreleasing  _Nullable *)setRefrence {
    return NO;
}

- (void)perform {
    // for overwrite
}

- (void)finish {
    if (!self.queue) {
        DebugLog(NO, nil, @"Canot end worker(%@) not in a queue.", self);
    }
    [self.queue _endWorker:self];
}

- (void)_setQueue:(MBWorkerQueue *)queue {
    _queue = queue;
}

@end
