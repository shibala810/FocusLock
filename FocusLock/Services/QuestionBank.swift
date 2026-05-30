//
//  QuestionBank.swift
//

import Foundation

@Observable
final class QuestionBank {
    private(set) var bundled: [Question] = []
    private(set) var custom:  [Question] = []

    /// All questions: bundled first, then any imported ones. The unlock
    /// flow uses this for random draw, the bank screen lists it.
    var all: [Question] { bundled + custom }

    private let customKey = "customQuestions"

    init() {
        loadBundled()
        loadCustom()
    }

    // MARK: Loading

    private func loadBundled() {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            bundled = QuestionBank.fallback()
            return
        }
        do {
            let wrapper = try JSONDecoder().decode(Wrapper.self, from: data)
            bundled = wrapper.questions
        } catch {
            bundled = QuestionBank.fallback()
        }
    }

    private func loadCustom() {
        guard let data = UserDefaults.standard.data(forKey: customKey),
              let arr = try? JSONDecoder().decode([Question].self, from: data)
        else { return }
        custom = arr
    }

    private func persistCustom() {
        guard let data = try? JSONEncoder().encode(custom) else { return }
        UserDefaults.standard.set(data, forKey: customKey)
    }

    // MARK: API

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

    /// Parse a JSON blob ({ "questions": [...] }), prefix imported IDs with
    /// "custom_" so they're distinguishable in the UI, and append to the
    /// custom store. Returns the number of questions actually added.
    @discardableResult
    func importJSON(_ data: Data) throws -> Int {
        let wrapper = try JSONDecoder().decode(Wrapper.self, from: data)
        let existing = Set(all.map(\.id))
        var added = 0
        for q in wrapper.questions {
            let id = q.id.hasPrefix("custom_") ? q.id : "custom_\(q.id)"
            guard !existing.contains(id) else { continue }
            let renamed = Question(
                id: id, subject: q.subject, grade: q.grade, topic: q.topic,
                question: q.question, options: q.options,
                answerIndex: q.answerIndex, explanation: q.explanation)
            custom.append(renamed)
            added += 1
        }
        if added > 0 { persistCustom() }
        return added
    }

    /// Remove every imported question.
    func clearCustom() {
        custom.removeAll()
        persistCustom()
    }

    private struct Wrapper: Decodable { let questions: [Question] }

    private static func fallback() -> [Question] {
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
