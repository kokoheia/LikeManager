//
//  TextInputTableViewCell.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/09/17.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit

class TextInputTableViewCell: UITableViewCell {
    
    // MARK: Subviews
    let textInput: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Category name"
        return tf
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
        addSubview(textInput)
        textInput.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, bottom: bottomAnchor, paddingTop: 0, paddingLeft: 23, paddingRight: 0, paddingBottom: 0, width: nil, height: nil)
        
        addSubview(separator)
        separator.anchor(top: nil, left: leftAnchor, right: rightAnchor, bottom: bottomAnchor, paddingTop: nil, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: nil, height: 0.5)
    }
    
    // MARK: Configure functions
    func configure(with category: Category) {
        self.textInput.placeholder = category.title
    }

}
