//
//  Extensions.swift
//  YahdehDemo
//
//  Created by iMac on 2/5/20.
//  Copyright © 2020 gritty. All rights reserved.
//

import Foundation
import UIKit

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

extension DateFormatter {
  static let iso8601Full: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
}

extension UITableView {
    func scrollToBottom(animated: Bool) {
        guard let dataSource = dataSource else { return }
        var lastSectionWithAtLeastOneElement = (dataSource.numberOfSections?(in: self) ?? 1) - 1
        while dataSource.tableView(self, numberOfRowsInSection: lastSectionWithAtLeastOneElement) < 1 && lastSectionWithAtLeastOneElement > 0 {
            lastSectionWithAtLeastOneElement -= 1
        }
        let lastRow = dataSource.tableView(self, numberOfRowsInSection: lastSectionWithAtLeastOneElement) - 1
        guard lastSectionWithAtLeastOneElement > -1 && lastRow > -1 else { return }
        let bottomIndex = IndexPath(item: lastRow, section: lastSectionWithAtLeastOneElement)
        scrollToRow(at: bottomIndex, at: .bottom, animated: animated)
    }
}
 
extension UIImage {

    public convenience init?(_ systemItem: UIBarButtonItem.SystemItem) {

        guard let sysImage = UIImage.imageFrom(systemItem: systemItem)?.cgImage else {
            return nil
        }

        self.init(cgImage: sysImage)
    }

    private class func imageFrom(systemItem: UIBarButtonItem.SystemItem) -> UIImage? {

        let sysBarButtonItem = UIBarButtonItem(barButtonSystemItem: systemItem, target: nil, action: nil)

        //MARK:- Adding barButton into tool bar and rendering it.
        let toolBar = UIToolbar()
        toolBar.setItems([sysBarButtonItem], animated: false)
        toolBar.snapshotView(afterScreenUpdates: true)

        if  let buttonView = sysBarButtonItem.value(forKey: "view") as? UIView{
            for subView in buttonView.subviews {
                if subView is UIButton {
                    let button = subView as! UIButton
                    let image = button.imageView!.image!
                    return image
                }
            }
        }
        return nil
    }
}

extension UIView {
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 5
    }}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}
