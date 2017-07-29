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
        cell.card.layer.cornerRadius = 5
        cell.card.clipsToBounds = true
        cell.card.backgroundColor = UIColor.init(gradientStyle: .leftToRight, withFrame: view.frame, andColors: [UIColor.flatSkyBlue(), UIColor.flatBlue()])
        cell.titleLabel.text = recordings[indexPath.row].name!
        cell.lengthDateLabel.text = "\(recordings[indexPath.row].duration!) | \(recordings[indexPath.row].date!)"
        cell.descriptionLabel.text = recordings[indexPath.row].transcription!
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //play recording\
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
}
