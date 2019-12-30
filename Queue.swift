//
//  Queue.swift
//  Queues
//
//  Created by Sisov on 24.12.2019.
//  Copyright © 2019 Sisov. All rights reserved.
//

import Foundation

public enum Queue {
    case database
    case transform
    case network
    case tracker
    case ui
}

private extension Queue {
    
    static var queueCache = [String: DispatchQueue]()
    
    var qos: DispatchQoS {
        if self == .database { return .utility }
        return .userInitiated
    }
    
    var label: String {
        switch self {
        case .database:   return "com.database.queue"
        case .transform:  return "com.transform.queue"
        case .network:    return "com.network.queue"
        case .tracker:    return "com.tracker.queue"
        case .ui:         return "com.ui.queue"
        }
    }
    
    var queue: DispatchQueue {
        if let queue = Queue.queueCache[label] {
            return queue
        }
        
        let queue = create()
        Queue.queueCache[label] = queue
        return queue
    }
    
    func create() -> DispatchQueue {
        if self == .ui { return DispatchQueue.main }
        return DispatchQueue(label: label, qos: qos)
    }
}

public extension Queue {
    typealias blockExecute = () -> ()
    
    func async(block: @escaping blockExecute) {
        let workItem = DispatchWorkItem(block: block)
        queue.async(execute: workItem)
    }
    
    func asyncAfter(deadline: DispatchTime, block: @escaping blockExecute) {
        let workItem = DispatchWorkItem(block: block)
        queue.asyncAfter(deadline: deadline, execute: workItem)
    }
    
    func sync(block: @escaping blockExecute) {
        let workItem = DispatchWorkItem(block: block)
        queue.sync(execute: workItem)
    }
    
    func release() {
        Queue.queueCache.removeValue(forKey: label)
    }
}
