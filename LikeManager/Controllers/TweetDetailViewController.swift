//
//  TweetDetailViewController.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/09/17.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit
import TwitterKit
import RealmSwift

final class TweetDetailViewController: UIViewController {
    // MARK: Properties
    private let cellID = "cellID"
    private let cellIDPlus = "cellIDPlus"
    private var categories: Results<Category>!
    private var filteredCategories = [Category]()
    private var categoriesInTweet =  [Category]()
    private var categoriesNotInTweet = [Category]()
    private var notificationToken: NotificationToken?
    private var sourceIndexPath: IndexPath?
    private var sourceCategory: Category?
    private var tweetHeight: CGFloat = 500
    private var tweetID: String? {
        return tweet?.tweetID
    }
    
    var tweet: TWTRTweet? {
        didSet {
            DispatchQueue.main.async {
                self.tweetView.configure(with: self.tweet)
            }
        }
    }
    
    // MARK: Subviews
    private let placeHolderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var tweetView: TWTRTweetView = {
        let view = TWTRTweetView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var dropSpaceView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.tag = 1
        view.dragDelegate = self
        view.dropDelegate = self
        view.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        view.delegate = self
        view.dataSource = self
        view.dragInteractionEnabled = true
        view.alwaysBounceHorizontal = true
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        cv.register(PlusButtonCollectionViewCell.self, forCellWithReuseIdentifier: cellIDPlus)
        cv.backgroundColor = UIColor(r: 239, g: 239, b: 239)
        cv.dragDelegate = self
        cv.dropDelegate = self
        cv.dragInteractionEnabled = true
        cv.tag = 0
        return cv
    }()
    
    
    // MARK: ViewController lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupRealm()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tweetHeight =  tweetView.frame.height
        dropSpaceView.reloadData()
    }
    
    
    // MARK: Setup Functions
    private func setupRealm() {
        let realm = RealmService.shared.realm
        categories = realm.objects(Category.self)
        notificationToken = categories.observe({ (changes: RealmCollectionChange) in
            switch changes {
            case .update(_, let delitions, _, _):
                if delitions.count > 0 {
                    break
                }
                self.setupCategories()
                self.collectionView.reloadData()
            default:
                break
            }
        })
        setupCategories()
    }
    
    private func setupCategories() {
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            filteredCategories = categories.filter({$0.userID == userID})
            categoriesInTweet =  filteredCategories.filter({$0.tweetIDs.contains(self.tweetID!)})
            categoriesNotInTweet = filteredCategories.filter({!($0.tweetIDs.contains(self.tweetID!))})
        }
    }
    
    private func setupViews() {
        edgesForExtendedLayout = []
        view.addSubview(tweetView)
        tweetView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tweetView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tweetView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tweetView.heightAnchor.constraint(lessThanOrEqualToConstant: 400).isActive = true
        
        view.addSubview(placeHolderView)
        placeHolderView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor).isActive = true
        placeHolderView.anchor(top: tweetView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: nil, width: nil, height: 50)
        
        
        view.addSubview(dropSpaceView)
        dropSpaceView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: placeHolderView.bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: nil, height: nil)
        
        view.addSubview(collectionView)
        collectionView.anchor(top: placeHolderView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: 0, width: nil, height: nil)
    }

}


extension TweetDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: CollectionView delegate methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 0:
            return categoriesNotInTweet.count + 1
        case 1:
            return categoriesInTweet.count
        default:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case 0:
            if  indexPath.item < categoriesNotInTweet.count {
                let category = categoriesNotInTweet[indexPath.item]
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CategoryCollectionViewCell
                cell.configure(category: category)
                return cell
            } else if indexPath.item == categoriesNotInTweet.count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIDPlus, for: indexPath) as! PlusButtonCollectionViewCell
                cell.plusButton.addTarget(self, action: #selector(handleEditCategory), for: .touchUpInside)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CategoryCollectionViewCell
                return cell
            }
        case 1:
            let category = categoriesInTweet[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CategoryCollectionViewCell
            cell.configure(category: category)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CategoryCollectionViewCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView.tag {
        case 0:
            if indexPath.item < categoriesNotInTweet.count {
                let title = categoriesNotInTweet[indexPath.item].title
                let width = CGRect.estimateFrame(for: title).width
                return CGSize(width: width + 20, height: 23)
            } else {
                return CGSize(width: 32, height: 27)
            }
        case 1:
            if indexPath.item < categoriesInTweet.count {
                let title = categoriesInTweet[indexPath.item].title
                let width = CGRect.estimateFrame(for: title).width
                return CGSize(width: width + 20, height: 23)
            } else {
                return CGSize(width: 50, height: 23)
            }
        default:
            return CGSize(width: 50, height: 23)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch collectionView.tag {
        case 0:
            return UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
        default:
            return UIEdgeInsets(top: tweetHeight+14.5, left: 10, bottom: 12.5, right: -1000000)
        }
    }
}


extension TweetDetailViewController: UIDropInteractionDelegate, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    // MARK: CollectionView drag interactions
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath, with: collectionView.tag)
    }
    
    private func dragItems(at indexPath: IndexPath, with tag: Int) -> [UIDragItem] {
        if tag == 0, let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell{
            sourceIndexPath = collectionView.indexPath(for: cell)
            let title = cell.textLabel.text
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: title! as NSString))
            dragItem.localObject = "forAdding"
            return [dragItem]
        } else if tag == 1, let cell = dropSpaceView.cellForItem(at: indexPath) as? CategoryCollectionViewCell  {
            sourceIndexPath = dropSpaceView.indexPath(for: cell)
            let title = cell.textLabel.text
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: title! as NSString))
            dragItem.localObject = "forRemoving"
            return [dragItem]
        } else {
            return []
        }
    }
    
    // MARK: CollectionView drop interactions
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = self.sourceIndexPath {
                if collectionView.tag == 0, let localObject = item.dragItem.localObject as? String, localObject == "forRemoving" {
                    self.sourceCategory = categoriesInTweet[sourceIndexPath.item]
                    let realm = RealmService.shared.realm
                    let category = realm.objects(Category.self).filter("title = '\((sourceCategory?.title)!)'").first!
                    self.dropSpaceView.performBatchUpdates({
                        try! realm.write {
                            if let removeIndex = category.tweetIDs.index(of: tweetID!) {
                                category.tweetIDs.remove(at: removeIndex)
                            }
                        }
                        categoriesInTweet.remove(at: sourceIndexPath.item)
                        self.dropSpaceView.deleteItems(at: [sourceIndexPath])
                        categoriesNotInTweet.insert(category, at: destinationIndexPath.item)
                        self.collectionView.insertItems(at: [destinationIndexPath])
                        self.sourceIndexPath = nil
                        self.sourceCategory = nil
                        
                    })
                } else if collectionView.tag == 1, let localObject = item.dragItem.localObject as? String, localObject == "forAdding"  {
                    self.sourceCategory = categoriesNotInTweet[sourceIndexPath.item]
                    let realm = RealmService.shared.realm
                    let category = realm.objects(Category.self).filter("title = '\((sourceCategory?.title)!)'").first!
                    self.collectionView.performBatchUpdates({
                        try! realm.write {
                            category.tweetIDs.append(tweetID!)
                        }
                        categoriesNotInTweet.remove(at: sourceIndexPath.item)
                        self.collectionView.deleteItems(at: [sourceIndexPath])
                        categoriesInTweet.insert(category, at: destinationIndexPath.item)
                        self.dropSpaceView.insertItems(at: [destinationIndexPath])
                        self.sourceIndexPath = nil
                        self.sourceCategory = nil
                    })
                }
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            }
        }
    }
    // MARK: Handlers
    @objc private func handleEditCategory() {
        let vc = AddCategoryViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
