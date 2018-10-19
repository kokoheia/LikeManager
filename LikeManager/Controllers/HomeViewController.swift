//
//  HomeViewController.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/08/11.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit
import TwitterKit
import RealmSwift


let tweetIDCache = NSCache<NSString, UserTweets>()

protocol HomeViewControllerDelegate {
    func toggleLeftPanel()
}

final class HomeViewController: UITableViewController {
    
    // MARK: Properties
    private let cellID = "cellID"
    private var searchResult = [TWTRTweet]()
    private var users: Results<User>!
    private var notificationToken: NotificationToken?
    private var numberOfRequest = 5
    private var client = TWTRAPIClient()
    private var tapGestureRecognizer: UITapGestureRecognizer?
    private var isFirstSearch = true

    var tweetIDs = [String]()
    var tweets = [TWTRTweet]()
    var lastLoadedTweetID: String?
    var loadCount = 0
    var searchController : UISearchController!
    var isTweetFetched =  false
    var delegate: HomeViewControllerDelegate?
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = .gray
        return indicator
    }()
    

    // MARK: Functions for Realm
    private func setupRealm(with userID: String) {
        let realm = RealmService.shared.realm
        
        //if it is the first time make a user
        if realm.objects(User.self).count == 0 {
            let user = User(userID: userID)
            RealmService.shared.create(user)
        }
    }
    
    
    // MARK: Functions for checking the state
    func checkIfUserLoggedIn() {
        //skip when it doesn't need to be fetched
        if isTweetFetched {
            return
        }
        
        //if there is a realm object fetch from the data
        let realm = RealmService.shared.realm
        users = realm.objects(User.self)
        if let currentUserID = users.filter({$0.isCurrentUser}).first?.userID {
            getTweetsIDs(userID: currentUserID, lastLoadedTweetID: nil)
            return
        }
        
        // if it is first time when the user use the app
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            getTweetsIDs(userID: userID, lastLoadedTweetID: self.lastLoadedTweetID)
            setupRealm(with: userID)
            return
        }
    }
    
    private func checkIfSearchBarIsHidden() {
        if let navigationController = self.parent {
            if let titleView = navigationController.navigationItem.titleView {
                if titleView.isHidden {
                    titleView.isHidden = false
                }
            }
        }
    }
    
    private func prepareForReload() {
        tweetIDs = []
        tweets = []
        loadCount = 0
    }
    

    // MARK: Functions for fetching tweets using TwitterAPI
    //getting TweetIDs -> fetching Tweets using TweetIDs
    private func getTweetsIDs(userID: String, lastLoadedTweetID: String?) {
        //if there is a cache load from it
        if let tweetIDs = tweetIDCache.object(forKey: userID as NSString) {
            self.tweetIDs = tweetIDs.tweetIDs
            fetchTweets()
        }
        
        //if the loadCount get the same as numberOfRequest, fetch data
        if self.loadCount >= numberOfRequest {
            DispatchQueue.main.async { [weak self] in
                if let tweetIDs = self?.tweetIDs {
                    let userTweets = UserTweets(tweetIDs: tweetIDs)
                    tweetIDCache.setObject(userTweets, forKey: userID as NSString)
                }
                self?.fetchTweets()
                self?.activityIndicator.stopAnimating()
            }
            return
        }
        
        let client = TWTRAPIClient(userID: userID)
        let statusesShowEndpoint = "https://api.twitter.com/1.1/favorites/list.json"
        var clientError : NSError?
        let params = makeParams(userID: userID)
        let request = client.urlRequest(withMethod: "GET", urlString: statusesShowEndpoint, parameters: params, error: &clientError)
        
        client.sendTwitterRequest(request) { [weak self] (response, data, connectionError) -> Void in
            if connectionError != nil {
                print("Error: \(connectionError!)")
                self?.present(UIAlertController.networkErrorAlert, animated: true, completion: nil)
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [Any] else {return}
                self?.loadTweetIDs(userID: userID, json: json)
            } catch let jsonError as NSError {
                print("json error: \(jsonError.localizedDescription)")
            }
        }
    }
    
    private func makeParams(userID: String) -> [String: String] {
        var params = [String: String]()
        if let lastLoadedTweetID = lastLoadedTweetID {
            params = ["id": userID,"count": "20", "max_id":lastLoadedTweetID, "include_entities": "false"]
        } else {
            params = ["id": userID,"count": "20","include_entities": "false"]
        }
        return params
    }
    
    private func loadTweetIDs(userID: String, json: [Any]) {
        for tweet in json {
            if let tweet = tweet as? [String: Any] {
                if let id = tweet["id_str"] as? String {
                    self.tweetIDs.append(id)
                    self.lastLoadedTweetID = id
                }
            }
        }
        self.loadCount += 1
        if let id = self.lastLoadedTweetID {
            let newID = String(Int(id)! - 1)
            self.getTweetsIDs(userID: userID, lastLoadedTweetID: newID)
        }
    }
    
    private func fetchTweets() {
        let client = TWTRAPIClient()
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
            self?.isTweetFetched = true
        }
    }
    
    
    
    // MARK: ViewController Life Cycles
    override func viewDidAppear(_ animated: Bool) {
        checkIfUserLoggedIn()
        checkIfSearchBarIsHidden()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = []

        setupTableView()
        setupNavigationBar()
        setupActivityIndicator()
        setupSearchBar()
        setupNotification()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: Setup Functions
    private func setupSearchBar() {
        self.searchController = UISearchController(searchResultsController:  nil)
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        
        if let navigationController = self.parent {
            searchController.delegate = self
            navigationController.navigationItem.titleView = searchController.searchBar
            self.definesPresentationContext = true
            
            if navigationController.navigationItem.titleView!.isHidden {
                navigationController.navigationItem.titleView?.isHidden = false
            }
        }
    }
    
    private func setupTableView() {
        tableView.register(TweetTableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.separatorStyle = .none
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.anchor(top: view.topAnchor, left: nil, right: nil, bottom: nil, paddingTop: 150, paddingLeft: nil, paddingRight: nil, paddingBottom: nil, width: 15, height: 15)
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 15).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        activityIndicator.startAnimating()
    }
    
    private func setupNavigationBar() {
        if let tabBarController = self.parent {
            
            let menuBtn = UIButton(type: .custom)
            menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
            menuBtn.setImage(#imageLiteral(resourceName: "hamburger"), for: .normal)
            menuBtn.addTarget(self, action: #selector(handleToggle), for: .touchUpInside)
            
            let menuBarItem = UIBarButtonItem(customView: menuBtn)
            menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
            menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
            tabBarController.navigationItem.leftBarButtonItem = menuBarItem
        }
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleChangeAccount), name: .accountChangedNotification, object: nil)
    }
    
    
    // MARK: Handlers
    @objc func handleChangeAccount(_ notification: NSNotification) {
        prepareForReload()
    }

    @objc private func handleToggle() {
        delegate?.toggleLeftPanel()
    }
    
    
    // MARK: TableView Delegate Functions
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! TweetTableViewCell
        if searchController.isActive {
            cell.tweetView.configure(with: searchResult[indexPath.row])
        } else {
            cell.tweetView.configure(with: tweets[indexPath.row])
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? searchResult.count : tweets.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive {
            if let text = searchController.searchBar.text {
                if text.isEmpty {
                    searchController.isActive = false
                    return
                }
            }
        }
        let vc = TweetDetailViewController()
        vc.tweet = searchController.isActive ? searchResult[indexPath.row] : tweets[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}




extension HomeViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    // MARK: SearchController Delegate Functions
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            return
        }
        searchTweets(for: searchText)
    }
    
    private func searchTweets(for text: String) {
        if text.isEmpty {
            self.searchResult = self.tweets
            tableView.reloadData()
            return
        }
        self.searchResult = self.tweets.filter { $0.author.name.lowercased().range(of: text.lowercased()) != nil || $0.text.lowercased().range(of: text.lowercased()) != nil ||  $0.author.formattedScreenName.lowercased().range(of: text.lowercased()) != nil}
        tableView.reloadData()
    }
}
