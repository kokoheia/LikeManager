//
//  AddCategoryTableViewCell.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/09/16.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit

class AddCategoryTableViewCell: UITableViewCell {
    
    // MARK: Subviews
    let plusView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "plus")
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let attributes: [NSAttributedStringKey: Any] = [
            .font : UIFont.systemFont(ofSize: 28, weight: .medium)
        ]
        let attributedText = NSAttributedString(string: "Add Other", attributes: attributes)
        label.attributedText = attributedText
        return label
    }()
    
    let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
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

        addSubview(plusView)
        plusView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        plusView.anchor(top: nil, left: leftAnchor, right: nil, bottom: nil, paddingTop: nil, paddingLeft: 20, paddingRight: nil, paddingBottom: nil, width: 23, height: 23)
        
        addSubview(titleLabel)
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLabel.anchor(top: nil, left: plusView.rightAnchor, right: nil, bottom: nil, paddingTop: nil, paddingLeft: 17, paddingRight: nil, paddingBottom: nil, width: nil, height: nil)
        
        addSubview(separator)
        separator.anchor(top: nil, left: leftAnchor, right: rightAnchor, bottom: bottomAnchor, paddingTop: nil, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: nil, height: 0.5)
        
    }
    
    
    
}
