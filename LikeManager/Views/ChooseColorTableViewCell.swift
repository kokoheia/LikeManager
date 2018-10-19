//
//  ChooseColorTableViewCell.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/09/17.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit

final class ChooseColorTableViewCell: UITableViewCell {
    // MARK: Properties
    private let cellID = "cellID"
    private lazy var colors: [UIColor] = [.appPurple, .appGreen, .appLightBlue, .appDeepYellow, .appBrown, .appVividRed, .appOrange]
    private var selectedIndex: Int?
    
    // MARK: Subviews
    lazy var collectionView: UICollectionView =  {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        return cv
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
        addSubview(collectionView)
        collectionView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        collectionView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        collectionView.anchor(top: nil, left: nil, right: nil, bottom: nil, paddingTop: nil, paddingLeft: nil, paddingRight: nil, paddingBottom: nil, width: 349, height: 35)
    }
    
    // MARK: Configure functions
    func configure(with category: Category) {
        let color = UIColor.convert(name: category.colorName)
        selectedIndex = colors.index(of: color)!
    }
}


extension ChooseColorTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK:  CollectionView delegate functions
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ColorCollectionViewCell
        cell.color = colors[indexPath.item]
        if let selectedIndex = selectedIndex, indexPath.item == selectedIndex {
            DispatchQueue.main.async {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 22, height: 22)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 25
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 9, bottom: 0, right: 0)
    }
}
