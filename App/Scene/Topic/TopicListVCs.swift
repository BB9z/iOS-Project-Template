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

import Debugger
extension TopicRecommendListController: DebugActionSource {
    func debugActionItems() -> [DebugActionItem] {
        [DebugActionItem("zz", action: nil)]
    }
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
