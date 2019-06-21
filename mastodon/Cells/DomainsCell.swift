//
//  DomainsCell.swift
//  mastodon
//
//  Created by Shihab Mehboob on 21/06/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit
import PINRemoteImage

class DomainsCell: SwipeTableViewCell {
    
    var userName = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        userName.translatesAutoresizingMaskIntoConstraints = false
        
        userName.numberOfLines = 0
        
        userName.textColor = Colours.black
        
        userName.font = UIFont.systemFont(ofSize: Colours.fontSize1, weight: .heavy)
        
        contentView.addSubview(userName)
        
        let viewsDict = [
            "name" : userName,
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[name]-(>=15)-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-18-[name]-18-|", options: [], metrics: nil, views: viewsDict))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ status: String) {
        userName.text = status
        userName.font = UIFont.systemFont(ofSize: Colours.fontSize1, weight: .heavy)
    }
    
}


