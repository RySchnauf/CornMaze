//
//  NFCTag.swift
//  CornMaze
//
//  Created by Ryan Schnaufer on 9/17/19.
//  Copyright © 2019 Ryan Schnaufer. All rights reserved.
//

import Foundation
import os.log

class NFCTag: NSObject, NSCoding {

    var tag: Int
    var timeFound: Date

    func encode(with aCoder: NSCoder) {
        aCoder.encode(tag, forKey: PropertyKey.tag)
        aCoder.encode(timeFound, forKey: PropertyKey.timeFound)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        guard let tag = aDecoder.decodeObject(forKey: PropertyKey.tag) as? Int else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let timeFound = aDecoder.decodeObject(forKey: PropertyKey.timeFound) as? Date else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }

        self.init(tag: tag, timeFound: timeFound)

    }




}


struct PropertyKey {
    static let tag = "tag"
    static let timeFound = "timeFound"
}
