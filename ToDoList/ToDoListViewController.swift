//
//  ToDoListViewController.swift
//  ToDoList
//
/*
 MIT License
 */

import UIKit

protocol ToDoListDelegate: class {
    func update()
    func addNewTask()
}

class ToDoListViewController: UIViewController, UITableViewDelegate,  UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var toDoItems: [ToDoItem] {
        do {
            return try context.fetch(ToDoItem.fetchRequest())
        } catch {
            print("Couldnt fetch data")
        }
        return [ToDoItem]()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        title = "To Do List"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))

        // Notification Save
        // NotificationCenter.default.addObserver(self, selector: #selector(addNewTask(_ :)), name: NSNotification.Name.init("com.sweetgodzillas.todoapp.addtask"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.setEditing(false, animated: false)
    }
    
    @objc func addTapped() {
        performSegue(withIdentifier: "AddTaskSegue", sender: nil)
    }
    
    @objc func editTapped() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        if tableView.isEditing == true {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editTapped))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))
        }
    }
    
    // Notification Save
    
    //    @objc func addNewTask(_ notification: NSNotification) {
    //        var toDoItem: ToDoItem!
    //        if let task = notification.object as? ToDoItem {
    //            toDoItem = task
    //        } else {
    //            return
    //        }
    //        toDoItems.append(toDoItem)
    //        toDoItems.sort(by: { $0.completionDate > $1.completionDate })
    //        tableView.reloadData()
    //    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        toDoItems.count
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let toDoItem = self.toDoItems[indexPath.row]
            self.context.delete(toDoItem)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            // self.toDoItems.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let toDoItem = toDoItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItem")!
        
        cell.textLabel?.text = toDoItem.name
        cell.detailTextLabel?.text = toDoItem.isComplete ? "Complete" : "In Complete"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = toDoItems [indexPath.row]
        let toDoTuple = (indexPath.row, selectedItem)
        
        performSegue(withIdentifier: "TaskDetailsSegue", sender: toDoTuple)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TaskDetailsSegue" {
            guard let destinationVC = segue.destination as? ToDoDetailsViewController else { return }
            guard let toDoTuple = sender as? (Int, ToDoItem) else { return }
            
            destinationVC.toDoIndex = toDoTuple.0
            destinationVC.toDoItem = toDoTuple.1
            destinationVC.delegate = self
        }
        
        if segue.identifier == "AddTaskSegue" {
            guard let desinationVC = segue.destination as? AddTaskViewController else { return }
            desinationVC.delegate = self
        }
     }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:  NSNotification.Name.init("com.sweetgodzillas.todoapp.addtask"), object: nil)
    }
}

extension ToDoListViewController: ToDoListDelegate {
    func update() {
        tableView.reloadData()
    }
    
    func addNewTask() {
        tableView.reloadData()
    }
}
