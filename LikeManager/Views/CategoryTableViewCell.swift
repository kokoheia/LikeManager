//
//  CategoryTableViewCell.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/09/16.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit

final class CategoryTableViewCell: UITableViewCell {
    // MARK: Subviews
    private lazy var badgeView: UIView = {
        let centerY = frame.height / 2
        let rect = CGRect(x: 0, y: 0, width: 16, height: 16)
        let circleView = UIView(frame: rect)
        circleView.translatesAutoresizingMaskIntoConstraints = false
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(ovalIn: rect).cgPath
        circleView.layer.mask = mask
        return circleView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Inits
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup functions
    private func setupViews() {
        selectionStyle = .none
        addSubview(badgeView)
        badgeView.leftAnchor.constraint(equalTo: leftAnchor, constant: 23).isActive = true
        badgeView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        badgeView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        badgeView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        addSubview(titleLabel)
        titleLabel.leftAnchor.constraint(equalTo: badgeView.rightAnchor, constant: 19).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(separator)
        separator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        separator.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
    }
    
    // MARK: Configure functions
    func configure(with category: Category) {
        let text = category.title
        let attributes: [NSAttributedStringKey: Any] = [
            .font : UIFont.systemFont(ofSize: 28, weight: .medium)
        ]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        self.titleLabel.attributedText = attributedText
        
        let color: UIColor = UIColor.convert(name: category.colorName)
        badgeView.backgroundColor = color
    }

    
}
