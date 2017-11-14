//
//  TableViewController.swift
//  Transcribe
//
//  Created by Roland Shen on 5/27/17.
//  Copyright © 2017 Ansail. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework
import RealmSwift
class TableViewController: UITableViewController {
    
    //var recordingTitles: [String]?
    //var recordings: [URL]?
    
    var recordings: Results<Recording>! {
        didSet {
            tableView.reloadData()
        }
    }

    
    override func viewDidLoad() {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        recordings = RealmHelper.retrieve()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        do {
            // Get the directory contents urls (including subfolders urls)
//            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
//            let savedFiles = directoryContents.filter{ $0.pathExtension == "m4a" }
//            print("urls:", savedFiles)
//            let fileNames = savedFiles.map{ $0.deletingPathExtension().lastPathComponent }
//            print("name list:", fileNames)
//            
//            recordings = savedFiles
//            recordingTitles = fileNames

        } catch let error as NSError {
            print(error.localizedDescription)
        }
        self.tableView.backgroundColor = UIColor(hexString: "232B3B")
        tableView.separatorStyle = .none
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)
        tableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tableView.reloadData()
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl?) {
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordingCell") as! RecordingCell
        cell.card.layer.cornerRadius = 3
        cell.card.clipsToBounds = true
        cell.titleLabel.text = recordings[indexPath.row].name!
        cell.lengthDateLabel.text = "\(recordings[indexPath.row].duration!) | \(recordings[indexPath.row].date!)"
        cell.descriptionTextView.text = recordings[indexPath.row].transcription!
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let recordingToDelete = recordings[indexPath.row]
            RealmHelper.deleteRecording(recordingToDelete)
            recordings = RealmHelper.retrieve()
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "detail") {
            let indexPath = tableView.indexPathForSelectedRow!
            let currentRecording = recordings[indexPath.row]
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.recording = currentRecording
        }
    }
    
    @IBAction func unwindToTableViewController(segue: UIStoryboardSegue) {
    }
}
