//
//  ViewController.swift
//  ChatSample
//
//  Created by riku yasui on 2019/10/08.
//  Copyright © 2019 riku yasui. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {
    
    var databaseRef:DatabaseReference!

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    
    //TextField押下時にキーボードで画面が隠れる問題対応
    @IBOutlet weak var scrollView: UIScrollView!
    var selectedTextField:UITextField?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //TextField押下時にキーボードで画面が隠れる問題対応
        self.textFieldInit()
        
        //FirebaseのDB関連処理
        databaseRef = Database.database().reference()
        databaseRef.observe(.childAdded, with: { snapshot in
            if let value = snapshot.value as? NSDictionary {
                let name = value["name"] as? String ?? ""
                let message = value["message"] as? String ?? ""
                self.textView.text = self.textView.text + "\n" + name + ":" + message
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func pushSend(_ sender: Any) {
        let messageData = ["name": nameTextField.text!, "message": messageTextField.text!]
        databaseRef.childByAutoId().setValue(messageData)
        
        messageTextField.text = ""
    }
    


}

extension ViewController: UITextFieldDelegate {
    
    func textFieldInit() {
        selectedTextField = self.nameTextField
        
        self.nameTextField.delegate = self
        self.messageTextField.delegate = self
    }
    
    @objc func keyboardWillBeShown(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue, let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
                restoreScrollViewSize()
                
                let convertedKeyboardFrame = scrollView.convert(keyboardFrame, from: nil)
                let offsetY: CGFloat = self.selectedTextField!.frame.maxY - convertedKeyboardFrame.minY
                if offsetY < 0 { return }
                updateScrollViewSize(moveSize: offsetY, duration: animationDuration)
            }
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        restoreScrollViewSize()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.selectedTextField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func updateScrollViewSize(moveSize: CGFloat, duration: TimeInterval) {
        UIView.beginAnimations("ResizeForKeyboard", context: nil)
        UIView.setAnimationDuration(duration)
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: moveSize, right: 0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.scrollView.contentOffset = CGPoint(x: 0, y: moveSize)
        
        UIView.commitAnimations()
    }
    
    func restoreScrollViewSize() {
        self.scrollView.contentInset = UIEdgeInsets.zero
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
}
