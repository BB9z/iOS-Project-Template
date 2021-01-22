/**

 */
extension MBEnvironment {
    static func registerWorkers() {
        // 🔰 例子：在线、用户已登入且应用在前台时执行后台数据同步
//        MBEnvironment.staticObserve([.online, .userHasLogged, .appInForeground], selector: #selector(journeySync), handleOnce: false)
//        MBEnvironment.setAsApplicationDefault(AppEnv())
    }

//    @objc func journeySync() {
//        AppBackgroundWorkerQueue().add(JourneySyncWorker())
//    }
}
