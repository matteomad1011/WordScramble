//
//  ContentView.swift
//  WordScramble
//
//  Created by Matteo Cavallo on 28/06/21.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {

        NavigationView{
            Form{
                Section(footer: Text("You must make as many as possible permutations of this word.")){
                        Text(rootWord)
                            .font(.headline)
                }
                TextField("Enter you word", text: $newWord, onCommit: addNewWord )
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .disableAutocorrection(true)
                if(usedWords.count > 0){
                    Section(header: Text("Your words")){
                        Text("\(score) points")
                            .font(.headline)
                        List(usedWords, id: \.self){
                            Image(systemName: "\($0.count).square")
                            Text($0)
                        }
                    }
                }
            }
            .alert(isPresented: $showingAlert, content: {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            })
            .navigationTitle("Scrambless")
            .onAppear(perform: startGame)
            .navigationBarItems(trailing: Button("Reload"){
                startGame()
            })
        }
    }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't guess them up.")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word does not exist!", message: "Try with a real one.")
            return
        }
        
        score +=  Int(pow(2, Double(answer.count)))
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func startGame(){
        usedWords = []
        newWord = ""
        score = 0
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkwarm"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String){
        alertTitle = title
        alertMessage = message
        showingAlert = true
        newWord = ""
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
