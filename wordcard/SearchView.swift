//
//  SearchView.swift
//  wordcard
//
//  Created by ldd on 2022/9/11.
//

import SwiftUI



class ObservableWordDef: ObservableObject {
    @Published var wd: WordDef
    
    init(wd: WordDef = WordDef()) {
        self.wd = wd
    }
    
    func getDefFromCollins(word: String) {
        let w = word.trimmingCharacters(in: .whitespaces)
        let url = "http://pi.ldd.cool:1500/word/\(w)/def/from/collins"
        httpGet(url, WordDef.self) { defs in
            print("got senses from collins....")

            DispatchQueue.main.async {
                self.wd = defs
            }
        }
    }
    
    func getDefFromWebster(word: String) {
        let w = word.trimmingCharacters(in: .whitespaces)
        let url = "http://pi.ldd.cool:1500/word/\(w)/def/from/webster"
        httpGet(url, WordDef.self) { defs in
            DispatchQueue.main.async {
                self.wd = defs
            }
        }
    }
}

class ObservableImageList: ObservableObject {
    @Published var images: [String]
    
    init(images: [String]) {
        self.images = images
    }
    
    func getImages(word: String) {
        let w = word.trimmingCharacters(in: .whitespaces)
        let url = "http://pi.ldd.cool:1500/word/\(w)/images"
        print("try  to get images....from....\(url)....")
        httpGet(url, ImageList.self) { imgs in
            print(" got images ....")
            for i in imgs.data {
                print(i)
            }
            DispatchQueue.main.async {
                self.images = imgs.data
            }
        }
    }
}



struct SearchView: View {
    @State var word: String = ""
    @StateObject var collinsDef = ObservableWordDef()
    @StateObject var websterDef = ObservableWordDef()
    @StateObject var wrappedImages = ObservableImageList(images: [])
    
    var body: some View {
        VStack {
            TextField("input your word", text: $word)
                .keyboardType(.webSearch)
                .onSubmit{
                    websterDef.getDefFromWebster(word: word)
                    collinsDef.getDefFromCollins(word: word)
                    wrappedImages.getImages(word: word)
                }
                .textInputAutocapitalization(.never)
                .border(.secondary)
                .padding(.all)
            
            TabView {
                VStack {
                    if let senses = collinsDef.wd.senses {
                        List {
                            ForEach(senses, id: \.def) { sense in
                                if let def = sense.def {
                                    Text(def).font(.headline)
                                }
                                if let cits = sense.cits {
                                    ForEach(cits, id: \.quote) { cit in
                                        if let quote = cit.quote {
                                            Text("// \(quote)").font(.body)
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .tabItem {
                    Text("Collins")
                }
                
//                 Webster tab
                VStack {
                    if let senses = websterDef.wd.senses {
                        List {
                            ForEach(senses, id: \.def) { sense in
                                if let def = sense.def {
                                    Text(def).font(.headline)
                                }
                                if let cits = sense.cits {
                                    ForEach(cits, id: \.quote) { cit in
                                        if let quote = cit.quote {
                                            Text("// \(quote)").font(.body)
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .tabItem {
                    Text("Webster")
                }
                
                
                // Image tab
                VStack {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible())]) {
                            ForEach(wrappedImages.images, id: \.self) { imgUrl in
                                AsyncImage(url: URL(string: imgUrl)) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                    }
                }
                .tabItem {
                    Text("images")
                }
            }
        }
        .textSelection(.enabled)
        
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
