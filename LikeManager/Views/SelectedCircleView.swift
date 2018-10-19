//
//  SelectedCircleView.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/09/17.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit

final class SelectedCircleView: UIView {

    // MARK: Properties
    var color: UIColor = .orange {
        didSet {
            setNeedsDisplay()
        }
    }
    private var percent: CGFloat = 0.8
    private var lineWidth: CGFloat?
    
    // MARK: Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(color: UIColor, sizePercentage: CGFloat) {
        self.init()
        self.backgroundColor = .white
        self.color = color
        self.percent = sizePercentage
    }
    
    // MARK: Draw function
    override func draw(_ rect: CGRect) {
        let centerX = (rect.minX + rect.maxX) / 2
        let centerY = (rect.minY + rect.maxY) / 2
        let outerWidth = rect.width*percent
        let outerHeight = rect.height*percent
        
        let outerOriginX = centerX - outerWidth / 2
        let outerOriginY = centerY - outerHeight / 2
        
        let outerRect = CGRect(x: outerOriginX, y: outerOriginY, width: outerWidth, height: outerHeight)
        let outerCirclePath = UIBezierPath(ovalIn: outerRect)
        
        let innerWidth = rect.width*percent / 2
        let innerHeight = rect.height*percent / 2
        
        let innerOriginX = centerX - innerWidth / 2
        let innerOriginY = centerY - innerHeight / 2
        
        let innerRect = CGRect(x: innerOriginX, y: innerOriginY, width: innerWidth, height: innerHeight)
        let innerCirclePath = UIBezierPath(ovalIn: innerRect)

        color.setStroke()
        outerCirclePath.stroke()

        color.setFill()
        innerCirclePath.fill()
    }

}
