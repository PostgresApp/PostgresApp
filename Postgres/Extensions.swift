//
//  Extensions.swift
//  Postgres
//
//  Created by Chris on 04/08/2016.
//  Copyright © 2016 postgresapp. All rights reserved.
//

import Foundation

extension FileManager {
	func applicationSupportDirectoryPath() -> String {
		let url = self.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
		
		let bundleName = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
		let path = url.appendingPathComponent(bundleName).path
		
		if !self.fileExists(atPath: path) {
			try! self.createDirectory(atPath: path, withIntermediateDirectories: false)
		}
		
		return path
	}
	
	func applicationExists(_ appName: String) -> Bool {
		var appPath = "/Applications/"
		switch appName {
		case "Terminal":
			appPath += "Utilities/"+appName+".app"
		default:
			appPath += appName+".app"
		}
		return self.fileExists(atPath: appPath)
	}
}

func is_arm_mac() -> Bool {
    // first check the cpu type
    var cpu_type: cpu_type_t = 0
    var cpu_type_size = MemoryLayout.size(ofValue: cpu_type)
    if -1 == sysctlbyname("hw.cputype", &cpu_type, &cpu_type_size, nil, 0) {
        // this should never happen
        return false
    }
    if (cpu_type & CPU_TYPE_ARM) == CPU_TYPE_ARM {
        return true
    }
    
    // When the app is running under Rosetta, hw.cputype reports an Intel CPU
    // We want to know the real CPU type, so we have to check for Rosetta
    // If we detect Rosetta, we are running on ARM
    var is_translated: Int = 0;
    var is_translated_size = MemoryLayout.size(ofValue: is_translated)
    if -1 == sysctlbyname("sysctl.proc_translated", &is_translated, &is_translated_size, nil, 0) {
        // if this call fails we are probably running on Intel
        return false
    }
    else if is_translated != 0 {
        // process is translated with Rosetta -> we must be on ARM
        return true
    }
    else {
        return false
    }
}

extension ProcessInfo {
	var macosDisplayVersion: String {
		let v = operatingSystemVersion
		return "\(v.majorVersion).\(v.minorVersion).\(v.patchVersion)"
	}
}
