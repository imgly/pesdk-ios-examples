//
//  SDKVersion.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 07/01/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

struct SDKVersion: Comparable, CustomStringConvertible {
    let majorVersion: Int
    let minorVersion: Int
    let patchVersion: Int

    var description: String {
        return "\(majorVersion).\(minorVersion).\(patchVersion)"
    }

    init?(string: String) {
        let versionComponents = string.componentsSeparatedByString(".")

        if versionComponents.count == 1 {
            guard let majorVersion = Int(versionComponents[0]) else {
                return nil
            }

            self.majorVersion = majorVersion
            self.minorVersion = 0
            self.patchVersion = 0
        } else if versionComponents.count == 2 {
            guard let majorVersion = Int(versionComponents[0]), minorVersion = Int(versionComponents[1]) else {
                return nil
            }

            self.majorVersion = majorVersion
            self.minorVersion = minorVersion
            self.patchVersion = 0
        } else if versionComponents.count == 3 {
            guard let majorVersion = Int(versionComponents[0]), minorVersion = Int(versionComponents[1]), patchVersion = Int(versionComponents[2]) else {
                return nil
            }

            self.majorVersion = majorVersion
            self.minorVersion = minorVersion
            self.patchVersion = patchVersion
        } else {
            return nil
        }
    }
}

func == (lhs: SDKVersion, rhs: SDKVersion) -> Bool {
    return (lhs.majorVersion == rhs.majorVersion) && (lhs.minorVersion == rhs.minorVersion) && (lhs.patchVersion == rhs.patchVersion)
}

func < (lhs: SDKVersion, rhs: SDKVersion) -> Bool {
    if lhs.majorVersion < rhs.majorVersion {
        return true
    } else if lhs.majorVersion > rhs.majorVersion {
        return false
    }

    if lhs.minorVersion < rhs.minorVersion {
        return true
    } else if lhs.minorVersion > rhs.minorVersion {
        return false
    }

    if lhs.patchVersion < rhs.patchVersion {
        return true
    } else if lhs.patchVersion > rhs.patchVersion {
        return false
    }

    return false
}
