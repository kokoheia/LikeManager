//
//  CategoryDetailTableViewController.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/09/24.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit
import TwitterKit
import RealmSwift

final class CategoryDetailTableViewController: UITableViewController {
    
    // MARK: Properties
    private let categoryCellID = "categoryCellID"
    private let tweetCellID = "tweetCellID"
    private var categories: Results<Category>!
    private var fileteredCategoires = [Category]()
    private var notificationToken: NotificationToken?
    private var tweetIDs = [String]()
    private var tweets = [TWTRTweet]()

    var selectedIndex: Int?
    
    // MARK: ViewController lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRealm()
        setupNavigationBar()
        setupTableView()
        fetchTweetIDs()
        fetchTweets()
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    
    // MARK: Setup functions
    private func setupRealm() {
        let realm = RealmService.shared.realm
        categories = realm.objects(Category.self)
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            fileteredCategoires = categories.filter({$0.userID == userID})
        }
        notificationToken = realm.observe { [weak self] (_, _) in
            self?.tableView.reloadData()
        }
    }
    
    private func setupNavigationBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(handleEditCategory))
    }
    
    private func setupTableView() {
        edgesForExtendedLayout = []
        tableView?.register(CategoryTableViewCell.self, forCellReuseIdentifier: categoryCellID)
        tableView?.register(TweetTableViewCell.self, forCellReuseIdentifier: tweetCellID)
    }
    
    private func makeDafaultCategories(with userID: String) {
        let realm = RealmService.shared.realm
        if realm.objects(Category.self).count == 0 {
            let biz = Category(title: "Biz", colorName: "appLightBlue", userID: userID)
            let tech = Category(title: "Tech", colorName: "appGreen", userID: userID)
            let design = Category(title: "Design", colorName: "appDeepYellow", userID: userID)
            RealmService.shared.create(biz)
            RealmService.shared.create(tech)
            RealmService.shared.create(design)
        }
    }
    
    // MARK: Functions for fetching tweets
    private func fetchTweetIDs() {
        if let selectedIndex = selectedIndex {
            let category = fileteredCategoires[selectedIndex]
            for i in 0..<category.tweetIDs.count {
                tweetIDs.append(category.tweetIDs[i])
            }
        }
    }
    
    private func fetchTweets() {
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            client.loadTweets(withIDs: tweetIDs) { [weak self] (tweets, err) in
                if let err = err {
                    print(err)
                }
                if let tweets = tweets {
                    self?.tweets = tweets
                }
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }

    
    // MARK: Handlers
    @objc private func handleEditCategory() {
        let vc = AddCategoryViewController()
        if let selectedIndex = selectedIndex {
            let category = fileteredCategoires[selectedIndex]
            vc.category = category
            vc.navigationItem.title = "Edit Category"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    

    // MARK: TableViewController delegate functions
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = CategoryTableViewCell()
        view.backgroundColor = .white
        if let selectedIndex = selectedIndex {
            let category = fileteredCategoires[selectedIndex]
            view.configure(with: category)
        }
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 51
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tweetCellID) as! TweetTableViewCell
        cell.tweetView.configure(with: tweets[indexPath.row])
        return cell
    }
}
