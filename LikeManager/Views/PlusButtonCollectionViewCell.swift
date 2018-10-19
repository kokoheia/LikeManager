//
//  PlusButtonCollectionViewCell.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/09/22.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit

final class PlusButtonCollectionViewCell: UICollectionViewCell {
    
    // MARK: Subviews
    let plusButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "plus-white")
        button.layer.cornerRadius = 13.5
        button.backgroundColor = UIColor.init(r: 216, g: 216, b: 216)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.masksToBounds = true
        return button
    }()
    
    // MARK: Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup functions
    private func setupViews() {
        addSubview(plusButton)
        plusButton.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, bottom: bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: nil, height: nil)
    }
}
