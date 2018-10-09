//
//  ColorCollectionViewCell.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/09/17.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties
    var isChosen = true
    override var isSelected: Bool {
        didSet {
            subviews.forEach {$0.removeFromSuperview() }
            setupViews()
        }
    }
    var color = UIColor.orange {
        didSet {
            if isSelected {
                selectedCircle.color = color
            } else {
                circle.fillColor = color
                circle.strokeColor = color
            }
        }
    }
    
    // MARK: Subviews
    lazy var circle: CircleView = {
        let circle = CircleView(strokeColor: color, fillColor: color, lineWidth: 1, sizePercentage: 0.8)
        circle.backgroundColor = .white
        return circle
    }()
    
    lazy var selectedCircle: SelectedCircleView = {
        let selectedCircle = SelectedCircleView(color: color, sizePercentage: 0.8)
        return selectedCircle
    }()
    
    // MARK: Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup functions
    private func setupViews() {
        let eitherCircle = !isSelected ? circle : selectedCircle
        addSubview(eitherCircle)
        eitherCircle.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, bottom: bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: nil, height: nil)
    }
}
