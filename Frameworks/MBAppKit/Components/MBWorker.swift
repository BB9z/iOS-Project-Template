/*
 MBWorker

 Copyright © 2018, 2023 BB9z.
 Copyright © 2016 Beijing ZhiYun ZhiYuan Technology Co., Ltd.
 https://github.com/RFUI/MBAppKit

 Apache License, Version 2.0
 http://www.apache.org/licenses/LICENSE-2.0
 */

import B9Debug

// Todo: 恢复 user 绑定逻辑

/**
 MBWorker 要在一个队列中依次执行
 */
final class MBWorkerQueue {
    init() {
    }

    /// work 执行线程，为空在主线程
    var dispatchQueue: DispatchQueue?

    /// 暂停/恢复队列，正在执行的 work 并不会因这个属性的变化终止或继续
    var suspended = false {
        didSet {
            if !suspended {
                tryEnqueue()
            }
        }
    }

    /// 当前执行中的 worker
    private(set) var executingWorker: MBWorker?

    /// 当前队列
    var currentWorkerQueue: [MBWorker] { workerQueue }

    private var workerQueue = [MBWorker]()

    /**
     @param worker 如果 worker 已加入队列，将抛出异常
     */
    func addWorker(_ worker: MBWorker?) {
        guard let worker = worker else { return }
        guard workerQueue.contains(where: { $0 === worker }) == false else {
            debugPrint("Cannot add the worker, already in queue.")
            return
        }
        if worker.requiresUserContext {
//            guard let user = MBUser.currentUser else {
//                debugPrint("未登入时尝试加入 \(worker.class)")
//                return
//            }
//            worker.userRequired = user
        }

        #if DEBUG
        worker.enqueueCallStack = Thread.callStackSymbols
        #endif

        worker.queue = self
        if worker.priority == .immediately {
            workerQueue.insert(worker, at: 0)
        } else if worker.priority == .idle {
            workerQueue.append(worker)
        } else {
            var idx = workerQueue.count
            for (index, w) in workerQueue.reversed().enumerated() {
                if w.priority != .idle {
                    break
                }
                idx = index
            }
            workerQueue.insert(worker, at: idx)
        }
        tryEnqueue()
    }

    fileprivate func _endWorker(_ worker: MBWorker) {
        guard executingWorker === worker else {
            debugPrint("尝试结束一个不在执行的任务")
            return
        }
        executingWorker = nil
        worker.queue = nil
        tryEnqueue()
    }

    func tryEnqueue() {
        if suspended { return }
        if executingWorker != nil { return }

        var next = popExecutableWorker()
        var workersToRemove: [MBWorker]?
        while let worker = next {
//            if worker.requiresUserContext && worker.userRequired !== MBUser.currentUser {
//                next = popExecutableWorker()
//                continue
//            }

            let skip = worker.shouldSkipExecution(withWorkersWillRemove: &workersToRemove)
            if let workersToRemove = workersToRemove {
                workerQueue.removeAll { workersToRemove.contains($0) }
            }
            if skip {
                next = popExecutableWorker()
            } else {
                break
            }
        }

        let queue = dispatchQueue ?? .main
        guard let work = next else {
            if !workerQueue.isEmpty {
                // 队列非空但没有满足当前条件的 worker，那只能过一会儿再看看了
                queue.asyncAfter(deadline: .now() + 3) { [weak self] in
                    self?.tryEnqueue()
                }
            }
            return
        }

        executingWorker = work

        queue.asyncAfter(deadline: .now() + work.enqueueDelay) { [weak self] in
            guard let self = self else { return }
            let workRef = next
            queue.asyncAfter(deadline: .now() + work.refrenceExecutionDuration) { [weak self] in
                guard let self = self else { return }
                guard let strongWorkRef = workRef else { return }
                if strongWorkRef !== self.executingWorker { return }


                self.executingWorker = nil
                self.tryEnqueue()
            }
            work.didExecution()
        }
    }

    fileprivate func checkTimeout(worker: MBWorker) {
        if executingWorker === worker {
            ThrowExceptionToPause()
            NSLog("⚠️ 仍在执行 %@，没有调用 finish？", worker)
            executingWorker = nil
            tryEnqueue()
        }
    }
    /**
     是否有类型相同的 worker 在队列中正在执行或排队中

     一般用于在 worker 中 shouldSkipExecutionWithWorkersWillRemove: 取消不必要的执行
     */
    func containsSameKindWorker(_ worker: MBWorker?) -> Bool {
        guard let worker = worker else { return true }
        let aClass = type(of: worker)
        if let executingWorker = executingWorker, executingWorker.isKind(of: aClass) {
            return true
        }
        for worker in workerQueue {
            if worker.isKind(of: aClass) {
                return true
            }
        }
        return false
    }

    // MARK: - Private

    private func popExecutableWorker() -> MBWorker? {
        guard !workerQueue.isEmpty else { return nil }

        var inBackground = false
        DispatchQueue.main.sync {
            inBackground = (UIApplication.shared.applicationState == .background)
        }

        for (index, item) in workerQueue.enumerated() {
            if inBackground && !item.allowsBackgroundExecution {
                continue
            }
            if let executeNoEarlierThan = item.executeNoEarlierThan, executeNoEarlierThan.timeIntervalSinceNow > 0 {
                continue
            }
            return workerQueue.remove(at: index)
        }

        return nil
    }
}

/**
 定义一个操作，放在队列中依次执行

 重写创建具体的 worker
 */
class MBWorker: NSObject, RFInitializing {
    override init() {
        super.init()
        onInit()
        DispatchQueue.main.async { [weak self] in
            self?.afterInit()
        }
    }

    func onInit() {

    }

    func afterInit() {

    }

    enum Priority {
        case normal
        /// 队列空闲才执行
        case idle
        /// 放到队列最前面，第一时间执行
        case immediately
    }

    /// 所在的队列，为空未加入队列
    fileprivate(set) weak var queue: MBWorkerQueue?

    /// 队列优先级
    var priority: Priority = .normal

    /// 操作可以在后台执行，默认操作只在前台执行
    var allowsBackgroundExecution = false

    /**
     标记操作需要用户登入

     置为 YES，当用户为登入时加入队列会直接抛弃。入队后会记住当前用户，
     执行时如果不是刚才的用户或已登出，直接会被抛弃掉
     */
    var requiresUserContext = false

    /// 自动设置
    fileprivate(set) var userRequired: MBUser?

    /// 队列轮到这个 worker 执行了，可以在执行实际操作前加一个延迟
    var enqueueDelay: TimeInterval = 0

    /// 设置操作的执行不应早于某个时间
    var executeNoEarlierThan: Date?

    /// 参考执行时间，超过执行时间队列可能跳过处理下一个任务
    var refrenceExecutionDuration: TimeInterval = 30

    /// 可选的完成回调，需要手工调用
    var completionBlock: (Result<Void, Error>)?

    #if DEBUG
    /// 把 worker 添加到队列时的调用堆栈
    var enqueueCallStack: [String]?
    #endif

    /**
     队列在执行 worker 前，会调用这个方法。
     worker 可以决定是否执行，并可以修改队列，达到操作合并、去重的目的。
     在调用该方法时，receiver 已经从队列中移除了。

     @warning 这个方法可能在各种线程上被调用，修改队列本身是线程安全的

     @param setRefrence 从队列中移除的操作
     @return YES 跳过当前操作的执行，NO 正常执行
     */
    func shouldSkipExecution(withWorkersWillRemove setRefrence: AutoreleasingUnsafeMutablePointer<[MBWorker]?>?) -> Bool {
        return false
    }

    /// 重写执行具体操作
    /// 除了业务操作外，要手工调用 finish 和 completionBlock
    func perform() {
        // for overwrite
    }

    /// 通知队列操作结束
    func finish() {
        executionTimeoutWatchdog = nil
        guard let queue = queue else {
            NSLog("⚠️ Canot end worker(%@) not in a queue.", self)
            return
        }
        queue._endWorker(self)
    }

    private var executionTimeoutWatchdog: DispatchWorkItem? {
        didSet {
            oldValue?.cancel()
        }
    }
    fileprivate func didExecution() {
        assert(queue != nil)
        if refrenceExecutionDuration > 0 {
            let timeoutChecker = DispatchWorkItem { [weak self] in
                guard let sf = self else { return }
                sf.queue?.checkTimeout(worker: sf)
            }
            executionTimeoutWatchdog = timeoutChecker
            (queue?.dispatchQueue ?? .main).asyncAfter(deadline: .now() + refrenceExecutionDuration, execute: timeoutChecker)
        }

        perform()
    }

    override var debugDescription: String {
        var text = "<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque())"
        if priority != .normal {
            if priority == .idle {
                text.append("; priority = idle")
            } else if priority == .immediately {
                text.append("; priority = immediately")
            }
        }
        if allowsBackgroundExecution {
            text.append("; allow background")
        }
//        if requiresUserContext {
//            text.append("; requires user: \(userRequired.uid)")
//        }
        if enqueueDelay > 0 {
            text.append("; enqueueDelay = \(enqueueDelay)")
        }
        if let date = executeNoEarlierThan {
            text.append("; executeNoEarlierThan = \(date)")
        }
        text.append(">")
        return text
    }
}
