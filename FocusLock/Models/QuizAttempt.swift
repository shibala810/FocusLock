//
//  QuizAttempt.swift — single answered question, used to compute subject mastery
//

import Foundation

struct QuizAttempt: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    var attemptedAt: Date
    var questionId: String
    var subject: Subject
    var correct: Bool
}
