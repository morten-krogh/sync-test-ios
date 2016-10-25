//
//  ViewController.swift
//  SyncTest1
//
//  Created by Morten Krogh on 2016-10-25.
//  Copyright © 2016 Morten Krogh. All rights reserved.
//

import UIKit
import RealmSwift

class SingleNumber: Object {
    dynamic var value = 0
}

class ViewController: UIViewController, UITextFieldDelegate {

    let info_label = UILabel()
    let text_field = UITextField()
    let button = UIButton(type: UIButtonType.roundedRect)
    let value_label = UILabel()
    let error_label = UILabel()
    
    var realm: Realm!
    var notification_token: NotificationToken!
    
    var single_number: SingleNumber?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(displayP3Red: 0.8, green: 0.9, blue: 1, alpha: 1)

        info_label.text = "Type the number of instructions"
        info_label.textAlignment = .center
        view.addSubview(info_label)

        text_field.borderStyle = UITextBorderStyle.roundedRect
        text_field.textAlignment = .center
        text_field.delegate = self
        view.addSubview(text_field)
        
        button.setTitle("Tap to sync", for: UIControlState.normal)
        button.addTarget(self, action: #selector(button_action), for: UIControlEvents.touchUpInside)
        view.addSubview(button)
        
        value_label.textAlignment = .center
        value_label.text = "0"
        view.addSubview(value_label)

        error_label.textAlignment = .center
        error_label.text = "No error"
        view.addSubview(error_label)
        
//        update_number()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        
        let width = view.frame.width
        
        var origin_y = 50 as CGFloat
        
        info_label.frame = CGRect(x: 30, y: origin_y, width: width - 60, height: 30)
        origin_y += info_label.frame.height + 30
        
        text_field.frame = CGRect(x: 50, y: origin_y, width: width - 100, height: 35)
        origin_y += text_field.frame.height + 30
        
        button.frame.size = CGSize(width: 200, height: 30)

        button.frame.origin = CGPoint(x: (width - button.frame.width) / 2, y: origin_y)
        origin_y += button.frame.height + 30
       
        value_label.frame = CGRect(x: 50, y: origin_y, width: width - 100 , height: 30)
        origin_y += value_label.frame.height + 30
        
        error_label.frame = CGRect(x: 50, y: origin_y, width: width - 100 , height: 30)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("did end editing")
        if let value: Int = Int(textField.text!) {
            print("value = \(value)")
            
            for _ in 0  ..< value {
                perform_transaction()
            }
        }
    }
    
    func button_action() {
        start_sync()
    }
    
    func perform_transaction() {

        let single_number = SingleNumber()
        single_number.value = 42
        
        try! realm.write {
            realm.add(single_number)
        }
    }
    
    
    func update_number() {
        let single_numbers = realm.objects(SingleNumber.self)
        let value = single_numbers.count
        
        value_label.text = "\(value)"
    }
    
    func start_sync() {
        
        let username = "1@1"
        let password = "1"
        let auth_url = "http://127.0.0.1:9080"
        let realm_url = "realm://127.0.0.1:9080/~/multi_instructions"
        
        SyncUser.authenticate(with: Credential.usernamePassword(username: username, password: password, actions: []), server: URL(string: auth_url)!, onCompletion: { user, error in
            guard let user = user else {
                self.error_label.text = String(describing: error)
                return
            }
            
            let configuration = Realm.Configuration(
                syncConfiguration: (user, URL(string: realm_url)!)
            )
            self.realm = try! Realm(configuration: configuration)
            self.update_number()
            
            // Notify us when Realm changes
            self.notification_token = self.realm.addNotificationBlock { _ in
                self.update_number()
            }
        })
    
    }
}
