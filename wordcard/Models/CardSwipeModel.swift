//
//  CardSwipeModel.swift
//  wordcard
//
//  Created by ldd on 2022/9/10.
//

import Foundation
import SwiftUI

class CardSwipeModel: ObservableObject {
    var offsetToSide: CGFloat
    var totalCards: Int
    var dataIndex: Int = 0
            
    struct Card: Identifiable {
        var id: Int
        
        var offset: CGFloat = 0
        var anchorOffset: CGFloat = 0
        var label: String = ""
        
        init(_ id: Int, offset: CGFloat = 0, anchorOffset: CGFloat = 0, label: String = "") {
            self.id = id
            self.offset = offset
            self.anchorOffset = anchorOffset
            self.label = label
        }
    }
    @Published var cards: [Card] = []
    
    init() {
        self.offsetToSide = 360
        self.totalCards =  0
    }
    
    func setup(offsetToSide: CGFloat, totalCards: Int) {
        self.offsetToSide = offsetToSide
        self.totalCards = totalCards
        
        if totalCards < 1 { return }
        
        cards.append(Card(0, offset: 0, anchorOffset: 0, label: String(1)))
        if totalCards > 1 {
            cards.append(Card(1, offset: offsetToSide, anchorOffset: offsetToSide, label: String(2)))
            let remainingCardCount = min(totalCards, 5) - 2
            for i in 0..<remainingCardCount {
                cards.append(Card(i+2, label: String(i+3)))
            }
        }
        // print("\(cards.count) cards has been initialized...")
    }
    
    init(offsetToSide: CGFloat, totalCards: Int) {
        self.offsetToSide = offsetToSide
        self.totalCards = totalCards
        setup(offsetToSide: offsetToSide, totalCards: totalCards)
    }
    
    func onSwipe(offset: CGFloat) {
        if let prevCardIndex = prevCardIndex() {
            cards[prevCardIndex].offset = cards[prevCardIndex].anchorOffset + offset
        }
        
        let currentCardIndex = cardIndex()
        cards[currentCardIndex].offset = cards[currentCardIndex].anchorOffset + offset
        
        if let nextCardIndex = nextCardIndex() {
            cards[nextCardIndex].offset = cards[nextCardIndex].anchorOffset + offset
        }
    }
    
    func didLeftSwipe() {
        if !hasNextCard() {
            cancelSwipe()
            return
        }
        dataIndex += 1
        
        setCardOffset()
    }
    
    func didRightSwipe() {
        if !hasPrevCard() {
            cancelSwipe()
            return
        }
        dataIndex -= 1
        
        setCardOffset()
    }
    
    func setCardOffset() {
        if let prevCardIndex = prevCardIndex() {
            cards[prevCardIndex].offset = -offsetToSide
            cards[prevCardIndex].anchorOffset = -offsetToSide
        }
        
        let currentCardIndex = cardIndex()
        cards[currentCardIndex].offset = 0
        cards[currentCardIndex].anchorOffset = 0
        
        if let nextCardIndex = nextCardIndex() {
            cards[nextCardIndex].offset = offsetToSide
            cards[nextCardIndex].anchorOffset = offsetToSide
        }
    }
    
    func cancelSwipe() {
        if let prevCardIndex = prevCardIndex() {
            cancelSwipe(at: prevCardIndex)
        }
        
        let currentCardIndex = cardIndex()
        cancelSwipe(at: currentCardIndex)
        
        if let nextCardIndex = nextCardIndex() {
            cancelSwipe(at: nextCardIndex)
        }
    }
    
    func cancelSwipe(at index: Int) {
        cards[index].offset = cards[index].anchorOffset
    }
    
    func isVisible(at index: Int) -> Bool {
        cardIndex() == index || prevCardIndex() == index || nextCardIndex() == index
    }
    
    func cardIndex() -> Int {
        dataIndex % cards.count
    }
    
    func prevCardIndex() -> Int? {
        hasPrevCard() ? (dataIndex - 1) % cards.count : nil
    }
    
    func nextCardIndex() -> Int? {
        hasNextCard() ? (dataIndex + 1) % cards.count : nil
    }
    
    func hasNextCard() -> Bool {
        dataIndex >= 0 && dataIndex + 1 < totalCards
    }
    
    func hasPrevCard() -> Bool {
        dataIndex > 0 && dataIndex < totalCards
    }
    
    func dataIndex(for index: Int) -> Int? {
        if index == prevCardIndex() {
            return dataIndex - 1
        } else if index == cardIndex() {
            return dataIndex
        } else if index == nextCardIndex() {
            return dataIndex + 1
        }
        return nil
    }
    
    func update(totalCards: Int) {
        let oldTotal = self.totalCards
        self.totalCards = totalCards
        if totalCards <= 5 {
            let count = cards.count
            let remainingCardCount = self.totalCards - count
            for i in 0..<remainingCardCount {
                cards.append(Card(i+count, label: String(i+1+count)))
            }
        }
        dataIndex = oldTotal
        setCardOffset()
    }
}
