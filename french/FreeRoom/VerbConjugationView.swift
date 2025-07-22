//
//  VerbConjugationView.swift
//  french
//
//  Created by Anton on 01/07/2025.
//

import SwiftUI

// View для отображения спряжений конкретного времени
struct VerbConjugationView: View {
    let mood: MoodConjugation
    let tense: TenseConjugation
    let imageName: String?
    
    var body: some View {
        VStack(spacing: 16) { // Увеличиваем spacing между элементами
            // Заголовок с наклонением
            Text(mood.name.capitalized)
                .font(.title.bold()) // Увеличиваем размер шрифта
                .padding(.top, 12)
            
            // Название времени
            Text(tense.name.capitalized)
                .font(.title3.bold()) // Увеличиваем размер шрифта
                .foregroundColor(.secondary)
            
            if imageName != nil {
                Image(imageName!)
                    .scaledToFit()
            }
            
            // Список форм спряжения
            let order = [0, 1, 2, 3, 4, 5]
            let uniqueForms = Dictionary(grouping: tense.forms, by: { $0.person })
                .compactMapValues { $0.first }
                .map { (person: $0.key, form: removeFeminineSuffix(from: $0.value.form)) }
                .sorted { lhs, rhs in
                    order.firstIndex(of: lhs.person)! < order.firstIndex(of: rhs.person)!
                }
            VStack(alignment: .leading, spacing: 16) { // Увеличиваем spacing
                ForEach(uniqueForms, id: \.person) { form in
                    HStack(alignment: .top) {
                        Text(personLabel(for: form.person))
                            .frame(width: 100, alignment: .leading) // Увеличиваем ширину для лиц
                            .font(.body.bold())
                        
                        Text(form.form)
                            .font(.body)
                            .lineLimit(nil) // Разрешаем перенос текста
                            .fixedSize(horizontal: false, vertical: true) // Разрешаем расширение по вертикали
                    }
                }
            }
            .padding(.horizontal, 20) // Увеличиваем горизонтальные отступы
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)  // Занимаем всю доступную ширину
        .frame(maxHeight: .infinity)
    }
    
    private func personLabel(for index: Int) -> String {
        ["je", "tu", "il", "nous", "vous", "ils"][index]
    }
    
    private func removeFeminineSuffix(from form: String) -> String {
        if form.hasSuffix("") && !form.hasSuffix("") {
            return String(form.dropLast())
        } else if form.hasSuffix("e ") {
            return String(form.dropLast(2)) + " "
        }
        return form.replacingOccurrences(of: "ée", with: "é")
    }
}
