//
//  Extensions.swift
//  LikeManager
//
//  Created by Kohei Arai on 2018/09/16.
//  Copyright © 2018年 Kohei Arai. All rights reserved.
//

import UIKit

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, right: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, paddingTop: CGFloat?, paddingLeft: CGFloat?, paddingRight: CGFloat?, paddingBottom: CGFloat?, width: CGFloat?, height: CGFloat?) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top, let paddingT = paddingTop {
            self.topAnchor.constraint(equalTo: top, constant: paddingT).isActive = true
        }
        
        if let left = left, let paddingL = paddingLeft {
            self.leftAnchor.constraint(equalTo: left, constant: paddingL).isActive = true
        }
        
        if let right = right, let paddingR = paddingRight {
            self.rightAnchor.constraint(equalTo: right, constant: paddingR).isActive = true
        }
        
        if let bottom = bottom, let paddingB = paddingBottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: paddingB).isActive = true
        }
        
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    static var appGreen = UIColor(r: 99, g: 218, b: 56)
    static var appLightBlue =  UIColor(r: 27, g: 173, b: 248)
    static var appPurple = UIColor(r: 207, g: 120, b: 228)
    static var appDeepYellow = UIColor(r: 234, g: 187, b: 0)
    static var appBrown = UIColor(r: 162, g: 132, b: 94)
    static var appVividRed = UIColor(r: 255, g: 41, b: 104)
    static var appOrange = UIColor(r: 255, g: 149, b: 0)

    
    var name: String {
        switch self {
        case .appGreen:
            return "appGreen"
        case .appLightBlue:
            return "appLightBlue"
        case .appPurple:
            return "appPurple"
        case .appDeepYellow:
            return "appDeepYellow"
        case .appBrown:
            return "appBrown"
        case .appVividRed:
            return "appVividRed"
        case .appOrange:
            return "appOrange"
        default:
            return "appLightBlue"
        }
    }
    
    static func convert(name: String) -> UIColor {
        switch name {
        case "appGreen":
            return appGreen
        case "appLightBlue":
            return .appLightBlue
        case "appPurple":
            return .appPurple
        case "appDeepYellow":
            return .appDeepYellow
        case "appBrown":
            return .appBrown
        case "appVividRed":
            return .appVividRed
        case "appOrange":
            return .appOrange
        default:
            return .appLightBlue
        }
    }
}

let imageCache = NSCache<NSString, UIImage>()


extension UIImageView {
    func loadProfileImage(with urlString: String) {
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        let url = NSURL(string: urlString)
        URLSession.shared.dataTask(with: url! as URL, completionHandler: {  [weak self] (data, response, err ) in
            if let err = err {
                print(err)
                return
            }
            
            if let image = UIImage(data: data!) {
                DispatchQueue.main.async {
                    self?.image = image
                }
                imageCache.setObject(image, forKey: urlString as NSString)
            }
        }).resume()
    }
}

extension UIImage {
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension CGRect {
    static func estimateFrame(for text: String) -> CGRect {
        let size = CGSize(width: 1000, height: 23)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
}

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}


extension UIAlertController {
    static let networkErrorAlert: UIAlertController = {
        let alert = UIAlertController(title: "ネットワークエラー", message: "Twitterとの通信に制限がかかっています。15分以上時間を空けてから再度お試しください。", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        return alert
    }()
    
    static let sameAccountAlert: UIAlertController = {
        let alert = UIAlertController(title: "エラー", message: "このアカウントはすでに登録されています。他のアカウントを選択して再度お試しください。", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        return alert
    }()
    
    static let nonColorAlert: UIAlertController = {
        let alert = UIAlertController(title: "色がありません", message: "色を選んでから実行してください。", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        return alert
    }()
    
    static let nonTitleAlert: UIAlertController = {
        let alert = UIAlertController(title: "名前がありません", message: "名前を記入してから実行してください。", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        return alert
    }()
    
    static let sameTitleAlert: UIAlertController = {
        let alert = UIAlertController(title: "タグがすでに存在します", message: "同じ名前のタグを作ることはできません。", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        return alert
    }()
    
    static let cannotMakeAccountAlert: UIAlertController = {
        let alert = UIAlertController(title: "アカウントを登録できません", message: "登録できるアカウントは最大2つまでです。", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        return alert
    }()
    
    static func deleteAlert(completion: @escaping () -> Void) -> UIAlertController {
        let alertController = UIAlertController(title: "本当に削除しますか？", message: "この動作は取り消せません。", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "はい", style: .default) { (alertAction) in
            completion()
        }
        let cancelAction = UIAlertAction(title: "いいえ", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        return alertController
    }
    
    static func confirmAccountChangeAlert(completion: @escaping () -> Void) -> UIAlertController {
        let alertController: UIAlertController = UIAlertController(title: nil, message: "アカウントを変えますか？", preferredStyle:  UIAlertControllerStyle.actionSheet)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (completed) in
            completion()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(yesAction)
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
}

extension Notification.Name {
    static let accountChangedNotification = Notification.Name("accountChangedNotification")
}

