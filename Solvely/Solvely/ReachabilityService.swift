//
//  InternetAvailabilityService.swift
//  Solvely
//
//  Created by Daniel Christopher on 10/23/16.
//  Copyright © 2016 Solvely. All rights reserved.
//

import Foundation
import ReachabilitySwift

protocol ReachabilityServiceDelegate {
    func reachabilityChanged(connectionAvailable: Bool!)
}

class ReachabilityService {
    let reachability = Reachability()!
    
    func registerForUpdates(delegate: ReachabilityServiceDelegate!) {
        reachability.whenReachable = { reachability in
            // this is called on a background thread
            DispatchQueue.main.async {
                delegate.reachabilityChanged(connectionAvailable: true)
            }
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread
            DispatchQueue.main.async {
                delegate.reachabilityChanged(connectionAvailable: false)
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}
