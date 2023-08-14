/// 弹出的分享菜单
class SharePanelViewController: MBModalPresentViewController {
    @objc var item: MBEntitySharing!

    @IBAction private func onTimeline(_ sender: Any) {
        guard MBShareManager.isWechatEnabled else {
            Current.hud.showErrorStatus("微信未安装")
            return
        }
        share(type: .wechatTimeline)
    }
    @IBAction private func onSession(_ sender: Any) {
        guard MBShareManager.isWechatEnabled else {
            Current.hud.showErrorStatus("微信未安装")
            return
        }
        share(type: .wechatSession)
    }
    @IBAction private func onQQ(_ sender: Any) {
        share(type: .qqSession)
    }
    @IBAction private func onWeibo(_ sender: Any) {
        share(type: .sinaWeibo)
    }

    func share(type: MBShareType) {
        item.shareLink?(with: type) { [weak self] success, _, error in
            let sf = self
            if success {
                Current.hud.showSuccessStatus("分享成功")
                sf?.dismissSelf(animated: true, completion: nil)
            }
            if let e = (error as NSError?) {
                Current.hud.alertError(e, title: "分享失败", fallbackMessage: nil)
            }
        }
    }
}
