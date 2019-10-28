//
//  MazeViewController.swift
//  CornMaze
//
//  Created by Ryan Schnaufer on 9/12/19.
//  Copyright © 2019 Ryan Schnaufer. All rights reserved.
//

import UIKit
import CoreNFC

class MazeViewController: UIViewController, NFCNDEFReaderSessionDelegate {

    @IBOutlet weak var FoundTag: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var TimeRemaining: UILabel!
    @IBOutlet weak var tagsFound: UILabel!
    @IBOutlet weak var lastFoundTime: UILabel!
    @IBOutlet weak var lastFoundText: UILabel!

    let defaults = UserDefaults.standard

    var startDate = Date.init()
    var scannedTags: [String] = []

    var session: NFCNDEFReaderSession?
    var restarting = false
    var running = false


    override func viewDidLoad() {
        super.viewDidLoad()

        _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fire), userInfo: nil, repeats: true)

        if let ScannedTags = defaults.object(forKey: "scannedTags") as? [String],
            let StartDate = defaults.object(forKey: "startDate") as? Date,
            let LastText = defaults.object(forKey: "lastText") as? String,
            let LastTime = defaults.object(forKey: "lastTime") as? String
        {
            //if items are in userDefaults
            startDate = StartDate
            scannedTags = ScannedTags
            lastFoundText.text = LastText
            lastFoundTime.text = LastTime
            tagsFound.text = "\(scannedTags.count)"
            running = true

        } else {
            //start a new maze
            running = false
            restartButton.setTitle("Start", for: .normal)
        }

    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print(error.localizedDescription)
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                var payload = (record.payload).suffix(from: 3v)
                var encoding = String.Encoding.utf8
                if(record.payload[3] == 255){
                    payload = (record.payload).suffix(from: 5)
                    encoding = String.Encoding.utf16LittleEndian
                }
                if let string = String(data: payload, encoding: encoding) {
                    print(string)
                    if(restarting)
                    {
                        //only do this check when restarting
                        if(string.contains("restart"))
                        {
                            restart()
                            restarting = false
                        }
                    }
                    //only when not restarting
                    else {

                        scanTags(tagString: string)
                    }
                }
            }
        }
    }

    @objc func fire()
    {
        if(running)
        {
            updateTime()
        }
    }

    @IBAction func buttonTapped(button: UIButton)
    {
        restarting = false
        session = NFCNDEFReaderSession(delegate: self, queue: DispatchQueue.main, invalidateAfterFirstRead: false)
        session?.begin()
    }

    @IBAction func restartButton(_ sender: Any) {
        restarting = true
        session = NFCNDEFReaderSession(delegate: self, queue: DispatchQueue.main, invalidateAfterFirstRead: false)
        session?.begin()
        restartButton.setTitle("Restart", for: .normal)
    }

    func finish() {
        //idkl what to do when finished yet (pause timer?)
    }

    func restart() {
        UserDefaults.standard.synchronize()
        startDate = Date.init()
        scannedTags = []
        running = true
        lastFoundTime.text = "00:00"
        lastFoundText.text = ""
        tagsFound.text = "\(scannedTags.count)"
        updateValues()
    }

    func scanTags(tagString: String) {
        if(!scannedTags.contains(tagString) && running) {
            scannedTags.append(tagString)
            updateLastFoundTime(lastScannedDate: Date.init())
            tagsFound.text = "\(scannedTags.count)"
            lastFoundText.text = tagString
            updateValues()
        }
    }

    func updateValues() {
        defaults.set(startDate, forKey: "startDate")
        defaults.set(scannedTags, forKey: "scannedTags")
        defaults.set(lastFoundTime.text, forKey: "lastTime")
        defaults.set(lastFoundText.text, forKey: "lastText")
    }

    func updateTime() {
        var seconds = Int(Date.init().timeIntervalSince(startDate))
        var minutes = 29
        if(!checkPast()){
            while seconds > 60 {
                seconds = seconds - 60
                minutes = minutes - 1
            }
            seconds = 60 - seconds
        } else {
            minutes = 0
            seconds = 0
            running = false
        }

        var minutesString = "\(minutes)"
        var secondsString = "\(seconds)"

        if(minutes < 10) { minutesString = "0\(minutes)" }
        if(seconds < 10) { secondsString = "0\(seconds)" }
        //write to the timer

        TimeRemaining.text = minutesString + ":" + secondsString
    }

    func updateLastFoundTime(lastScannedDate: Date) {
        var seconds = Int(lastScannedDate.timeIntervalSince(startDate))
        var minutes = 29
        if(!checkPast()){
            while seconds > 60 {
                seconds = seconds - 60
                minutes = minutes - 1
            }
            seconds = 60 - seconds
        } else {
            minutes = 0
            seconds = 0
            running = false
        }

        var minutesString = "\(minutes)"
        var secondsString = "\(seconds)"

        if(minutes < 10) { minutesString = "0\(minutes)" }
        if(seconds < 10) { secondsString = "0\(seconds)" }

        lastFoundTime.text = minutesString + ":" + secondsString
    }



    func checkPast() -> Bool {
        let seconds = Int(Date.init().timeIntervalSince(startDate))
        return seconds >= (60*30)
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

