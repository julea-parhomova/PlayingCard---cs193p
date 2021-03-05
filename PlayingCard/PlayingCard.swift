//
//  PlayingCard.swift
//  PlayingCard
//
//  Created by Julea Parkhomava on 2/23/21.
//

import Foundation

struct PlayingCard: CustomStringConvertible{
    var description: String{
        "Card is \(suit) \(rank)"
    }
    
    var suit: Suit
    
    var rank: Rank

    enum Suit: String, CustomStringConvertible {
        var description: String{
            self.rawValue
        }
        
        case spades = "♠️"
        case hearts = "♥️"
        case diamonds = "♦️"
        case clubs = "♣️"
        
        static var all = [Suit.spades, .hearts, .diamonds, .clubs]
    }
    
    enum Rank: CustomStringConvertible{
        var description: String{
            switch self{
            case .ace:
                return "A"
            case .number(let pips):
                return String(pips)
            case .face(let kind):
                return kind
            }
        }
        
        case ace
        case face(String)
        case number(Int)
        
        var order: Int{
            switch self{
            case .ace:
                return 1
            case .number(let pips):
                return pips
            case .face(let kind) where kind == "J":
                return 11
            case .face(let kind) where kind == "Q":
                return 12
            case .face(let kind) where kind == "K":
                return 13
            default:
                return 0
            }
        }
        
        static var all: [Rank]{
            var allRank = [Rank.ace]
            for pips in 2...10{
                allRank.append(.number(pips))
            }
            allRank += [.face("J"), .face("Q"), .face("K")]
            return allRank
        }
    }
}
