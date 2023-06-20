
#import "MBWorkerQueue.h"
#import "shadow.h"
#import "MBUser.h"

@interface MBWorker (/* Private */)
- (void)_setQueue:(MBWorkerQueue *)queue;
@end

@interface MBWorkerQueue ()
@property (readonly) NSMutableArray<MBWorker *> *workerQueue;
@end

@implementation MBWorkerQueue
RFInitializingRootForNSObject

- (void)onInit {
    _workerQueue = [NSMutableArray array];
}

- (void)afterInit {
    // Nothing
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, executing: %@, queued: %@>",
            self.class, (void *)self,
            self.executingWorker.class,
            [self.workerQueue valueForKeyPath:@"class"]
            ];
}

- (NSArray<MBWorker *> *)currentWorkerQueue {
    return [self.workerQueue copy];
}

- (void)addWorker:(MBWorker *)worker {
    @synchronized(self) {
        if (!worker) return;
        if (!RFAssertKindOfClass(worker, [MBWorker class])) {
            return;
        }
        if (worker.queue) {
            RFAssert(false, @"Cannot add the worker, already in queue.");
            return;
        }
        if (worker.requiresUserContext) {
            MBUser *user = MBUser.currentUser;
            if (!user) {
                DebugLog(NO, nil, @"未登入时尝试加入 %@", worker.class);
                return;
            }
            worker.userRequired = user;
        }

#if DEBUG
        if ([worker respondsToSelector:@selector(setEnqueueCallStack:)]) {
            // 这里 respondsToSelector 检查的必要性在于源文件和头文件编译环境可能不一样
            worker.enqueueCallStack = [NSThread callStackSymbols];
        }
#endif
        [worker _setQueue:self];
        NSMutableArray<MBWorker *> *wq = self.workerQueue;
        // 队列平时就是按照优先级排列的
        if (worker.priority == MBWorkerPriorityImmediately) {
            [wq insertObject:worker atIndex:0];
        }
        else if (worker.priority == MBWorkerPriorityIdle) {
            // 空闲总是插入到末尾
            [wq addObject:worker];
        }
        else {
            NSInteger idx = wq.count;
            // 从后往前找到第一个不是 idle 的 worker 插到它的后面
            for (MBWorker *w in wq.reverseObjectEnumerator) {
                if (w.priority != MBWorkerPriorityIdle) {
                    break;
                }
                idx--;
            }
            [wq insertObject:worker atIndex:idx];
        }
        [self tryEnqueue];
    }

}

- (void)_endWorker:(MBWorker *)worker {
    @synchronized(self) {
        if (_executingWorker != worker) {
            DebugLog(NO, @"MBWorkerQueueEndWorkNotExecuting", @"尝试结束一个不在执行的任务");
            return;
        }
        _executingWorker = nil;
        [worker _setQueue:nil];
        [self tryEnqueue];
    }
}

- (void)setSuspended:(BOOL)suspended {
    @synchronized(self) {
        _suspended = suspended;
        if (!suspended) {
            [self tryEnqueue];
        }
    }
}

- (void)tryEnqueue {
    if (self.suspended) return;
    if (_executingWorker) return;

    MBWorker *w = [self popExecutableWorker];
    NSArray *workersToRemove = nil;
    while (w) {
        if (w.requiresUserContext
            && w.userRequired != MBUser.currentUser) {
            w = [self popExecutableWorker];
            continue;
        }

        BOOL skip = [w shouldSkipExecutionWithWorkersWillRemove:&workersToRemove];
        if (workersToRemove) {
            [self.workerQueue removeObjectsInArray:workersToRemove];
        }
        if (skip) {
            w = [self popExecutableWorker];
        }
        else {
            break;
        }
    }

    if (!w) {
        if (self.workerQueue.count) {
            // 队列非空但没有满足当前条件的 worker，那只能过一会儿再看看了
            @weakify(self);
            dispatch_after_seconds(3, ^{
                @strongify(self);
                [self tryEnqueue];
            });
        }
        return;
    }
    _executingWorker = w;
    @weakify(self);
    dispatch_queue_t dq = self.dispatchQueue?: dispatch_get_main_queue();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(w.enqueueDelay * NSEC_PER_SEC)), dq, ^{
        // 执行超时检测
        __weak MBWorker *workRef = w;
        dispatch_after_seconds(w.refrenceExecutionDuration?: 30, ^{
            @strongify(self);
            __strong MBWorker *strongWorkRef = workRef;
            if (!strongWorkRef
                || strongWorkRef != self.executingWorker) return;

            DebugLog(NO, @"MBWorkerQueueTimeOut", @"仍在执行 %@，没有调用 finish？", strongWorkRef);

            // 执行下一个
            self->_executingWorker = nil;
            [self tryEnqueue];
        });
        [w perform];
    });
}

- (nullable MBWorker *)popExecutableWorker {
    NSMutableArray<MBWorker *> *queue = self.workerQueue;
    if (!queue.count) return nil;

    MBWorker *w = nil;
    __block BOOL inBackground = NO;
    dispatch_sync_on_main(^{
        inBackground = (UIApplication.sharedApplication.applicationState == UIApplicationStateBackground);
    });

    for (MBWorker *item in queue) {
        // 遍历队列直到找到一个符合执行条件的
        // 看到不符合条件的直接下一个
        if (inBackground
            && !item.allowsBackgroundExecution) {
            continue;
        }
        if (item.executeNoEarlierThan
            && [item.executeNoEarlierThan timeIntervalSinceNow] > 0) {
            continue;
        }

        w = item;
        break;
    }

    if (w) {
        [queue removeObject:w];
    }
    return w;
}

- (BOOL)containsSameKindWorker:(MBWorker *)worker {
    if (!worker) return YES;
    Class aClass = worker.class;
    if ([_executingWorker isKindOfClass:aClass]) return YES;
    for (MBWorker *worker in self.workerQueue) {
        if ([worker isKindOfClass:aClass]) return YES;
    }
    return NO;
}

@end
