//
//  AddTaskViewController.swift
//  ToDoList
//
/*
 MIT License
 
 Copyright (c) 2018 Gwinyai Nyatsoka
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

class AddTaskViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var taskNameTextField: UITextField!
    
    @IBOutlet weak var taskDetailsTextView: UITextView!
    
    @IBOutlet weak var taskCompletionDatePicker: UIDatePicker!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    weak var delegate: ToDoListDelegate?
    
    let toolbarDone = UIToolbar.init()
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    lazy var touchView: UIView = {
        let _touchView = UIView();
        _touchView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0)
        
        let touchViewtapped = UITapGestureRecognizer(target: self, action: #selector(doneBtnTapped))
        _touchView.addGestureRecognizer(touchViewtapped)
        _touchView.isUserInteractionEnabled = true
        _touchView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
        return _touchView;
    }()

    var activeTextField: UITextField?
    var activeTextView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let navigationItem = UINavigationItem(title: "Add Task")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidTouch))
        navigationBar.items = [navigationItem]
        
        taskDetailsTextView.layer.borderColor = UIColor.lightGray.cgColor
        taskDetailsTextView.layer.borderWidth = CGFloat(1)
        taskDetailsTextView.layer.cornerRadius = CGFloat(3)
        
        // To show a done button along with keyboard
        toolbarDone.sizeToFit()
        toolbarDone.barTintColor = UIColor.red
        toolbarDone.isTranslucent = false
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let barBtnDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneBtnTapped))
        
        barBtnDone.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        toolbarDone.items = [flexSpace, barBtnDone, flexSpace]
        taskNameTextField.inputAccessoryView = toolbarDone
        taskDetailsTextView.inputAccessoryView = toolbarDone
        
        taskNameTextField.delegate = self
        taskDetailsTextView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterKeyboardNotification()
    }
    
    @objc func cancelButtonDidTouch() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func doneBtnTapped() {
        view.endEditing(true)
    }
    
    func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHasShown(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHasHidden(notofication:)), name: UIWindow.keyboardDidHideNotification, object: nil)
    }
    
    func deregisterKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardDidHideNotification, object: nil)
    }
    
    @objc func keyboardHasShown(notification: NSNotification) {
        view.addSubview(touchView)
        let info: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: (keyboardSize!.height + toolbarDone.frame.size.height + 10.0), right: 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect: CGRect = UIScreen.main.bounds
        aRect.size.height -= keyboardSize!.height
        
        if activeTextField != nil {
            if aRect.contains(activeTextField!.frame.origin) {
                self.scrollView.scrollRectToVisible(activeTextField!.frame, animated: true)
            }
        }
        else if activeTextView != nil {
            let textViewPoint: CGPoint = CGPoint(x: activeTextField!.frame.origin.x, y: activeTextField!.frame.size.height + activeTextField!.frame.size.height)
            
            if (aRect.contains(textViewPoint)) {
                self.scrollView.scrollRectToVisible(activeTextField!.frame, animated: true)
            }
        }
        
    }
    
    @objc func keyboardHasHidden(notofication: NSNotification) {
        touchView.removeFromSuperview()
        let contentInsets: UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
    }
    
    @IBAction func addTaskDidTouch(_ sender: Any) {
        guard let taskName = taskNameTextField.text, !taskName.isEmpty else {
            // Report error
            reportError(title: "Invalid Task Name", message: "Task Name is required")
            return
        }
        
        if taskDetailsTextView.text.isEmpty {
            // Report error
            reportError(title: "Invalid Task Details", message: "Task Details is required")
            return
        }
        
        let completionDate: Date = taskCompletionDatePicker.date
        if completionDate < Date() {
            // Report error
            print(completionDate)
            print(Date())
            reportError(title: "Invalid Completeion Date", message: "Completeion Date is required")
            return
        }
        
        // Save data back via protocol delegate method
        // let toDoItem = ToDoItem(name: taskName, details: taskDetailsTextView.text, completionDate: completionDate)
        let context = appDelegate.persistentContainer.viewContext
        let toDoItem = ToDoItem(context: context)
        toDoItem.name = taskName
        toDoItem.details = taskDetailsTextView.text
        toDoItem.completionDate = completionDate
        toDoItem.isComplete = false
        toDoItem.startDate = Date()
        appDelegate.saveContext()
        
         delegate?.addNewTask()
        cancelButtonDidTouch()
        
        
        // save data via NSNotification
        /*
         let toDoItem = ToDoItem(name: taskName, details: taskDetailsTextView.text, completionDate: completionDate)
                NotificationCenter.default.post(name: NSNotification.Name.init("com.sweetgodzillas.todoapp.addtask"), object: toDoItem)
        */
       
    }
    
    func reportError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}


extension AddTaskViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
}

extension AddTaskViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextView = nil
    }
}
