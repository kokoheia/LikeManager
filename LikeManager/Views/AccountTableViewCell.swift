//
//  AccountTableViewCell.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/09/30.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell {
    
    // MARK: Subviews
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 17.5
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    let checkBox: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "check")
        return iv
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
        addSubview(profileImageView)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.anchor(top: nil, left: leftAnchor, right: nil, bottom: nil, paddingTop: nil, paddingLeft: 19, paddingRight: nil, paddingBottom: nil, width: 35, height: 35)
        
        addSubview(nameLabel)
        nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        nameLabel.anchor(top: nil, left: profileImageView.rightAnchor, right: nil, bottom: nil, paddingTop: nil, paddingLeft: 10, paddingRight: nil, paddingBottom: nil, width: nil, height: nil)
        
        addSubview(checkBox)
        checkBox.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        checkBox.anchor(top: nil, left: nil, right: rightAnchor, bottom: nil, paddingTop: nil, paddingLeft: nil, paddingRight: -83, paddingBottom: nil, width: 20, height: 20)
    }
    
    // MARK: Configure functions
    func configure(with user: User){
        if let profileImageURL = user.profileImageUrlString {
            self.profileImageView.loadProfileImage(with: profileImageURL)
        }
        if let userName = user.userName {
            self.nameLabel.text = userName
        }
    }
}
