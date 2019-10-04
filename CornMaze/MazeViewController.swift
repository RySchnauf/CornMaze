//
//  MazeViewController.swift
//  CornMaze
//
//  Created by Ryan Schnaufer on 9/12/19.
//  Copyright © 2019 Ryan Schnaufer. All rights reserved.
//

import UIKit

class MazeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var FoundTag: UIButton!
    @IBOutlet weak var NFCTableView: UITableView!

    let defaults = UserDefaults.standard

    var nfcTags: [String] = []
    var timeDict = [String: String]()
    var startDate = Date.init()
    var activeTag = 0

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NFCCell", for: indexPath) as UITableViewCell

        let tag = nfcTags[indexPath.row]

        if(timeDict[tag] != nil){
            cell.textLabel?.text = "\(tag)"
            cell.detailTextLabel?.text = timeDict[tag]
        } else if(indexPath.row == 0 || timeDict[nfcTags[indexPath.row-1]] != nil) {
            cell.textLabel?.text = "\(tag)"
            cell.detailTextLabel?.text = "--:--:--"
        } else {
            cell.textLabel?.text = "????"
            cell.detailTextLabel?.text = "--:--:--"
        }
        return cell
    }



    override func viewDidLoad() {
        super.viewDidLoad()

        if let TimeDict = defaults.object([String:String].self, with: "timeDict"),
        let NFCTags = defaults.object([String].self, with: "nfcTags"),
        let StartDate = defaults.object(Date.self, with: "startDate") {
            //if items are in userDefaults
            timeDict = TimeDict
            nfcTags = NFCTags
            startDate = StartDate
            activeTag = defaults.integer(forKey: "activeTag")
        } else {
            //start a new maze
            restart()

        }


        NFCTableView.delegate = self
        NFCTableView.dataSource = self

        refresh()
    }

    @IBAction func buttonTapped(button: UIButton)
    {
        completeTag()
    }

    func restart() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        timeDict = [String: String]()
        startDate = Date.init()
        activeTag = 0
        nfcTags = chooseTargets()

        updateValues()

        refresh()
    }

    func updateValues() {
        defaults.set(timeDict, forKey: "timeDict")
        defaults.set(nfcTags, forKey: "nfcTags")
        defaults.set(startDate, forKey: "startDate")
        defaults.set(activeTag, forKey: "activeTag")
    }

    func recordTime(tag: String) {
        var seconds = Int(Date.init().timeIntervalSince(startDate))
        var minutes = 0
        var hours = 0
        while seconds >= 60 {
            seconds = seconds - 60
            if minutes == 59 {
                minutes = 0
                hours = hours + 1
            } else {
                minutes = minutes + 1
            }
        }
        var hoursString = "\(hours)"
        var minutesString = "\(minutes)"
        var secondsString = "\(seconds)"

        if(hours < 10) { hoursString = "0\(hours)" }
        if(minutes < 10) { minutesString = "0\(minutes)" }
        if(seconds < 10) { secondsString = "0\(seconds)" }

        timeDict.updateValue("\(hoursString):\(minutesString):\(secondsString)", forKey: tag)
    }

    func completeTag(){
        recordTime(tag: nfcTags[activeTag])
        activeTag += 1
        if(activeTag > 3) { activeTag = 3}

        updateValues()

        refresh()
    }

    func refresh(){
        self.NFCTableView.reloadData()
    }

    func chooseTargets() -> [String] {
        var remaining = [1, 2, 3, 4]
        var chips:[String] = []
        while remaining.count > 0 {
            let select = Int.random(in: 0 ... remaining.count-1)
            chips.append("\(selectNFC(quadrant: remaining[select]))")
            remaining.remove(at: select)
        }
        return chips
    }

    func selectNFC(quadrant: Int) -> Int {
        switch quadrant {
        case 1:
            return Int.random(in: 1...4)
        case 2:
            return Int.random(in: 5...8)
        case 3:
            return Int.random(in: 9...12)
        default:
            return Int.random(in: 13...16)
        }

    }
}

extension UserDefaults {
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = self.value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }

    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        self.set(data, forKey: key)
    }
}

