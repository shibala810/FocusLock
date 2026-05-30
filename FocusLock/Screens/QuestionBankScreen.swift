//
//  QuestionBankScreen.swift — browse + import the question bank
//

import SwiftUI
import UniformTypeIdentifiers

struct QuestionBankScreen: View {
    @Environment(AppState.self) private var app
    @Environment(\.fl) private var fl

    @State private var selectedSubject: Subject? = nil
    @State private var showImporter = false
    @State private var importError: String? = nil

    var body: some View {
        let counts = app.bank.counts()
        let questions = filteredQuestions()
        let total = app.bank.all.count

        FLScreen {
            PawField()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    TopBar(title: "題庫", sub: "瀏覽 / 匯入",
                           onBack: { app.route = .main })

                    VStack(spacing: 18) {
                        heroCard(total: total)
                        subjectFilter(counts: counts)

                        VStack(spacing: 12) {
                            ForEach(questions) { q in
                                questionCard(q)
                            }
                        }

                        Button { showImporter = true } label: {
                            HStack(spacing: 8) {
                                LineIcon(name: .plus, size: 18, color: fl.onPrimary)
                                Text("匯入 JSON 題庫")
                            }
                        }
                        .buttonStyle(FLCTAStyle())

                        Text("檔案格式參考 Resources/questions.json")
                            .font(.system(size: 11.5))
                            .foregroundStyle(fl.inkFaint)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
        }
        .fileImporter(isPresented: $showImporter,
                      allowedContentTypes: [.json],
                      allowsMultipleSelection: false) { result in
            handleImport(result)
        }
        .alert("匯入失敗", isPresented: Binding(
            get: { importError != nil },
            set: { if !$0 { importError = nil } }
        )) {
            Button("好", role: .cancel) { importError = nil }
        } message: {
            Text(importError ?? "")
        }
    }

    // MARK: Sections

    @ViewBuilder
    private func heroCard(total: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(LinearGradient(colors: [fl.primary, fl.primaryDeep],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
            VStack(alignment: .leading, spacing: 0) {
                Text("已收錄")
                    .font(.system(size: 13, weight: .heavy))
                    .tracking(2)
                    .foregroundStyle(Color.white.opacity(0.8))
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(total)")
                        .font(.system(size: 46, weight: .heavy).monospacedDigit())
                    Text("題")
                        .font(.system(size: 22, weight: .heavy))
                }
                .foregroundStyle(.white)
                .padding(.top, 2)
                Text("解鎖時會從你勾選的科目隨機抽")
                    .font(.system(size: 12.5))
                    .foregroundStyle(Color.white.opacity(0.85))
                    .padding(.top, 8)
            }
            .padding(20)

            LineIcon(name: .book, size: 84, color: Color.white.opacity(0.18))
                .offset(x: -10, y: -4)
        }
    }

    @ViewBuilder
    private func subjectFilter(counts: [Subject: Int]) -> some View {
        HStack(spacing: 8) {
            chip(label: "全部", count: counts.values.reduce(0, +),
                 isOn: selectedSubject == nil, color: fl.primary,
                 onTap: { selectedSubject = nil })
            ForEach(Subject.allCases) { s in
                chip(label: s.rawValue, count: counts[s] ?? 0,
                     isOn: selectedSubject == s, color: s.color,
                     onTap: { selectedSubject = (selectedSubject == s) ? nil : s })
            }
        }
    }

    @ViewBuilder
    private func chip(label: String, count: Int, isOn: Bool, color: Color,
                      onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(label)
                Text("\(count)")
                    .font(.system(size: 11, weight: .heavy).monospacedDigit())
                    .opacity(0.7)
            }
            .font(.system(size: 13, weight: .heavy))
            .foregroundStyle(isOn ? Color.white : fl.ink)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Capsule().fill(isOn ? color : fl.surface))
            .modifier(AnyShadow(.small(fl)))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func questionCard(_ q: Question) -> some View {
        FLCard(cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    SubjectIcon(subject: q.subject, size: 32)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("\(q.subject.rawValue)・\(q.topic)")
                            .font(.system(size: 14, weight: .heavy))
                        Text(q.grade)
                            .font(.system(size: 11.5))
                            .foregroundStyle(fl.inkSoft)
                    }
                    Spacer()
                    if q.id.hasPrefix("custom_") {
                        Text("自訂")
                            .font(.system(size: 10.5, weight: .heavy))
                            .foregroundStyle(fl.amber)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Capsule().fill(fl.amberSoft))
                    }
                }
                Text(q.question)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(fl.ink)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                VStack(spacing: 6) {
                    ForEach(q.options.indices, id: \.self) { i in
                        let ok = (i == q.answerIndex)
                        HStack(spacing: 9) {
                            Text(["A","B","C","D"][i])
                                .font(.system(size: 11, weight: .heavy))
                                .foregroundStyle(ok ? fl.focus : fl.inkFaint)
                                .frame(width: 20, height: 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(ok ? fl.focusSoft : fl.surface3))
                            Text(q.options[i])
                                .font(.system(size: 13.5, weight: ok ? .heavy : .regular))
                                .foregroundStyle(ok ? fl.focus : fl.inkSoft)
                            Spacer(minLength: 4)
                            if ok {
                                LineIcon(name: .check, size: 14, color: fl.focus)
                            }
                        }
                    }
                }
                if !q.explanation.isEmpty {
                    HStack(alignment: .top, spacing: 6) {
                        LineIcon(name: .info, size: 14, color: fl.primaryDeep)
                        Text(q.explanation)
                            .font(.system(size: 12))
                            .foregroundStyle(fl.inkSoft)
                            .lineSpacing(3)
                    }
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(fl.surface2))
                }
            }
            .padding(16)
        }
    }

    // MARK: Filtering

    private func filteredQuestions() -> [Question] {
        guard let s = selectedSubject else { return app.bank.all }
        return app.bank.all.filter { $0.subject == s }
    }

    // MARK: Import

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .failure(let err):
            importError = err.localizedDescription
        case .success(let urls):
            guard let url = urls.first else { return }
            let didStart = url.startAccessingSecurityScopedResource()
            defer { if didStart { url.stopAccessingSecurityScopedResource() } }
            do {
                let data = try Data(contentsOf: url)
                let added = try app.bank.importJSON(data)
                if added == 0 {
                    importError = "檔案讀取成功,但沒有有效題目。請確認 JSON 結構符合 { \"questions\": [...] }。"
                }
            } catch {
                importError = "讀取失敗:\(error.localizedDescription)"
            }
        }
    }
}
