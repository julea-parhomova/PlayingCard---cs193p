//
//  CardBehavior.swift
//  PlayingCard
//
//  Created by Julea Parkhomava on 2/26/21.
//

import UIKit

class CardBehavior: UIDynamicBehavior {
    
    lazy var collisionBehavior: UICollisionBehavior = {
        var behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    lazy var itemViewBehavior: UIDynamicItemBehavior = {
       let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = false
        behavior.elasticity = 1
        behavior.resistance = 0
        return behavior
    }()
    
    private func addPush(item: UIView){
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
            let center = CGPoint(x: referenceBounds.midX, y: referenceBounds.midY)
            switch (item.center.x, item.center.y) {
            case let (x, y) where x < center.x && y < center.y:
                push.angle = CGFloat.random(in: 0...CGFloat.pi/2)
            case let (x, y) where x > center.x && y < center.y:
                push.angle = CGFloat.pi - CGFloat.random(in: 0...CGFloat.pi/2)
            case let (x, y) where x < center.x && y > center.y:
                push.angle = -CGFloat.random(in: 0...(CGFloat.pi/2))
            case let (x, y) where x > center.x && y > center.y:
                push.angle = CGFloat.pi+CGFloat.random(in: 0...(CGFloat.pi/2))
            default:
                push.angle = CGFloat.random(in: 0...(CGFloat.pi*2))
            }
        }
        push.magnitude = 1.0 + CGFloat.random(in: 0...2)
        //зачум нам здесь слабая ссылка на себя??
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemViewBehavior)
    }
    
    convenience init(animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
    
    func addItem(item: UIView) {
        collisionBehavior.addItem(item)
        itemViewBehavior.addItem(item)
        addPush(item: item)
    }
    
    func removeItem(item: UIView) {
        collisionBehavior.removeItem(item)
        itemViewBehavior.removeItem(item)
    }
}
