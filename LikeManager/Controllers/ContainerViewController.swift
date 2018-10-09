//
//  ContainerViewController.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/09/28.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit
import TwitterKit
import RealmSwift

class ContainerViewController: UIViewController, UIGestureRecognizerDelegate {
    
    enum SlideOutState {
        case collapsed
        case leftPanelExpanded
    }
    
    // MARK: Properties
    lazy var tabBarControllerForNavigationController: UITabBarController = {
        let tbc = UITabBarController()
        let homeVC = HomeViewController()
        homeVC.delegate = self
        let likeTabBarItem = UITabBarItem(title: "いいね!済み", image: #imageLiteral(resourceName: "twitter"), tag: 0)
        homeVC.tabBarItem = likeTabBarItem
        let taggedTabBarItem = UITabBarItem(title: "タグ済み", image: #imageLiteral(resourceName: "MainTag"), tag: 1)
        let categoryVC = CategoryTableViewController()
        categoryVC.tabBarItem = taggedTabBarItem
        tbc.viewControllers = [homeVC, categoryVC]
        return tbc
    }()
    
    
    var centerNavigationController: UINavigationController?
    var leftViewController: SettingViewController?
    var currentState: SlideOutState = .collapsed {
        didSet {
            let isLeftPanelExpanded = currentState == .leftPanelExpanded
            showShadowForCenterViewController(isLeftPanelExpanded)
            setTapGestureRecognizer(isLeftPanelExpanded)
        }
    }
    let centerPanelExpandedOffset: CGFloat = 60
    
    // MARK: ViewController lifecycles
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkIfUserLoggedIn()
    }

    
    // MARK: Setup functions
    private func setTapGestureRecognizer(_ isLeftPanelExpanded: Bool) {
        if isLeftPanelExpanded {
            let tap = UITapGestureRecognizer(target: self, action: #selector(animateLeftPanel))
            tap.delegate = self
            self.centerNavigationController?.view.addGestureRecognizer(tap)
        } else {
            self.centerNavigationController?.view.gestureRecognizers = []
        }
    }
    
    private func setupViewController() {
        centerNavigationController = UINavigationController(rootViewController: tabBarControllerForNavigationController)
        view.addSubview(centerNavigationController!.view)
        self.addChildViewController(centerNavigationController!)
        
        centerNavigationController!.didMove(toParentViewController: self)
    }
    
    private func checkIfUserLoggedIn() {
        if let _ = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            setupViewController()
            setupRealm()
        } else {
            handleLogout()
        }
    }
    
    // MARK: Handlers
    @objc private func handleLogout() {
        let store = TWTRTwitter.sharedInstance().sessionStore
        if let userID = store.session()?.userID {
            store.logOutUserID(userID)
        }
        let layout = UICollectionViewFlowLayout()
        let vc = InstructionViewController(collectionViewLayout: layout)
        self.present(vc, animated: true, completion: nil)
    }
}


extension ContainerViewController: HomeViewControllerDelegate {
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .leftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func addLeftPanelViewController() {
        guard leftViewController == nil else { return }
        
        if let homeVC = centerNavigationController?.childViewControllers.first?.childViewControllers.first as? HomeViewController {
            homeVC.searchController.isActive = false
        }
        
        let vc = SettingViewController()
        addChildSidePanelController(vc)
        leftViewController = vc
    }
    
    func addChildSidePanelController(_ settingViewController: SettingViewController) {
        view.insertSubview(settingViewController.view, at: 0)
        addChildViewController(settingViewController)
        settingViewController.didMove(toParentViewController: self)
    }
    
    private func setupRealm() {
        let realm = RealmService.shared.realm
        if realm.objects(Category.self).count == 0 {
            if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
                makeDefaultCategories(with: userID)
            }
        }
    }
    
    private func makeDefaultCategories(with userID: String) {
        let biz = Category(title: "Biz", colorName: "appLightBlue", userID: userID)
        let tech = Category(title: "Tech", colorName: "appGreen", userID: userID)
        let design = Category(title: "Design", colorName: "appDeepYellow", userID: userID)
        RealmService.shared.create(biz)
        RealmService.shared.create(tech)
        RealmService.shared.create(design)
    }
    
    @objc func animateLeftPanel(shouldExpand: Bool) {
        if shouldExpand {
            currentState = .leftPanelExpanded
            animateCenterPanelXPosition(
                targetPosition: centerNavigationController!.view.frame.width - centerPanelExpandedOffset)
            
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .collapsed
                self.leftViewController?.view.removeFromSuperview()
                self.leftViewController = nil
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut, animations: {
                        self.centerNavigationController!.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
    func showShadowForCenterViewController(_ shouldShowShadow: Bool) {
        
        if shouldShowShadow {
            centerNavigationController!.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController!.view.layer.shadowOpacity = 0.0
        }
    }
}
