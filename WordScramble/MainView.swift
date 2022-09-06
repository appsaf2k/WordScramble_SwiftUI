//
//  ContentView.swift
//  WordScramble
//
//  Created by @andreev2k on 01.09.2022.
//

import SwiftUI

struct MainView: View {
    @State private var useWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    // счет
    private var score: Int {
        var count = 0
        for word in useWords {
            count += word.count
        }
        return count
    }
    
    var body: some View {
        NavigationView {
                VStack {
                    HStack {
                        Spacer()
                        Button("Сбросить игру") { startGame() }
                    } .padding()
                    
                    Section {
                        TextField("введи слово", text: $newWord)
                            .autocapitalization(.none)
                    } .padding()
    
                    List {
                        ForEach(useWords, id: \.self) { word in
                                Label {
                                    Text(word)
                                } icon: {
                                    Image(systemName: "\(word.count).circle")
                                        .font(.title2)
                                        .foregroundColor(.secondary)
                            }
                        }
                    } .listStyle(.inset)
                    
                    Section {
                        HStack {
                            Text("Счет:  **\(score)**")
                                .font(.title3)
                        }
                    }
                }
                .navigationTitle(rootWord)
                .navigationBarTitleDisplayMode(.inline)
               // .onSubmit(addNewWord)
                .onSubmit {
                    addNewWord()
        
                }
                .onAppear(perform: startGame)
                .alert(errorTitle, isPresented: $showingError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
        }
    }
    
    // метод для записи слов
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        // дополнительная проверка
        guard isOriginal(word: answer) else {
            wordError(title: "Слово уже использовалось", message: "Будь оригинальнее!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Такое слово невозможно составить из '\(rootWord)'", message: "Придумай новое слово!")
            return
        }
        
        guard checkWord(word: answer) else {
            wordError(title: "В слове допущена ошибка", message: "Посмотри внимательнее на введенное слово!")
            return
        }
        
        guard shortWord(word: answer) else {
            wordError(title: "Слишком короткое слово", message: "Слово не должно состоять из 2х букв")
            return
        }
        
//
        withAnimation {
            useWords.insert(answer, at: 0)
        }
        newWord = ""
        
    }
    
    // загрузка слов при старте игры
    func startGame() {
        if let startWordUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordUrl) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "шелкопрядничество"
                useWords.removeAll()
                return
            }
        }
        fatalError("файл start.txt не может быть загружен")
    }
    
    // запрет ввода короткого слова
    func shortWord(word: String) -> Bool {
        if newWord.count < 3 || newWord == rootWord {
            return false
        }
        return true
    }
    
    // проверка на повторение слов
    func isOriginal(word: String) -> Bool {
        !useWords.contains(word)
    }
    
    // возможно ли использовать введенное слово
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    // проверка введенного слова на ошибки
    func checkWord(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "ru")
        
        return misspelledRange.location == NSNotFound
    }
    
    // отображение ошибки .alert()
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
