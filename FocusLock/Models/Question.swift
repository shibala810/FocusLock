//
//  Question.swift
//

import Foundation

struct Question: Codable, Identifiable, Hashable {
    let id: String
    let subject: Subject
    let grade: String
    let topic: String
    let question: String
    let options: [String]
    let answerIndex: Int
    let explanation: String

    init(id: String, subject: Subject, grade: String, topic: String,
         question: String, options: [String], answerIndex: Int, explanation: String = "") {
        self.id = id; self.subject = subject; self.grade = grade; self.topic = topic
        self.question = question; self.options = options; self.answerIndex = answerIndex
        self.explanation = explanation
    }
}
