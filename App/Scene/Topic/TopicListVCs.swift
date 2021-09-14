//
//  TopicListVCs.swift
//  App
//

/**
 推荐帖子列表
 */
class TopicRecommendListController: MBTableListController, StoryboardCreation {
    static var storyboardID: StoryboardID { .topic }
}

#if PREVIEW
import SwiftUI
struct TopicRecommendListPreview: PreviewProvider {
    static var previews: some View {
        ViewControllerPreview {
            TopicRecommendListController.newFromStoryboard()
        }
    }
}
#endif
