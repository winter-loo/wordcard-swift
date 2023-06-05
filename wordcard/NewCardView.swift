//
//  NewCardView.swift
//  wordcard
//
//  Created by ldd on 2022/10/1.
//

import SwiftUI


struct NewCardView: View {
    @StateObject var word = Word("")
    @State var prevWord = ""
    @State var visible: [Bool] = [ false, false, false ]
    @FocusState private var focusWord: Bool
    @FocusState private var focusNote: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    var cardBackgroundColor: Color {
        let light = Color(red: 0.949, green: 0.949, blue: 0.949)
        let dark = Color(red: 0.067, green: 0.067, blue: 0.067)
        return colorScheme == .light ? light : dark
    }
    
    func setVisible(_ index: Int) {
        for i in visible.indices {
            if i == index {
                visible[i] = true
            } else {
                visible[i] = false
            }
        }
    }
    
    struct TabViewButtonLikeStyle: PrimitiveButtonStyle {
        var selected: Bool
        
        init(_ selected: Bool) {
            self.selected = selected
        }
        
        func makeBody(configuration: Configuration) -> some View {
            if self.selected {
                Button(action: {configuration.trigger()}) {
                    configuration.label
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button(action: {configuration.trigger()}) {
                    configuration.label
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    
    init() {
        // workaround to set TextEditor background
        UITextView.appearance().backgroundColor = .clear
        UIListContentView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(cardBackgroundColor)
            VStack {
                TextField("input your word", text: $word.literal)
                    .onSubmit {
                        print("your word is \(word.literal)")
                        focusNote = true
                    }
                    .submitLabel(.next)
                    .textInputAutocapitalization(.never)
                    .font(.largeTitle)
                    .padding(.leading, 6)
                    .focused($focusWord)
                
                // TextEditor with placeholder
                ZStack(alignment: .leading)  {
                    if word.note.isEmpty {
                        VStack {
                            Text("take some notes here...")
                                .font(.title)
                                .padding(.leading, 6)
                                .opacity(0.30)
                            Spacer()
                        }
                    }
                    TextEditor(text: $word.note)
                        .lineLimit(5)
                        .opacity(word.note.isEmpty ? 0.85 : 1)
                        .focused($focusNote)
                }
                
                
                // suggestions
                VStack(alignment: .leading) {
                    Text("suggested from...").font(.caption)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                                Button("Merriam Webster") {
                                    visible[0].toggle()
                                    focusWord = false
                                    focusNote = false
                                    
                                    if visible[0] {
                                        setVisible(0)
                                        if prevWord != word.literal {
                                            prevWord = word.literal
                                            word.resetResources()
                                        }
                                        if word.defFromWebster == nil {
                                            word.getDefFromWebster()
                                        }
                                    }
                                }
                                .buttonStyle(TabViewButtonLikeStyle(visible[0]))
                            
                                Button("Collins") {
                                    visible[1].toggle()
                                    focusWord = false
                                    focusNote = false
                                    
                                    if visible[1] {
                                        setVisible(1)
                                        if prevWord != word.literal {
                                            prevWord = word.literal
                                            word.resetResources()
                                        }
                                        if word.defFromCollins == nil {
                                            word.getDefFromCollins()
                                        }
                                    }
                                }
                                .buttonStyle(TabViewButtonLikeStyle(visible[1]))
                            
                                Button("Image") {
                                    visible[2].toggle()
                                    focusWord = false
                                    focusNote = false
                                    
                                    if visible[2] {
                                        setVisible(2)
                                        if prevWord != word.literal {
                                            prevWord = word.literal
                                            word.resetResources()
                                        }
                                        if word.imageUrls == nil {
                                            word.getImages()
                                        }
                                    }
                                }
                                .buttonStyle(TabViewButtonLikeStyle(visible[2]))
                        }
                    }
                }
                
                if let senses = word.defFromWebster?.senses, visible[0] {
                    showSenses(senses)
                }
                
                if let senses = word.defFromCollins?.senses, visible[1] {
                    showSenses(senses)
                }
                
                if let imageUrls = word.imageUrls, visible[2] {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: [GridItem(.fixed(UIScreen.main.bounds.width * 0.6))]) {
                            ForEach(imageUrls, id: \.self) { imgUrl in
                                AsyncImage(url: URL(string: imgUrl)) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: UIScreen.main.bounds.width * 0.6)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20.0)
        .padding(.vertical)
        .onAppear {
            focusWord = true
        }
    }
    
    func showSenses(_ senses: [Sense]) -> some View {
        List {
            ForEach(senses, id: \.def) { sense in
                if let def = sense.def {
                    Text(def).font(.headline).textSelection(.enabled)
                        .listRowBackground(cardBackgroundColor)
                }
                if let cits = sense.cits {
                    ForEach(cits, id: \.quote) { cit in
                        if let quote = cit.quote {
                            Text("// \(quote)").font(.body).textSelection(.enabled)
                                .listRowBackground(cardBackgroundColor)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

struct NewCardView_Previews: PreviewProvider {
    static var previews: some View {
        NewCardView()
    }
}
