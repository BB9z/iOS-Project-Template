
/*:
 [目录](TOC) | [Previous](@previous) | [Next](@next)
 */

import PlaygroundSupport

class TagItem: TagViewElement {
    var title: String

    init(title: String) {
        self.title = title
    }
}

PlaygroundPage.current.liveView = {
    let tagview = TagView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    tagview.backgroundColor = nil
    tagview.isOpaque = false
    tagview.items =         [
        TagItem(title: "title 01"),
        TagItem(title: "title very very very very very very very long"),
        TagItem(title: "t"),
        TagItem(title: "title 04"),
    ]
    return tagview
}()
