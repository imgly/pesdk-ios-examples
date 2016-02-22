//
//  JSONParser.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 22/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import Foundation

/**
 <#Description#>

 - IllegalBorderHash:      <#IllegalBorderHash description#>
 - IllegalImageRecord:     <#IllegalImageRecord description#>
 - IllegalImageRatio:      <#IllegalImageRatio description#>
 - BorderNodeNoDictionary: <#BorderNodeNoDictionary description#>
 - BorderArrayNotFound:    <#BorderArrayNotFound description#>
 */
enum JSONParserError: ErrorType {
    case IllegalBorderHash
    case IllegalImageRecord(recordName: String)
    case IllegalImageRatio(recordName: String)
    case BorderNodeNoDictionary
    case BorderArrayNotFound
}

/**
 *  The JSONParser class is out to parse a JSON dicionary into an array of `BorderInfoRecord` entries.
 */
@objc(IMGLYJSONParserProtocol) public protocol JSONParserProtocol {
    /**
     Parses the retrieved JSON data to an array of `BorderInfoRecord`s.

     - parameter dict: The JSON induced dictionary.

     - throws: An `JSONParserError`.

     - returns: An array of `BorderInfoRecord`s.
     */
    func parseJSON(dict: NSDictionary)  throws -> [BorderInfoRecord]
}

/**
 *  The JSONParser class is out to parse a JSON dicionary into an array of `BorderInfoRecord` entries.
 */
@objc(IMGLYJSONParser) public class JSONParser: NSObject, JSONParserProtocol {

    /**
     Parses the retrieved JSON data to an array of `BorderInfoRecord`s.

     - parameter dict: The JSON induced dictionary.

     - throws: An `JSONParserError`.

     - returns: An array of `BorderInfoRecord`s.
     */
    public func parseJSON(dict: NSDictionary)  throws -> [BorderInfoRecord] {
        var records = [BorderInfoRecord]()
        if let borders = dict["borders"] as? NSArray {
            for border in borders {
                if let border = border as? NSDictionary {
                    guard let name = border["name"] as? String,
                        let label = border["label"] as? String,
                        let thumbnailURL = border["thumbnail_url"] as? String,
                        let images = border["images"] as? NSDictionary else {
                            throw JSONParserError.IllegalBorderHash
                    }
                    let record = BorderInfoRecord()
                    record.name = name
                    record.label = label
                    record.thumbnailURL = thumbnailURL
                    for (key, value) in images {
                        let imageInfo = ImageInfoRecord()
                        guard let ratioString = key as? String,
                            let url = value as? String else {
                                throw JSONParserError.IllegalImageRecord(recordName: record.name)
                        }
                        let expn = NSExpression(format:ratioString)
                        if let ratio = expn.expressionValueWithObject(nil, context: nil) as? Float {
                            imageInfo.ratio = ratio
                        } else {
                            throw JSONParserError.IllegalImageRatio(recordName: record.name)
                        }
                        imageInfo.url = url
                        record.imageInfos.append(imageInfo)
                    }
                    records.append(record)
                } else {
                    throw JSONParserError.BorderNodeNoDictionary
                }
            }
        } else {
            throw JSONParserError.BorderArrayNotFound
        }
        return records
    }
}
