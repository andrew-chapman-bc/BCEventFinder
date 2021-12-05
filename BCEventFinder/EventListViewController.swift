//
//  EventListViewController.swift
//  BCEventFinder
//
//  Created by Andrew Chapman on 11/30/21.
//

import UIKit
import Firebase

private let dateFormatter: DateFormatter = {
    print("Just created the date formatter")
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yy"
    return dateFormatter
}()

class EventListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var events: Events!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        events = Events()
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        events.loadData {
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let destination = segue.destination as! EventDetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.event = events.eventArray[selectedIndexPath.row]
        } 
    }
    
    func sortBasedOnSegmentPressed() {
        switch segmentedControl.selectedSegmentIndex {
        case 0: //A-Z
            events.eventArray.sort(by: {$0.name < $1.name})
        case 1: // date recent
            events.eventArray.sort(by: {dateFormatter.date(from: String($0.date.components(separatedBy: ",")[0])) ?? Date() < dateFormatter.date(from: String($1.date.components(separatedBy: ",")[0])) ?? Date()})
        case 2: // date future
            events.eventArray.sort(by: {dateFormatter.date(from: String($0.date.components(separatedBy: ",")[0])) ?? Date() > dateFormatter.date(from: String($1.date.components(separatedBy: ",")[0])) ?? Date()})
        default:
            print("HEY! You shouldn't have gotten here. Check out the segmented control for an error!")
        }
        tableView.reloadData()
    }
    
    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
        sortBasedOnSegmentPressed()
    }
    @IBAction func createEventPressed(_ sender: UIBarButtonItem) {
    }
    
}

extension EventListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.eventArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = events.eventArray[indexPath.row].name
        cell.detailTextLabel?.text = events.eventArray[indexPath.row].date
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.textColor = .black
        if events.eventArray[indexPath.row].postingUserID == Auth.auth().currentUser?.uid {
            cell.backgroundColor = UIColor(named: "SecondaryColor")
        } else {
            cell.backgroundColor = .clear
        }
        let today = Date()
        let modifiedDate = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        if dateFormatter.date(from: String(events.eventArray[indexPath.row].date.components(separatedBy: ",")[0]))! <= modifiedDate {
            cell.backgroundColor = UIColor(named: "PrimaryColor")
            cell.textLabel?.textColor = .white
            cell.detailTextLabel?.textColor = .white
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
