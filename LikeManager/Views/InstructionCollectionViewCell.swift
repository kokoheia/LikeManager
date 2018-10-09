//
//  InstructionCollectionViewCell.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/10/04.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit
import TwitterKit

class InstructionCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties
    let cellID = "cellID"
    let cellIDForCategoryView = "cellIDForCategoryView"
    var currentIndex: Int?
    var categories =  [Category]()
    
    // MARK: Subviews
    lazy var pageIndicatorView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 7
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        cv.delegate = self
        cv.dataSource = self
        cv.tag = 0
        return cv
    }()
    
    let mainTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "tags")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let tweetView: TWTRTweetView = {
        let view = TWTRTweetView()
        return view
    }()
    
    lazy var categoryView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: cellIDForCategoryView)
        cv.backgroundColor = .clear
        cv.tag = 1
        return cv
    }()
    
    lazy var logInButton = TWTRLogInButton(logInCompletion: { session, error in
        if let session = session {
            print("signed in as \(session.userName)")
            if let parentCollectionView = self.superview {
                DispatchQueue.main.async { [weak self] in
                    parentCollectionView.findViewController()?.dismiss(animated: true, completion: nil)
                    
                }
            }
        } else {
            if let error = error {
                print("error: \(error.localizedDescription)")
            }
        }
    })
    
    // MARK: Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        fetchExampleTweet(with: "1041868256464654336")
        makeCategories()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup functions
    private func setupViews() {
        backgroundColor = .white
        
        addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.anchor(top: topAnchor, left: nil, right: nil, bottom: nil, paddingTop: 100, paddingLeft: nil, paddingRight: nil, paddingBottom: nil, width: 161, height: 194)
        
        addSubview(tweetView)
        tweetView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        tweetView.anchor(top: topAnchor, left: nil, right: nil, bottom: nil, paddingTop: 78, paddingLeft: nil, paddingRight: nil, paddingBottom: nil, width: nil, height: nil)
        
        addSubview(mainTitleLabel)
        mainTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        mainTitleLabel.anchor(top: topAnchor, left: nil, right: nil, bottom: nil, paddingTop: 384, paddingLeft: nil, paddingRight: nil, paddingBottom: nil, width: nil, height: nil)
        
        
        addSubview(subTitleLabel)
        subTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        subTitleLabel.anchor(top: topAnchor, left: nil, right: nil, bottom: nil, paddingTop: 450, paddingLeft: nil, paddingRight: nil, paddingBottom: nil, width: 250, height: nil)
        
        addSubview(pageIndicatorView)
        pageIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        pageIndicatorView.anchor(top: nil, left: nil, right: nil, bottom: bottomAnchor, paddingTop: nil, paddingLeft: nil, paddingRight: nil, paddingBottom: -51, width: 35, height: 6)
        
        addSubview(logInButton)
        logInButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logInButton.anchor(top: nil, left: nil, right: nil, bottom: bottomAnchor, paddingTop: nil, paddingLeft: nil, paddingRight: nil, paddingBottom: -128, width: nil, height: nil)
        
        
        addSubview(categoryView)
        categoryView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        categoryView.anchor(top: topAnchor, left: nil, right: nil, bottom: nil, paddingTop: 78, paddingLeft: nil, paddingRight: nil, paddingBottom: nil, width: 300, height: 356)
    }
    
    
    private func makeCategories() {
        let biz = Category(title: "Biz", colorName: "appLightBlue")
        let tech = Category(title: "Tech", colorName: "appGreen")
        let design = Category(title: "Design", colorName: "appDeepYellow")
        categories += [biz, tech, design]
    }
    
    
    private func fetchExampleTweet(with tweetID: String) {
        let client = TWTRAPIClient()
        client.loadTweet(withID: tweetID) { [weak self] (tweet, err) in
            if let err = err {
                print(err)
            }
            if let tweet = tweet {
                self?.tweetView.configure(with: tweet)
            }
        }
    }
    
    func animateCell() {
        UIView.animate(withDuration: 1.5, delay: 0.5, options: [.repeat, .curveEaseInOut], animations: {
            let cell = self.categoryView.cellForItem(at: IndexPath(item: 0, section: 0))
            cell?.frame.origin = CGPoint(x: 30, y: 100)
        }, completion: nil)
    }
    
    
}

extension InstructionCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    // MARK: CollectionView Delegate functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 0:
            return 3
        default:
            return categories.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch collectionView.tag {
        case 0:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        default:
            return UIEdgeInsets(top: 167, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView.tag {
        case 0:
            return CGSize(width: 6, height: 6)
        default:
            let title = categories[indexPath.item].title
            let width = CGRect.estimateFrame(for: title).width
            return CGSize(width: width + 20, height: 23)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
            cell.layer.cornerRadius = 3
            cell.layer.masksToBounds = true
            if let currentIndex = self.currentIndex {
                cell.backgroundColor = currentIndex == indexPath.item ? .black : .lightGray
            }
            return cell
        default:
            let category = categories[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIDForCategoryView, for: indexPath) as! CategoryCollectionViewCell
            cell.configure(category: category)
            return cell
        }
    }
    // MARK: Configure functions
    func configure(with index: Int) {
        switch index {
        case 0:
            mainTitleLabel.text = "アドタグへようこそ。"
            categoryView.isHidden = true
            subTitleLabel.text = "Twitterでいいね！した投稿を\nカテゴリごとに管理しよう。"
            logInButton.isHidden = true
            tweetView.isHidden = true
            categoryView.isHidden = true
        case 1:
            mainTitleLabel.text = "使い方は簡単。"
            subTitleLabel.text = "追加したいカテゴリのタグを\nドラッグ＆ドロップするだけ。"
            logInButton.isHidden = true
            imageView.isHidden = true
            tweetView.isHidden = false
            categoryView.isHidden = false
        case 2:
            mainTitleLabel.text = "Twitterにログインして始めよう！"
            subTitleLabel.isHidden = true
            tweetView.isHidden = true
            categoryView.isHidden = true
        default:
            return
        }
    }
}
