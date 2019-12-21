//
//  ToDoListViewController.swift
//  ToDoList
//
/*
 MIT License
 */

import UIKit

protocol ToDoListDelegate: class {
    func update(task: ToDoItem, index: Int)
}

class ToDoListViewController: UIViewController, UITableViewDelegate,  UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var toDoItems: [ToDoItem] = [ToDoItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        title = "To Do List"
        
        let testItem = ToDoItem(name: "Hello Sam", details: "Lorem", completionDate: Date())
        self.toDoItems.append(testItem)
        
        let testItem1 = ToDoItem(name: "Hello Sam1", details: "Lorem1", completionDate: Date())
        self.toDoItems.append(testItem1)
        
        let testItem2 = ToDoItem(name: "Hello Sam2", details: "Lorem2", completionDate: Date())
        self.toDoItems.append(testItem2)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        toDoItems.count
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
    }
}

extension ToDoListViewController: ToDoListDelegate {
    func update(task: ToDoItem, index: Int) {
        toDoItems[index] = task
        tableView.reloadData()
    }
}
