
//
//  SettingViewController.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/09/28.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit
import TwitterKit
import RealmSwift


let userCache = NSCache<NSString, User>()


final class SettingViewController: UITableViewController {
    
    // MARK: Properties
    private let accountCellID = "accontCellID"
    private let normalCellID = "normalCellID"
    
    private var sections = ["Accounts", "Utilities"]
    
    private var users: Results<User>!
    private var usersData = [User] () {
        didSet {
            usersData.sort { $0.userName! < $1.userName! }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    private var utilities = ["Feedback"]
    private var currentUserID: String? {
        if let user = users.filter({$0.isCurrentUser}).first {
            return user.userID
        } else {
            return nil
        }
    }
    
    // MARK: ViewController lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRealm()
        fetchAccount()
        setupTableView()
    }
    
    
    // MARK: Setup functions
    private func setupAccount(with user: User) {
        let client = TWTRAPIClient()
        let statusesShowEndpoint = "https://api.twitter.com/1.1/users/show.json"
        var clientError : NSError?
        let params = ["user_id": user.userID]
        let request = client.urlRequest(withMethod: "GET", urlString: statusesShowEndpoint, parameters: params, error: &clientError)
        client.sendTwitterRequest(request) { [weak self] (response, data, connectionError) -> Void in
            if let connectionError = connectionError {
                print("Error: \(connectionError)")
                self?.present(UIAlertController.networkErrorAlert, animated: true, completion: {
                    if let parentViewController = self?.parent as? ContainerViewController {
                        parentViewController.toggleLeftPanel()
                    }
                })
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] else {return}
                let profileImageUrl = json["profile_image_url_https"] as! String
                let userName = json["screen_name"] as! String
                let newUser = User(userID: user.userID, userName: userName, profileImageUrlString: profileImageUrl)
                self?.usersData.append(newUser)
                userCache.setObject(newUser, forKey: newUser.userID as NSString)
            } catch let jsonError as NSError {
                print("json error: \(jsonError.localizedDescription)")
            }
        }
    }


    private func setupRealm() {
        self.users = RealmService.shared.realm.objects(User.self)
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.separatorStyle = .none
        tableView.register(AccountTableViewCell.self, forCellReuseIdentifier: accountCellID)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: normalCellID)
    }
        
    private func fetchAccount() {
        for user in users {
            if let cachedUser = userCache.object(forKey: user.userID as NSString) {
                if !usersData.contains(cachedUser) {
                    usersData.append(cachedUser)
                }
            } else {
                setupAccount(with: user)
            }
        }
    }
    
    private func reset(homeViewController: HomeViewController) {
        homeViewController.isTweetFetched = false
        homeViewController.tweetIDs = []
        homeViewController.tweets = []
        homeViewController.lastLoadedTweetID = nil
        homeViewController.loadCount = 0
    }

    
    
    // MARK: TableViewController delegate functions
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SettingHeaderView()
        view.textLabel.text = sections[section]
        if section == 0 {
            view.plusButton.isHidden = false
            view.plusButton.addTarget(self, action: #selector(handleAddAccount), for: .touchUpInside)
        }
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? usersData.count : utilities.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: accountCellID, for: indexPath) as! AccountTableViewCell
            cell.configure(with: usersData[indexPath.row])
            cell.selectionStyle = .none
            
            //unhide checkbox of current user account
            if let currentUserID = self.currentUserID{
                let account = usersData[indexPath.row]
                cell.checkBox.isHidden = account.userID == currentUserID ? false : true
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: normalCellID, for: indexPath)
            cell.selectionStyle = .none
            cell.textLabel?.text = utilities[indexPath.row]
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if let currentUserID = self.currentUserID{
                let user = usersData[indexPath.row]
                if user.userID != currentUserID {
                    let alertController =  UIAlertController.confirmAccountChangeAlert {
                        let userID = user.userID
                        let dict = ["userID": userID]
                        NotificationCenter.default.post(name: .accountChangedNotification, object: nil, userInfo: dict)
                        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
                            if (session != nil) {
                                self.handleChangeAccount(to: session!.userID)
                            } else {
                                if let error = error {
                                    print("error: \(error.localizedDescription)")
                                }
                            }
                        })
                    }
                    present(alertController, animated: true, completion: nil)
                } else {
                    return
                }
            }
        default:
            let feedBackEmail = "a_la_mode1108@icloud.com"
            if let url = URL(string: "mailto:\(feedBackEmail)") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    // MARK: Handlers
    @objc private func handleAddAccount() {
        if users.count > 1 {
            present(UIAlertController.cannotMakeAccountAlert, animated: true, completion: nil)
            return
        }
        
        let store = TWTRTwitter.sharedInstance().sessionStore
        if let userID = store.session()?.userID {
            store.logOutUserID(userID)
        }
        TWTRTwitter.sharedInstance().logIn(completion: { [weak self] (session, error) in
            if let session = session {
                let  userID = session.userID
                let user = User(userID: userID)
                
                if self?.users.filter({$0.userID == user.userID}).count == 0 {
                    let user = User(userID: user.userID)
                    RealmService.shared.create(user)
                    self?.setupAccount(with: user)
                    self?.handleChangeAccount(to: userID)
                } else {
                    print("it's the same account")
                    self?.present(UIAlertController.sameAccountAlert, animated: true, completion: nil)
                }
            } else {
                if let error = error  {
                    print("error: \(error.localizedDescription)");
                }
            }
        })
    }
    
    private func handleChangeAccount(to userID: String) {
        if let oldCurrentUser = users.filter({$0.isCurrentUser}).first {
            RealmService.shared.update(oldCurrentUser, with: ["isCurrentUser": false])
        }
        if let newCurrentUser = users.filter({$0.userID == userID}).first {
            RealmService.shared.update(newCurrentUser, with: ["isCurrentUser": true])
        }
        
        //set tweet fetched to false to re-fetch
        if let parentViewController = self.parent as? ContainerViewController {
            if let homeVC = parentViewController.centerNavigationController?.childViewControllers.first?.childViewControllers.first as? HomeViewController {
                reset(homeViewController: homeVC)
                homeVC.checkIfUserLoggedIn()
            }
            
            //do something to reset category view
            if let categoryVC = parentViewController.centerNavigationController?.childViewControllers.first?.childViewControllers[1] as? CategoryTableViewController {
                categoryVC.reset()
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}




