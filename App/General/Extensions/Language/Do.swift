/*
 Do.swift

 Copyright © 2021 BB9z.
 https://github.com/BB9z/iOS-Project-Template

 The MIT License
 https://opensource.org/licenses/MIT
 */

enum Do { // swiftlint:disable:this type_name
    static func `try`<T>(_ action: () throws -> T) -> T? {
        do {
            return try action()
        } catch {
            AppLog().critical("\(error)")
            return nil
        }
    }

    static func tryOptional<T>(_ action: () throws -> T?) -> T? {
        do {
            return try action()
        } catch {
            AppLog().critical("\(error)")
            return nil
        }
    }

    static func handle<Success, Failure, Return>(_ result: Result<Success, Failure>, action: (Success) -> Return) -> Return? {
        switch result {
        case .success(let obj):
            return action(obj)
        case .failure(let error):
            AppLog().error("\(error)")
            return nil
        }
    }

    enum FailureStrategy {
        case log
        case hud(_ title: String?)
    }

    /// Result 处理，成功自定义，失败用标准的处理
    static func handler<Success>(fail: FailureStrategy, success: ((Success) -> Void)?) -> (Result<Success, Error>) -> Void {
        { result in
            switch result {
            case .success(let obj):
                success?(obj)
            case .failure(let e):
                switch fail {
                case .log:
                    AppLog().error("\(e)")
                case .hud(let title):
                    AppHUD().showErrorStatus(String.join(title, e.localizedDescription, separator: ": "))
                }
            }
        }
    }

    /**
     将传入的可选 Result 回调转为一个在主线程执行的回调，并可在执行前插入其他操作
     */
    static func safe<S, F>(callback: ((Result<S, F>) -> Void)?, addition: (() -> Void)? = nil) -> ((Result<S, F>) -> Void) {
        { result in
            if addition == nil, callback == nil { return }
            DispatchQueue.main.async {
                addition?()
                callback?(result)
            }
        }
    }
}
