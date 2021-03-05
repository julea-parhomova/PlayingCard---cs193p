//
//  PlayingCardDeck.swift
//  PlayingCard
//
//  Created by Julea Parkhomava on 2/23/21.
//

import Foundation

struct PlayingcardDeck{
    private(set) var cards: [PlayingCard]
    
    init(){
        var allCards = [PlayingCard]()
        for suite in PlayingCard.Suit.all{
            for rank in PlayingCard.Rank.all{
                allCards.append(PlayingCard(suit: suite, rank: rank))
            }
        }
        cards = allCards
    }
    
    mutating func draw() -> PlayingCard?{
        if cards.count > 0{
            return cards.remove(at: Int.random(in: 0..<cards.count))
        }
        return nil
    }
    
}
