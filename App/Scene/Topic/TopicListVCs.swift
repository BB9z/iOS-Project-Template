//
//  TopicListVCs.swift
//  App
//

/**
 推荐帖子列表
 */
class TopicRecommandListController: MBTableListController {
    override class func storyboardName() -> String { "Topic" }
}

#if PREVIEW
import SwiftUI
struct TopicRecommandListPreview: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            TopicRecommandListController.newFromStoryboard()
        }
    }
}
#endif
