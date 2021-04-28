//
//  ViewController.swift
//  PingBus-Passenger
//
//  Created by Christopher Teddy  on 28/04/21.
//

import UIKit
import CloudKit

class ViewController: UIViewController, UITableViewDataSource {
    
    let RECORD_TYPE = "GroceyItem"
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return tableView
    }()
    
    //create reference to container
    private let database = CKContainer(identifier: "iCloud.com.teddy.PingBus-Passenger").publicCloudDatabase
    
    var items = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Grocery List"
        view.addSubview(tableView)
        tableView.dataSource = self
        
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = control
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        
        
        fetchItems()
    }
    
    @objc private func fetchItems(){
        
        let query = CKQuery(recordType: RECORD_TYPE, predicate: NSPredicate(value: true))
        
        database.perform(query, inZoneWith: nil) { (records, error) in
            guard let records = records, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self.items = records.compactMap({$0.value(forKey: "name") as? String})
                print(self.items)
                
                self.tableView.reloadData()
              
            }
            
           
        }
    }
    
    @objc private func pullToRefresh(){
        tableView.refreshControl?.beginRefreshing()
        let query = CKQuery(recordType: RECORD_TYPE, predicate: NSPredicate(value: true))
        
        database.perform(query, inZoneWith: nil) { (records, error) in
            guard let records = records, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self.items = records.compactMap({$0.value(forKey: "name") as? String})
                print(self.items)
                
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
            
           
        }
    }
    
    @objc func didTapAdd() {
        let alert = UIAlertController(title: "Add Item", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (field) in
            field.placeholder = "Enter Name..."
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (_ ) in
            
            if let field = alert.textFields?.first, let text = field.text, !text.isEmpty {
                self.saveItem(name: text)
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func saveItem(name: String) {
        let record = CKRecord(recordType: RECORD_TYPE)
        record.setValue(name, forKey: "name")
        database.save(record) { (record, error) in
            if record != nil, error == nil {
                print("Save")
                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                    self.fetchItems()
                }
             
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    //Mark : - Table

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = items[indexPath.row]
        
        return cell
    }
}

