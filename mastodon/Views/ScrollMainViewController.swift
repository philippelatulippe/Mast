//
//  ScrollMainViewController.swift
//  mastodon
//
//  Created by Shihab Mehboob on 13/06/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class ScrollMainViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var scrollView = UIScrollView()
    var viewControllers: [UIViewController] = [] {
        didSet {
            for viewController in viewControllers {
                self.addChild(viewController)
                self.scrollView.addSubview(viewController.view)
                viewController.didMove(toParent: self)
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        self.scrollView.isUserInteractionEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.view = (self.scrollView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let width: CGFloat = 380
        
        self.scrollView.contentSize = CGSize(width: CGFloat(width * CGFloat(CGFloat(viewControllers.count) + CGFloat(0.6))), height: CGFloat(self.view.bounds.height))
        
        var idx: Int = 0
        var widthOffset: CGFloat = 0
        for viewController in viewControllers {
            viewController.view.frame = CGRect(x: widthOffset, y: 0, width: width + 0.6, height: self.view.bounds.height)
            widthOffset += viewController.view.frame.size.width + 0.6
            idx += 1
        }
    }
}
