//
//  ViewController.swift
//  PlayingCard
//
//  Created by Julea Parkhomava on 2/23/21.
//

import UIKit

class ViewController: UIViewController {
    
    var deck = PlayingcardDeck()
    
    @IBOutlet var cardsView: [PlayingCardView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cards = [PlayingCard]()
        for _ in 0..<(cardsView.count + 1)/2 {
            if let card = deck.draw(){
                cards += [card, card]
            }
        }
        for card in cardsView{
            card.isFaceUp = false
            let randomCard = cards.remove(at: Int.random(in: cards.indices))
            card.rank = randomCard.rank.order
            card.suit = randomCard.suit.rawValue
            card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector (flipCard(_:))))
            cardBehavior.addItem(item: card)
        }
    }
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    lazy var cardBehavior = CardBehavior(animator: animator)
    
    private var faceUpCardsView: [PlayingCardView]{
        cardsView.filter{
            $0.isFaceUp && !$0.isHidden && $0.alpha == 1 && $0.transform != CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)}
    }
    
    private var faceUpCardsViewMatched: Bool{
        faceUpCardsView.count == 2 &&
            faceUpCardsView[0].suit == faceUpCardsView[1].suit &&
            faceUpCardsView[0].rank == faceUpCardsView[1].rank
    }
    
    @objc private func flipCard(_ recogniser: UITapGestureRecognizer){
        switch recogniser.state {
        case .ended:
            if let choosenCard = recogniser.view as? PlayingCardView, faceUpCardsView.count < 2{
                cardBehavior.removeItem(item: choosenCard)
                UIView.transition(
                    with: choosenCard,
                    duration: 3,
                    options: [.transitionFlipFromLeft],
                    animations: {choosenCard.isFaceUp = !choosenCard.isFaceUp},
                    completion: { [self] finished in
                        let cardsToAnimate = faceUpCardsView
                        if cardsToAnimate.count == 2{
                            if !faceUpCardsViewMatched{
                                cardsToAnimate.forEach{card in
                                    UIView.transition(
                                        with: card,
                                        duration: 3,
                                        options: [.transitionFlipFromLeft],
                                        animations: {card.isFaceUp = false},
                                        completion: {finished in
                                            cardBehavior.addItem(item: card)
                                        }
                                    )
                                }
                            }else{
                                UIViewPropertyAnimator.runningPropertyAnimator(
                                    withDuration: 3,
                                    delay: 0,
                                    options: [],
                                    animations: {
                                        cardsToAnimate.forEach{
                                            $0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
                                        }
                                    },
                                    completion: {position in
                                        UIViewPropertyAnimator.runningPropertyAnimator(
                                            withDuration: 3,
                                            delay: 0,
                                            options: [],
                                            animations: {
                                                cardsToAnimate.forEach{
                                                    $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                                    $0.alpha = 0
                                                }
                                            },
                                            completion: { position in
                                                cardsToAnimate.forEach{
                                                    $0.isHidden = true
                                                    $0.alpha = 1
                                                    $0.transform = CGAffineTransform.identity
                                                }
                                            }
                                        )
                                    }
                                )
                            }
                        }
                    }
                )
            }
        default:
            break
        }
    }
}





    /* LECTURE 6
 //IT WAS IN VIEWController
    @IBOutlet weak var playingCardView: PlayingCardView!{
        didSet{
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector (nextCard))
            swipe.direction = [.left, .right]
            playingCardView.addGestureRecognizer(swipe)
            let pinch = UIPinchGestureRecognizer(target: playingCardView, action: #selector (PlayingCardView.adjustFaceUadjustFaceCardScale(byHandlingGestureRecognizeBy:)))
            playingCardView.addGestureRecognizer(pinch)
        }
    }
    //добавление tapGesture через интерфейс
    @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
        switch sender.state{
        case .ended:
            playingCardView.isFaceUp = !playingCardView.isFaceUp
        default:
            break
        }
        
    }
    
    @objc private func nextCard(){
        if let card = deck.draw(){
            playingCardView.rank = card.rank.order
            playingCardView.suit = card.suit.rawValue
        }
    }
    
    var deck = PlayingcardDeck()
    
    override func viewDidLoad() {
        
    }
*/

