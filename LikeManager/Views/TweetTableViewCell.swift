//
//  TweetTableViewCell.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/09/16.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit
import TwitterKit

class TweetTableViewCell: UITableViewCell, TWTRTweetViewDelegate {
    
    // MARK: Subviews
    lazy var tweetView: TWTRTweetView = {
        let view = TWTRTweetView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.isUserInteractionEnabled = false
        return view
    }()
    
    // MARK: init functions
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
        addSubview(tweetView)
        tweetView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        tweetView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        tweetView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tweetView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
