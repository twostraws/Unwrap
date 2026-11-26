//
//  Lesson.swift
//  Unwrap
//

import Foundation

struct Lesson {
    let id: String
    let title: String
    let content: LessonContent
    let review: ReviewContent
    let videoURL: URL?

    init(
        title: String,
        bundle: Bundle = .main
    ) throws {
        let id = title.bundleName

        self.id = id
        self.title = title
        content = try bundle.decode(LessonContent.self, from: "\(id).json")
        review = try bundle.decode(ReviewContent.self, from: "\(id).json")
        videoURL = bundle.url(named: "\(id).mp4")
    }
}
