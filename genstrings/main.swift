#!/usr/bin/swift
//
//  main.swift
//  genstrings
//
//  Created by Kristian Trenskow on 03/04/2017.
//  Copyright © 2017 trenskow. All rights reserved.
//

import Foundation

let exp = try! NSRegularExpression(pattern: "(?<=\")([^\"]*)(?=\".(localize\\((\\\"(.*?)\\\")?\\)))", options: [])

func findFiles(path: String) throws -> [String] {
    return try FileManager.default.contentsOfDirectory(atPath: path).reduce([], { (result, subpath) -> [String] in
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: "\(path)/\(subpath)", isDirectory: &isDirectory) else { return result }
        guard isDirectory.boolValue == false else {
            return try result + findFiles(path: "\(path)/\(subpath)")
        }
        return result + ["\(path)/\(subpath)"]
    }).filter({ (path) -> Bool in
        path.contains(".swift")
    })
}

var path: String? = nil

if CommandLine.arguments.count > 1 {
    path = CommandLine.arguments[1]
}

FileHandle.standardOutput.write(Data(bytes: [0xfe, 0xff]))
FileHandle.standardOutput.write(try findFiles(path: path ?? FileManager.default.currentDirectoryPath)
    .map { (path) -> [(String, String?)] in
        
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        
        let string = String(data: data, encoding: .utf8)!
        
        return exp.matches(in: string, options: [], range: NSMakeRange(0, string.characters.count)).reduce([], { (ret, result) -> [(String, String?)] in
            
            let found = (0 ..< result.numberOfRanges).map({ (idx) -> String? in
                let range = result.rangeAt(idx)
                guard range.location != NSNotFound else { return nil }
                let startIndex = string.index(string.startIndex, offsetBy: range.location)
                let endIndex = string.index(startIndex, offsetBy: range.length)
                return string.substring(with: startIndex ..< endIndex)
            })
            
            return ret + [(found.first!!, found.last!)]
            
        })
        
    }
    .reduce([], +)
    .reduce([]) { (result, strings) -> [(String, String?)] in
        guard !result.contains(where: { $0.0 == strings.0 }) else { return result }
        return result + [strings]
    }
    .map { (strings) in
        let string = strings.0.components(separatedBy: "\"").joined(separator: "\\\"")
        let comment = strings.1 ?? "No comment provided by engineer"
        return ["", "/* \(comment) */", "\"\(string)\" = \"\(string)\";"]
    }
    .reduce([], +)
    .joined(separator: "\n")
    .data(using: .utf16BigEndian)!)
