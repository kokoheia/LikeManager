//
//  CategoryCollectionViewCell.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/09/22.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    // MARK: Subviews
    let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
        return label
    }()
    
    // MARK: Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 5.5
        self.layer.masksToBounds = true
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup function
    private func setupViews() {
        addSubview(textLabel)
        textLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        textLabel.anchor(top: topAnchor, left: nil, right: nil, bottom: bottomAnchor, paddingTop: 0, paddingLeft: nil, paddingRight: nil, paddingBottom: 0, width: nil, height: nil)
    }
    
    // MARK: Configure function
    func configure(category: Category) {
        let color = UIColor.convert(name: category.colorName)
        self.backgroundColor = color
        self.textLabel.text = category.title
    }
 
}
