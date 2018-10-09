//
//  CircleView.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/09/17.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit

class CircleView: UIView {
    
    // MARK: Properties
    var strokeColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    var fillColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    var percent: CGFloat = 0.8
    var lineWidth: CGFloat?
    
    // MARK: Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(strokeColor: UIColor?, fillColor: UIColor?, lineWidth: CGFloat?, sizePercentage: CGFloat) {
        self.init()
        if let strokeColor = strokeColor {
            self.strokeColor = strokeColor
        }
        if let fillColor = fillColor {
            self.fillColor = fillColor
        }
        
        if let lineWidth = lineWidth {
            self.lineWidth = lineWidth
        }
        self.percent = sizePercentage
    }
    
    // MARK: Draw function
    override func draw(_ rect: CGRect) {
        let centerX = (rect.minX + rect.maxX) / 2
        let centerY = (rect.minY + rect.maxY) / 2
        let width = rect.width*percent
        let height = rect.height*percent
        
        let originX = centerX - width / 2
        let originY = centerY - height / 2
        
        let innerRect = CGRect(x: originX, y: originY, width: width, height: height)
        let circlePath = UIBezierPath(ovalIn: innerRect)
        strokeColor?.setStroke()
        fillColor?.setFill()
        
        if let lineWidth = lineWidth {
            circlePath.lineWidth = lineWidth
        }
        circlePath.stroke()
        circlePath.fill()
    }

}
