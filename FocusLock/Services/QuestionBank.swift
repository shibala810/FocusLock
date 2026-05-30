//
//  QuestionBank.swift
//

import Foundation

@Observable
final class QuestionBank {
    private(set) var all: [Question] = []

    init() { load() }

    private func load() {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            all = QuestionBank.fallback()
            return
        }
        do {
            let wrapper = try JSONDecoder().decode(Wrapper.self, from: data)
            all = wrapper.questions
        } catch {
            all = QuestionBank.fallback()
        }
    }

    func draw(subjects: Set<Subject>, count n: Int) -> [Question] {
        let pool = all.filter { subjects.contains($0.subject) }
        let bag  = (pool.isEmpty ? all : pool).shuffled()
        return Array(bag.prefix(max(1, n)))
    }

    func counts() -> [Subject: Int] {
        var d: [Subject: Int] = [:]
        for q in all { d[q.subject, default: 0] += 1 }
        return d
    }

    private struct Wrapper: Decodable { let questions: [Question] }

    private static func fallback() -> [Question] {
        // Tiny safety net if JSON load fails.
        [
            Question(id: "fallback_1", subject: .math, grade: "高一", topic: "三角",
                     question: "sin 30° 的值為?",
                     options: ["1/2", "√3/2", "√2/2", "1"], answerIndex: 0,
                     explanation: "sin 30° = 1/2。"),
            Question(id: "fallback_2", subject: .english, grade: "高一", topic: "字彙",
                     question: "The opposite of \"generous\" is ____.",
                     options: ["kind", "stingy", "brave", "honest"], answerIndex: 1,
                     explanation: "generous 的反義為 stingy。"),
        ]
    }
}
