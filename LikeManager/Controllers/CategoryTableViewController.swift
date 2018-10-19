//
//  CategoryTableViewController.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/09/16.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit
import RealmSwift
import TwitterKit

final class CategoryTableViewController: UITableViewController {
    
    // MARK: Properties
    var categories: Results<Category>!
    var filteredCategories = [Category]()
    
    let cellID = "cellID"
    let cellIDAdd = "cellIDAdd"
    
    var notificationToken: NotificationToken?
    
    
    
    // MARK: ViewController Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupRealm()
        setupNotification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkIfSearchBarIsHidden()
    }
    
    deinit {
        notificationToken?.invalidate()
    }

    
    // MARK: Setup Functions
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleAccountChange), name: .accountChangedNotification, object: nil)
    }
    
    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.register(AddCategoryTableViewCell.self, forCellReuseIdentifier: cellIDAdd)
    }


    func reset() {
        filteredCategories = []
        setupRealm()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func setupRealm() {
        let realm = RealmService.shared.realm
        
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            categories = realm.objects(Category.self)
            //only fetch ids which has the same user ID
            filteredCategories = categories.filter({$0.userID == userID})
            
            notificationToken = categories.observe({ (changes: RealmCollectionChange) in
                switch changes {
                case .update(_, let delitions, _, _):
                    if delitions.count > 0 {
                        break
                    }
                    self.categories = realm.objects(Category.self)
                    self.filteredCategories = self.categories.filter({$0.userID == userID})
                    self.tableView.reloadData()
                    
                default:
                    break
                }
            })
        }
    }
    
    private func checkIfSearchBarIsHidden() {
        if let navigationController = self.parent {
            navigationController.navigationItem.titleView?.isHidden = true
        }
    }

    
    // MARK: Handlers
    @objc private func handleAccountChange() {
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            self.filteredCategories = self.categories.filter({$0.userID == userID})
            tableView.reloadData()
        }
    }

    
    
    // MARK: TableViewController delegate functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCategories.count + 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < filteredCategories.count  {
            let vc = CategoryDetailTableViewController()
            vc.selectedIndex = indexPath.row
            navigationController?.pushViewController(vc, animated: true)

        } else {
            let vc = AddCategoryViewController()
            vc.navigationItem.title = "Add Category"
            navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != filteredCategories.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deleteAlert = UIAlertController.deleteAlert {
                let categoryToDelete = self.filteredCategories[indexPath.row]
                RealmService.shared.delete(categoryToDelete)
                
                if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
                    let realm = RealmService.shared.realm
                    self.categories = realm.objects(Category.self)
                    self.filteredCategories = self.categories.filter({$0.userID == userID})
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            present(deleteAlert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < filteredCategories.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! CategoryTableViewCell
            cell.configure(with: filteredCategories[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIDAdd) as! AddCategoryTableViewCell
            cell.titleLabel.textColor = .gray
            return cell
        }
    }
    
}
