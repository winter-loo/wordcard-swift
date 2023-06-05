//
//  CardListDemo.swift
//  wordcard
//
//  Created by ldd on 2022/9/9.
//

import SwiftUI


struct CardListDemo: View {
    @StateObject var cardSwipeModel = CardSwipeModel(offsetToSide: 360, totalCards: 26)
    
    var body: some View {
        ZStack {
            ForEach(cardSwipeModel.cards) { c in
                if cardSwipeModel.isVisible(at: c.id) {
                    // single card view
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.brown)
                            .padding(.vertical)
                            .padding(.horizontal, 20)
                        VStack {
                            Text("Card \(c.label)").font(.headline)
                            Text("data \(cardSwipeModel.dataIndex)").font(.body)
                        }
                    }
                    .onAppear {
                        print("card \(c.label) appears")
                    }
                    .onDisappear {
                        print("card \(c.label) disappears")
                    }
                    .offset(x: c.offset)
                    .gesture(DragGesture()
                        .onChanged { ges in
                            let offset = ges.translation.width
                            // print("card \(c.id) on change: \(offset)")
                            withAnimation {
                                cardSwipeModel.onSwipe(offset: offset)
                            }
                        }
                        .onEnded { ges in
                            let offset = ges.translation.width
                            // FIXME: .onEnded won't be called when put the second finger on the current card
                            // print("card \(c.id) on end: \(offset)")
                            withAnimation {
                                if offset  < -50 {
                                    cardSwipeModel.didLeftSwipe()
                                } else if offset > 50 {
                                    cardSwipeModel.didRightSwipe()
                                } else {
                                    cardSwipeModel.cancelSwipe()
                                }
                            }
                        }
                    )
                }
            }
        }
    }
}

struct bar_Previews: PreviewProvider {
    static var previews: some View {
        CardListDemo()
    }
}
