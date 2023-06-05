//
//  CardSwiper.swift
//  wordcard
//
//  Created by ldd on 2022/9/8.
//

import SwiftUI

struct CardSwiper: View {
    @State var words: [Word] = Word.sampleWords
    @State var isAddingWord = false
    @State var closeBook = false
    @State var newWord = Word("")
    @State var newWordDescription: String = ""
    @State var currentIndex = 0
    @State var cardWidth: CGFloat = 0
    
    @StateObject var swipeModel = CardSwipeModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if isAddingWord {
                    NewCardView()
                } else {
                    ZStack {
                        ForEach(swipeModel.cards) { card in
                            if swipeModel.isVisible(at: card.id) {
                                let idx = swipeModel.dataIndex(for: card.id)!
                                CardView(word: words[idx], index: 1 + idx, count: words.count)
                                    .offset(x: card.offset)
                                    .gesture(DragGesture()
                                        .onChanged { ges in
                                            let offset = ges.translation.width
                                            // print("card \(c.id) on change: \(offset)")
                                            withAnimation {
                                                swipeModel.onSwipe(offset: offset)
                                            }
                                        }
                                        .onEnded { ges in
                                            let offset = ges.translation.width
                                            // FIXME: .onEnded won't be called when put the second finger on the current card
                                            // print("card \(c.id) on end: \(offset)")
                                            withAnimation {
                                                if offset  < -50 {
                                                    swipeModel.didLeftSwipe()
                                                } else if offset > 50 {
                                                    swipeModel.didRightSwipe()
                                                } else {
                                                    swipeModel.cancelSwipe()
                                                }
                                            }
                                        }
                                    )
                            } // end if isVisible
                        }
                    }
                    .onAppear {
                        swipeModel.setup(offsetToSide: 360, totalCards: words.count)
                    }
                    .onChange(of: words.count) { swipeModel.update(totalCards: $0) }
                }
            }
            .navigationTitle(isAddingWord ? "add new word" : "anykeeper")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        if isAddingWord {
                            Button(action:  {
                                isAddingWord = false
                                // save word now
                            }) {
                                Image(systemName: "checkmark.circle")
                            }
                        } else {
                            Button(action: {
                                isAddingWord = true
                            }) {
                                Image(systemName: "plus.circle")
                            }
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: {
                            if isAddingWord {
                                isAddingWord = false
                            } else {
                                closeBook = true
                            }
                        }) {
                            Image(systemName: "xmark.circle")
                        }
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var swipeModel = CardSwipeModel(offsetToSide: 360, totalCards: 7)
    static var previews: some View {
        CardSwiper()
    }
}
