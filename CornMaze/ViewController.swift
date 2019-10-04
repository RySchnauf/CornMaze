//
//  ViewController.swift
//  CornMaze
//
//  Created by Ryan Schnaufer on 9/12/19.
//  Copyright © 2019 Ryan Schnaufer. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var TeamPicker: UIPickerView!
    @IBOutlet weak var Next: UIButton!
    
    var teamList: [Team] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        //TeamPicker.delegate = self as UIPickerViewDelegate
        //TeamPicker.dataSource = self as UIPickerViewDataSource

        let decoder = JSONDecoder()

//        if let path = Bundle.main.path(forResource: "Teams", ofType: "json") {
//            do {
//                let JSONData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
//                teamList = try decoder.decode([Team].self, from: JSONData)
//            } catch {
//                print(error.localizedDescription)
//
//            }
//        }

    }


    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return teamList.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return teamList[row].Name
    }

}

