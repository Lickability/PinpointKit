//
//  SystemLogCollector.swift
//  PinpointKit
//
//  Created by Brian Capps on 2/5/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

import ASL

/// Provides high-level methods to access the raw data in
/// an ASL message.
struct SystemLogEntry {
    /// Key-value pairs read from ASL message
    let data: [String : String]
    
    init(_ data: [String : String]) {
        self.data = data
    }
    
    var time: String              { return data[ASL_KEY_TIME] ?? "" }
    var timeNanoSec: String       { return data[ASL_KEY_TIME_NSEC] ?? "" }
    var host: String              { return data[ASL_KEY_HOST] ?? "" }
    var sender: String            { return data[ASL_KEY_SENDER] ?? "" }
    var facility: String          { return data[ASL_KEY_FACILITY] ?? "" }
    var PID: String               { return data[ASL_KEY_PID] ?? "" }
    var UID: String               { return data[ASL_KEY_UID] ?? "" }
    var GID: String               { return data[ASL_KEY_GID] ?? "" }
    var level: String             { return data[ASL_KEY_LEVEL] ?? "" }
    var message: String           { return data[ASL_KEY_MSG] ?? "" }
    var readUID: String           { return data[ASL_KEY_READ_UID] ?? "" }
    var readGID: String           { return data[ASL_KEY_READ_GID] ?? "" }
    var expireTime: String        { return data[ASL_KEY_EXPIRE_TIME] ?? "" }
    var messageID: String         { return data[ASL_KEY_MSG_ID] ?? "" }
    var session: String           { return data[ASL_KEY_SESSION] ?? "" }
    var refPID: String            { return data[ASL_KEY_REF_PID] ?? "" }
    var refProc: String           { return data[ASL_KEY_REF_PROC] ?? "" }
    var auxTitle: String          { return data[ASL_KEY_AUX_TITLE] ?? "" }
    var auxUTI: String            { return data[ASL_KEY_AUX_UTI] ?? "" }
    var auxURL: String            { return data[ASL_KEY_AUX_URL] ?? "" }
    var option: String            { return data[ASL_KEY_OPTION] ?? "" }
    var module: String            { return data[ASL_KEY_MODULE] ?? "" }
    var senderInstance: String    { return data[ASL_KEY_SENDER_INSTANCE] ?? "" }
    var senderMachUUID: String    { return data[ASL_KEY_SENDER_MACH_UUID] ?? "" }
    var finalNotification: String { return data[ASL_KEY_FINAL_NOTIFICATION] ?? "" }
    var OSActivityID: String      { return data[ASL_KEY_OS_ACTIVITY_ID] ?? "" }
    
    /// Get the entry time as an NSDate
//    var date: NSDate {
//        var sec = time.toInt() ?? 0
//        var nanosec = timeNanoSec.toInt() ?? 0
//        var timeInterval = NSTimeInterval(sec) + NSTimeInterval(nanosec) * 1.0e-9
//        return NSDate(timeIntervalSince1970: timeInterval)
//    }
    
    /// Get the level as a displayable string
    var levelDescription: String {
        if let levelAsInt = Int(level) {
            switch Int32(levelAsInt) {
            case ASL_LEVEL_EMERG:   return ASL_STRING_EMERG
            case ASL_LEVEL_ALERT:   return ASL_STRING_ALERT
            case ASL_LEVEL_CRIT:    return ASL_STRING_CRIT
            case ASL_LEVEL_ERR:     return ASL_STRING_ERR
            case ASL_LEVEL_WARNING: return ASL_STRING_WARNING
            case ASL_LEVEL_NOTICE:  return ASL_STRING_NOTICE
            case ASL_LEVEL_INFO:    return ASL_STRING_INFO
            case ASL_LEVEL_DEBUG:   return ASL_STRING_DEBUG
            default:                return "Unknown"
            }
        }
        else {
            return "Unknown"
        }
    }
}

struct SystemLog {
    /// Invoke a specified closure for every entry in the system log
    ///
    /// The closure argument is a dictionary where each key
    /// is a message attribute name, and the value is the
    /// value of that attribute.
    static func readAllLogEntries(processLogEntry: (SystemLogEntry) -> ()) {
        let query = asl_new(UInt32(ASL_TYPE_QUERY))
        let response = asl_search(nil, query)
        
        for var msg = asl_next(response); msg != nil; msg = asl_next(response) {
            var dict: [String : String] = [:]
            
            var keyIndex = UInt32(0)
            for var key = asl_key(msg, keyIndex); key != nil; key = asl_key(msg, ++keyIndex) {
                if let keyString = String.fromCString(key) {
                    let value = asl_get(msg, key)
                    let valueString = (value == nil) ? "" : String.fromCString(value)
                    
                    dict[keyString] = valueString ?? ""
                }
            }
            
            let logEntry = SystemLogEntry(dict)
            processLogEntry(logEntry)
        }
        
        asl_release(response)
    }
}

class SystemLogCollector: LogCollector {
    
    func readEntries() {
        print("test")
        print("test2")
        NSLog("test3")

        SystemLog.readAllLogEntries { entry in
            print("entry: \(entry.message)")
        }
    }
}
