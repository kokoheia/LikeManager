//
//  SettingHeaderView.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/09/30.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit


class SettingHeaderView: UIView {
    
    // MARK: Subviews
    let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    //originaly set hidden
    let plusButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "plus"), for: .normal)
        button.isHidden = true
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
        addSubview(textLabel)
        textLabel.anchor(top: nil, left: leftAnchor, right: nil, bottom: bottomAnchor, paddingTop: nil, paddingLeft: 12, paddingRight: nil, paddingBottom: -10, width: nil, height: nil)
        
        addSubview(separatorView)
        separatorView.anchor(top: nil, left: leftAnchor, right: rightAnchor, bottom: bottomAnchor, paddingTop: nil, paddingLeft: 0, paddingRight: 0, paddingBottom: 1, width: nil, height: 1)
        
        addSubview(plusButton)
        plusButton.anchor(top: nil, left: nil, right: rightAnchor, bottom: bottomAnchor, paddingTop: nil, paddingLeft: nil, paddingRight: -80, paddingBottom: -10, width: 24, height: 24)
   
    }
    
}
