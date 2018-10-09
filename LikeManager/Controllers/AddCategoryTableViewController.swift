//
//  AddCategoryViewController.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/09/17.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit
import RealmSwift
import TwitterKit

class AddCategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: Properties
    let inputCellID = "inputCellID"
    let colorCellID = "colorCellID"
    var category: Category?
    var categories: Results<Category>!

    lazy var tableView: UITableView =  {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.register(TextInputTableViewCell.self, forCellReuseIdentifier: inputCellID)
        tv.register(ChooseColorTableViewCell.self, forCellReuseIdentifier: colorCellID)
        tv.alwaysBounceVertical = false
        return tv
    }()
    
    // MARK: ViewController LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRealm()
        setupViews()
        setupNavigationBar()
    }
    
    // MARK: Setup functions
    private func setupRealm() {
        let realm = RealmService.shared.realm
        categories = realm.objects(Category.self)
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
    }
    
    private func setupViews() {
        tableView.separatorStyle = .none
        
        view.backgroundColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1)
        edgesForExtendedLayout = []
        
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingTop: 0, paddingLeft: 0, paddingRight: 0, paddingBottom: nil, width: nil, height: 126)
    }
    
    // MARK: Handlers
    @objc private func handleDone() {
        let firstCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TextInputTableViewCell
        let secondCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! ChooseColorTableViewCell
        if let text = firstCell.textInput.text, !text.isEmpty {
            if let indexPathes = secondCell.collectionView.indexPathsForSelectedItems, indexPathes.count > 0 {
                let indexPath = indexPathes[0]
                let cell = secondCell.collectionView.cellForItem(at: indexPath) as! ColorCollectionViewCell
                let color = cell.selectedCircle.color
                let colorName = color.name
                if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
                    //check if there is a category of the same name
                    if categories.filter({$0.userID == userID}).filter({$0.title == text}).count > 0 {
                        present(UIAlertController.sameTitleAlert, animated: true)
                        return
                    }
                    if let category = category {
                        let dict = ["title": text, "colorName": colorName]
                        RealmService.shared.update(category, with: dict)
                    } else {
                        let newCategory = Category(title: text, colorName: colorName, userID: userID)
                        RealmService.shared.create(newCategory)
                    }
                }
            } else {
                // if there is no color selected
                present(UIAlertController.nonColorAlert, animated: true)
                return
            }
        } else {
            //if there is no title
            present(UIAlertController.nonTitleAlert, animated: true)
            return
        }
        navigationController?.popViewController(animated: true)
    }
    
    
    
    // MARK: TableViewController delegate functions
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: inputCellID) as! TextInputTableViewCell
            if let category = category {
                cell.configure(with: category)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: colorCellID) as! ChooseColorTableViewCell
            if let category = category {
                cell.configure(with: category)
            }
            return cell
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }


}
