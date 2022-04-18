//
//  FileManager-DocumentsDirectory.swift
//  JoshanRai-BucketList
//
//  Created by Joshan Rai on 4/17/22.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
