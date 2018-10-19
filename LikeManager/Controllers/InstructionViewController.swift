//
//  LoginViewController.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/09/15.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit
import TwitterKit
import RealmSwift

final class InstructionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: Properties
    private let cellID = "cellID"
    private var users: Results<User>!
    
    private lazy var logInButton = TWTRLogInButton(logInCompletion: { [weak self] session, error in
        if let session = session {
            print("signed in as \(session.userName)")
            DispatchQueue.main.async { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
        } else {
            if let error = error {
                print("error: \(error.localizedDescription)")
            }
        }
    })
    
    // MARK: ViewController LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    // MARK: Setup Funtions
    private func setupCollectionView() {
        collectionView?.register(InstructionCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.isPagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
        
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout{
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
        }
    }
    
    
    // MARK: CollectionViewController delegate functions
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! InstructionCollectionViewCell
        cell.configure(with: indexPath.item)
        cell.currentIndex = indexPath.item
        
        if indexPath.item == 1 {
            DispatchQueue.main.async {
                cell.animateCell()
            }
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
}
