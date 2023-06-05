//
//  CardView.swift
//  wordcard
//
//  Created by ldd on 2022/9/8.
//

import SwiftUI

struct CardView: View {
    let word: Word
    let index: Int
    let count: Int
    
    @Environment(\.colorScheme) private var colorScheme
    
    
    var cardBackgroundColor: Color {
        let light = Color(red: 0.949, green: 0.949, blue: 0.949)
        let dark = Color(red: 0.067, green: 0.067, blue: 0.067)
        return colorScheme == .light ? light : dark
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(cardBackgroundColor)
            VStack {
                HStack {
                    Text(word.literal).font(.largeTitle)
                    Button(action: {
                        word.pronounce()
                    }, label: {
                        Image(systemName: "mouth.fill").padding(.top, 10.0)
                    })
                }
                if let note = word.note {
                    Text(note).font(.body)
                }
                TabView {
                    // Webster tab
                    VStack {
                        if let senses = word.defFromWebster?.senses {
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
                    .tabItem {
                        Text("Webster")
                    }
                    
                    // collins tab
                    VStack {
                        if let senses = word.defFromCollins?.senses {
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
                    .tabItem {
                        Text("Collins")
                    }
                    
                    
                    // Image tab
                    VStack {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible())]) {
                                if let imageUrls = word.imageUrls  {
                                    ForEach(imageUrls, id: \.self) { imgUrl in
                                        AsyncImage(url: URL(string: imgUrl)) { image in
                                            image.resizable().scaledToFit()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .tabItem {
                        Text("images")
                    }
                }
                
                Spacer()
                HStack {
                    Text("\(index)/\(count)").padding(.bottom)
                }
            }
            .foregroundColor(.brown)
        }
        .padding(.horizontal, 20.0)
        .padding(.vertical)
    }
}



struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(word: Word.sampleWords[0], index: 0, count: 10)
    }
}
