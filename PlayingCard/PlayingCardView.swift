//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by Julea Parkhomava on 2/24/21.
//

import UIKit

@IBDesignable
class PlayingCardView: UIView {
   
    @IBInspectable
    var rank: Int = 12{
        didSet{
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    var suit: String = "♥️"{
        didSet{
            setNeedsDisplay()
            setNeedsLayout()
        }
    } //отображение сразу эмоджи
    
    @IBInspectable
    var isFaceUp: Bool = true{
        didSet{
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    private var faceCardScale = SizeRatio.faceCardImageSizeToBoundSize{
        didSet{
            setNeedsDisplay()
        }
    }
    
    @objc func adjustFaceUadjustFaceCardScale(byHandlingGestureRecognizeBy recognizer: UIPinchGestureRecognizer){
        switch recognizer.state {
        case .changed, .ended:
            faceCardScale *= recognizer.scale
            recognizer.scale = 1
        default:
            break
        }
    }

    private var rankString: String{
        switch rank {
        case 1: return "A"
        case 2...10: return String(rank)
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "?"
        }
    }
    
    private func centeredAttributedString(string: String, fontSize: CGFloat) -> NSAttributedString{
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle, .font: font])
    }
    
    //когда мы поменяли размер шрифта в настройках телфона
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    private var cornerString: NSAttributedString{
        centeredAttributedString(string: rankString+"\n"+suit, fontSize: cornerFontSize)
    }
    
    private func createCornerLabel() -> UILabel{
        let label = UILabel()
        label.numberOfLines = 0
        addSubview(label)
        return label
    }
    
    private lazy var upperLeftLabel = createCornerLabel()
    private lazy var lowerRightLabel = createCornerLabel()
    
    private func configureCornerLabel(_ label: UILabel) -> UILabel{
        label.attributedText = cornerString
        label.frame.size = CGSize.zero
        label.sizeToFit()
        label.isHidden = !isFaceUp
        return label
    }
    
    override func layoutSubviews() {
        //почему я могу убрать эту строчку и приложение работает?
        super.layoutSubviews()
        configureCornerLabel(upperLeftLabel)
        upperLeftLabel.frame.origin = bounds.origin.offsetBy(dx: cornerOffSet, dy: cornerOffSet)
        
        configureCornerLabel(lowerRightLabel)
        lowerRightLabel.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY).offsetBy(dx: -cornerOffSet-lowerRightLabel.frame.size.width, dy: -cornerOffSet-lowerRightLabel.frame.size.height)
        lowerRightLabel.transform = CGAffineTransform.identity.rotated(by: CGFloat.pi)
    }
    
    override func draw(_ rect: CGRect) {
        let roundedRectangle = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        UIColor.white.setFill()
        roundedRectangle.fill()
        
        if isFaceUp{
            if let image = UIImage(named: rankString+suit, in: Bundle(for: classForCoder), compatibleWith: traitCollection) {
                //почему изображенеи не выходит за пределы View?
                image.draw(in: bounds.zoom(by: faceCardScale))
            }else{
                drawPips()
            }
        }else{
            if let image = UIImage(named: "cardBack", in: Bundle(for: classForCoder), compatibleWith: traitCollection) {
                image.draw(in: bounds)
            }
        }
    }
    
    private func drawPips()
       {
           let pipsPerRowForRank = [[0],[1],[1,1],[1,1,1],[2,2],[2,1,2],[2,2,2],[2,1,2,2],[2,2,2,2],[2,2,1,2,2],[2,2,2,2,2]]
           
           func createPipString(thatFits pipRect: CGRect) -> NSAttributedString {
               let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.count, $0) })
               let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0) { max($1.max() ?? 0, $0) })
               let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
            let attemptedPipString = centeredAttributedString(string: suit, fontSize: verticalPipRowSpacing)
               let probablyOkayPipStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
            let probablyOkayPipString = centeredAttributedString(string: suit, fontSize: probablyOkayPipStringFontSize)
               if probablyOkayPipString.size().width > pipRect.size.width / maxHorizontalPipCount {
                return centeredAttributedString(string: suit, fontSize: probablyOkayPipStringFontSize / (probablyOkayPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
               } else {
                   return probablyOkayPipString
               }
           }
           
           if pipsPerRowForRank.indices.contains(rank) {
               let pipsPerRow = pipsPerRowForRank[rank]
               var pipRect = bounds.insetBy(dx: cornerOffSet, dy: cornerOffSet).insetBy(dx: cornerString.size().width, dy: cornerString.size().height / 2)
               let pipString = createPipString(thatFits: pipRect)
               let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
               pipRect.size.height = pipString.size().height
               pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
               for pipCount in pipsPerRow {
                   switch pipCount {
                   case 1:
                       pipString.draw(in: pipRect)
                   case 2:
                    pipString.draw(in: pipRect.leftHalf)
                       pipString.draw(in: pipRect.rightHalf)
                   default:
                       break
                   }
                   pipRect.origin.y += pipRowSpacing
               }
           }
       }
    
    private struct SizeRatio{
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static let cornerRadiousToBoundsHeight: CGFloat = 0.06
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let faceCardImageSizeToBoundSize: CGFloat = 0.75
        
    }
    private var cornerRadius: CGFloat{
        bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
    private var cornerOffSet: CGFloat{
        cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    private var cornerFontSize: CGFloat{
        bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
}

extension CGRect{
    var leftHalf: CGRect{
        CGRect(x: minX, y: minY, width: self.width/2, height: height)
    }
    
    var rightHalf: CGRect {
        CGRect(x: midX, y: minY, width: width/2, height: height)
    }
    
    func inset(by size:CGSize) -> CGRect {
        insetBy(dx: size.width, dy: height)
    }
    
    func size(to size: CGSize) -> CGRect {
        CGRect(origin: origin, size: size)
    }
    
    func zoom(by scale: CGFloat) -> CGRect{
        let newSize = (width: width * scale, height: height * scale)
        //почему мы делим на 2?
        return insetBy(dx: (width-newSize.width)/2, dy: (height-newSize.height)/2)
    }
}

extension CGPoint{
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint{
        CGPoint(x: x + dx, y: y + dy)
    }
}
