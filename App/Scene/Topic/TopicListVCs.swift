//
//  TopicListVCs.swift
//  App
//

/**
 推荐帖子列表
 */
class TopicRecommandListController: MBTableListController, StroryboardCreation {
    static var storyboardID: StoryboardID { .topic }
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
