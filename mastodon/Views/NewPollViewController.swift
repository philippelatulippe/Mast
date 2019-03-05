//
//  NewPollViewController.swift
//  mastodon
//
//  Created by Shihab Mehboob on 05/03/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation
import UIKit

class NewPollViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var closeButton = MNGExpandedTouchAreaButton()
    var tootLabel = UIButton()
    var textField = UITextField()
    var keyHeight = 0
    var bgView = UIView()
    var tableView = UITableView()
    var currentOptions: [String] = []
    let timePicker = UIDatePicker()
    let toolBar = UIToolbar()
    var hiddenTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colours.white
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        var tabHeight = Int(UITabBarController().tabBar.frame.size.height) + Int(34)
        var offset = 88
        var closeB = 47
        var botbot = 20
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2688:
                offset = 88
                closeB = 47
                botbot = 40
            case 2436, 1792:
                offset = 88
                closeB = 47
                botbot = 40
            default:
                offset = 64
                closeB = 24
                botbot = 20
                tabHeight = Int(UITabBarController().tabBar.frame.size.height)
            }
        }
        
        bgView.frame = CGRect(x:0, y:Int(self.view.bounds.height) - 40 - Int(self.keyHeight), width:Int(self.view.bounds.width), height:Int(self.keyHeight) + 40)
        bgView.backgroundColor = Colours.tabSelected
        bgView.alpha = 0
        self.view.addSubview(bgView)
        
        self.closeButton = MNGExpandedTouchAreaButton(frame:(CGRect(x: 20, y: closeB, width: 32, height: 32)))
        self.closeButton.setImage(UIImage(named: "block")?.maskWithColor(color: Colours.grayLight2), for: .normal)
        self.closeButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.closeButton.adjustsImageWhenHighlighted = false
        self.closeButton.addTarget(self, action: #selector(didTouchUpInsideCloseButton), for: .touchUpInside)
        self.view.addSubview(self.closeButton)
        
        tootLabel.frame = CGRect(x: CGFloat(self.view.bounds.width - 175), y: CGFloat(closeB), width: CGFloat(150), height: CGFloat(36))
        tootLabel.setTitle("Create", for: .normal)
        tootLabel.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        tootLabel.setTitleColor(Colours.gray.withAlphaComponent(0.65), for: .normal)
        tootLabel.contentHorizontalAlignment = .right
        tootLabel.addTarget(self, action: #selector(didTouchUpInsideTootButton), for: .touchUpInside)
        self.view.addSubview(tootLabel)
        
        textField.frame = CGRect(x: 20, y: offset + 6, width: Int(self.view.bounds.width - 40), height: 30)
        textField.font = UIFont.systemFont(ofSize: Colours.fontSize1 + 2)
        textField.tintColor = Colours.tabSelected
        textField.delegate = self
        textField.becomeFirstResponder()
        textField.keyboardType = .default
        textField.attributedPlaceholder = NSAttributedString(string: "Start typing to add poll options...".localized,
                                                                   attributes: [NSAttributedString.Key.foregroundColor: Colours.tabUnselected])
        textField.keyboardAppearance = Colours.keyCol
        textField.backgroundColor = Colours.white
        textField.textColor = Colours.grayDark
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.returnKeyType = .done
        self.view.addSubview(textField)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        textField.addGestureRecognizer(swipeDown)
        
        self.hiddenTextField.frame = CGRect.zero
        self.view.addSubview(self.hiddenTextField)
        
        self.tableView.register(PollOptionCell.self, forCellReuseIdentifier: "PollOptionCell")
        self.tableView.register(PollOptionCell.self, forCellReuseIdentifier: "PollOptionCell2")
        self.tableView.frame = CGRect(x: 0, y: Int(offset + 40), width: Int(self.view.bounds.width), height: Int(self.view.bounds.height) - offset - tabHeight - 45)
        self.tableView.alpha = 1
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .singleLine
        self.tableView.backgroundColor = Colours.white
        self.tableView.separatorColor = Colours.cellQuote
        self.tableView.layer.masksToBounds = true
        self.tableView.estimatedRowHeight = 89
        self.tableView.rowHeight = UITableView.automaticDimension
        self.view.addSubview(self.tableView)
        
        self.openTimePicker()
    }
    
    func openTimePicker()  {
        self.timePicker.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 200)
        self.timePicker.tintColor = Colours.grayDark
        self.timePicker.datePickerMode = .dateAndTime
        self.timePicker.minimumDate = Date()
        
        if (UserDefaults.standard.object(forKey: "theme") == nil || UserDefaults.standard.object(forKey: "theme") as! Int == 0) {
            toolBar.barStyle = .default
            self.timePicker.backgroundColor = UIColor.white
            self.timePicker.setValue(UIColor.black, forKeyPath: "textColor")
            self.timePicker.setValue(false, forKeyPath: "highlightsToday")
        } else {
            toolBar.barStyle = .blackOpaque
            self.timePicker.backgroundColor = UIColor.black
            self.timePicker.setValue(UIColor.white, forKeyPath: "textColor")
            self.timePicker.setValue(false, forKeyPath: "highlightsToday")
        }
        
        toolBar.isTranslucent = false
        toolBar.tintColor = Colours.tabUnselected
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(timeChanged))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        
        self.hiddenTextField.inputView = timePicker
        self.hiddenTextField.inputAccessoryView = toolBar
    }
    
    @objc func cancelDatePicker() {
        timePicker.removeFromSuperview()
        toolBar.removeFromSuperview()
        self.hiddenTextField.resignFirstResponder()
    }
    
    @objc func timeChanged() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? PollOptionCell {
            cell.configure(formatter.string(from: self.timePicker.date), count: "This poll will expire on:")
        }
        timePicker.removeFromSuperview()
        toolBar.removeFromSuperview()
        self.hiddenTextField.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        switch (deviceIdiom) {
        case .pad:
            self.tableView.translatesAutoresizingMaskIntoConstraints = false
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30).isActive = true
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        default:
            print("nothing")
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.keyHeight = Int(keyboardHeight)
        }
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
            let impact = UIImpactFeedbackGenerator()
            impact.impactOccurred()
        }
        if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            self.textField.resignFirstResponder()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func didTouchUpInsideCloseButton(_ sender: AnyObject) {
        if (UserDefaults.standard.object(forKey: "hapticToggle") == nil) || (UserDefaults.standard.object(forKey: "hapticToggle") as! Int == 0) {
            let impact = UIImpactFeedbackGenerator()
            impact.impactOccurred()
        }
        
        self.textField.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text == "" || textField.text == " " {
            self.textField.resignFirstResponder()
        } else {
            self.currentOptions.append(textField.text ?? "")
            self.textField.text = ""
            self.tableView.reloadData()
        }
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (UserDefaults.standard.object(forKey: "keyhap") == nil) || (UserDefaults.standard.object(forKey: "keyhap") as! Int == 0) {
            
        } else if (UserDefaults.standard.object(forKey: "keyhap") as! Int == 1) {
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
        } else if (UserDefaults.standard.object(forKey: "keyhap") as! Int == 2) {
            let impact = UIImpactFeedbackGenerator()
            impact.impactOccurred()
        }
        
        if (textField.text?.count)! > 0 {
            tootLabel.setTitleColor(Colours.tabSelected, for: .normal)
        } else {
            tootLabel.setTitleColor(Colours.gray.withAlphaComponent(0.65), for: .normal)
        }
    }
    
    @objc func didTouchUpInsideTootButton(_ sender: AnyObject) {
        if self.textField.text == "" { return }
        self.textField.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return currentOptions.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PollOptionCell", for: indexPath) as! PollOptionCell
            cell.configure(self.currentOptions[indexPath.row], count: "Option \(indexPath.row + 1)")
            cell.backgroundColor = Colours.white
            let bgColorView = UIView()
            bgColorView.backgroundColor = Colours.white
            cell.selectedBackgroundView = bgColorView
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PollOptionCell2", for: indexPath) as! PollOptionCell
            cell.configure("Tomorrow", count: "This poll will expire on:")
            cell.backgroundColor = Colours.white
            let bgColorView = UIView()
            bgColorView.backgroundColor = Colours.white
            cell.selectedBackgroundView = bgColorView
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            
        } else {
            self.textField.resignFirstResponder()
            self.hiddenTextField.becomeFirstResponder()
        }
    }
}
