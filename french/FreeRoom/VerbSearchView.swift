//
//  VerbSearchView.swift
//  french
//
//  Created by Anton on 29/06/2025.
//

import SwiftUI

struct VerbSearchView: View {
    let verbName: String  // Глагол передается извне
    @State private var verb: VerbConjugation?  // Найденный глагол с его спряжениями
    @State private var isLoading = false  // Флаг загрузки данных
    @State private var errorMessage: String?  // Сообщение об ошибке
    
    @State private var selectedTabIndicatif = 2
    @State private var selectedTabSubjonctif = 1
    
    var body: some View {
        VStack {
            // Основной контент
            if isLoading {
                ProgressView()  // Индикатор загрузки
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else if let verb = verb {
                VerticalSwipeView(pagesCount: 6) {
                    VerticalPage(id: 0) {
                        TabView(selection: $selectedTabIndicatif) {
                            IndicatifPasseSimpleView(verb: verb)
                                .tag(0)
                            
                            IndicatifImparfaitView(verb: verb)
                                .tag(1)
                            
                            IndicatifPasseComposeView(verb: verb)
                                .tag(2)
                            
                            IndicatifPresentView(verb: verb)
                                .tag(3)
                            
                            IndicatifFuturProcheView(verbName: verbName)
                                .tag(4)
                            
                            IndicatifFuturView(verb: verb)
                                .tag(5)
                        }
                        .onAppear {
                            selectedTabIndicatif = 3 // Убедимся, что при появлении выбрана Present вкладка
                        }
                        .frame(height: 700)
                        .tabViewStyle(.page)
                        .tabViewStyle(PageTabViewStyle())
                        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    }
                    
                    VerticalPage(id: 1) {
                        ConditionnelPresentView(verb: verb)
                    }
                    
                    VerticalPage(id: 2) {
                        TabView(selection: $selectedTabSubjonctif) {
                            SubjonctifImparfaitView(verb: verb)
                                .tag(0)
                            SubjonctifPresentView(verb: verb)
                                .tag(1)
                        }
                        .onAppear {
                            selectedTabSubjonctif = 1
                        }
                        .frame(height: 700)
                        .tabViewStyle(.page)
                        .tabViewStyle(PageTabViewStyle())
                        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    }
                    
                    VerticalPage(id: 3) {
                        ImperatifView(verb: verb)
                    }
                }
                .ignoresSafeArea()
            }
        }
        .onAppear {
            loadVerbConjugations()  // Загружаем данные при появлении View
        }
    }
    
    private func loadVerbConjugations() {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let verbID = DatabaseManager.shared.searchVerb(verbName) {
                let forms = DatabaseManager.shared.fetchConjugations(for: verbID)
                let groupedVerb = groupFormsIntoVerb(forms)
                
                DispatchQueue.main.async {
                    self.verb = groupedVerb
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Глагол '\(verbName)' не найден"
                    self.isLoading = false
                }
            }
        }
    }
    
    
    // Группировка отдельных форм спряжения в структурированные данные
    private func groupFormsIntoVerb(_ forms: [ConjugationForm]) -> VerbConjugation {
        // Фильтруем формы, оставляя только те, где род не указан (nil) или указан как мужской (masculine)
        let filteredForms = forms
        
        // Группируем отфильтрованные формы по наклонениям
        let moods = Dictionary(grouping: filteredForms) { $0.mood }
        
        // Для каждого наклонения создаем структуру
        let moodGroups = moods.map { moodName, forms in
            // Группируем формы по временам
            let tenses = Dictionary(grouping: forms) { $0.tense }
            
            // Для каждого времени создаем структуру
            let tenseGroups = tenses.map { tenseName, forms in
                TenseConjugation(
                    name: tenseName,
                    forms: forms.sorted { $0.person < $1.person } // Сортируем формы по лицам
                )
            }
            
            // Сортируем времена в правильном порядке
            let sortedTenses = tenseGroups.sorted {
                tenseOrder($0.name) < tenseOrder($1.name)
            }
            
            return MoodConjugation(
                name: moodName,
                tenses: sortedTenses
            )
        }
        
        // Сортируем наклонения в правильном порядке
        let sortedMoods = moodGroups.sorted {
            moodOrder($0.name) < moodOrder($1.name)
        }
        
        return VerbConjugation(moods: sortedMoods)
    }
    
    // Порядок наклонений для сортировки
    private func moodOrder(_ mood: String) -> Int {
        ["Indicatif", "Conditionnel", "Subjonctif", "Impératif", "Participe"].firstIndex(of: mood) ?? 5
    }
    
    // Порядок времен для сортировки
    private func tenseOrder(_ tense: String) -> Int {
        ["Passé composé", "Imparfait", "Plus-que-parfait", "Passé simple", "Passé antérieur", "Futur antérieur", "Présent", "Futur simple", "Passé"].firstIndex(of: tense) ?? 10
    }
    
    // Получение подписи для лица по индексу
    private func personLabel(for index: Int) -> String {
        ["je", "tu", "il/elle", "nous", "vous", "ils/elles"][index]
    }
}
