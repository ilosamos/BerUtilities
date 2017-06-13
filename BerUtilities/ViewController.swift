//
//  ViewController.swift
//  BerUtilities
//
//  Created by Daniel Berger on 13/06/2017.
//  Copyright © 2017 Daniel Berger. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  var reachability: Reachability?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Start reachability without a hostname initially
    setupReachability(nil, useClosures: true)
    startNotifier()
    
    // After 5 seconds, stop and re-start reachability, this time using a hostname
    let dispatchTime = DispatchTime.now() + DispatchTimeInterval.seconds(5)
    DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
      self.stopNotifier()
      self.setupReachability("google.com", useClosures: true)
      self.startNotifier()
      
      let dispatchTime = DispatchTime.now() + DispatchTimeInterval.seconds(5)
      DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
        self.stopNotifier()
        self.setupReachability("invalidhost", useClosures: true)
        self.startNotifier()            }
      
    }
  }
  
  func setupReachability(_ hostName: String?, useClosures: Bool) {
    print("--- set up with host name: \(hostName ?? "No Hostname!")")
    
    let reachability = hostName == nil ? Reachability() : Reachability(hostname: hostName!)
    self.reachability = reachability
    
    if useClosures {
      reachability?.whenReachable = { reachability in
        DispatchQueue.main.async {
          self.updateLabelColourWhenReachable(reachability)
        }
      }
      reachability?.whenUnreachable = { reachability in
        DispatchQueue.main.async {
        }
      }
    } else {
      NotificationCenter.default.addObserver(self, selector: #selector(ViewController.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: reachability)
    }
  }
  
  func startNotifier() {
    print("--- start notifier")
    do {
      try reachability?.startNotifier()
    } catch {
      print("Unable to start\nnotifier")
      return
    }
  }
  
  func stopNotifier() {
    print("--- stop notifier")
    reachability?.stopNotifier()
    NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
    reachability = nil
  }
  
  func updateLabelColourWhenReachable(_ reachability: Reachability) {
    print("\(reachability.description) - \(reachability.currentReachabilityString)")
    if reachability.isReachableViaWiFi {
      //self.networkStatus.textColor = .green
    } else {
      //self.networkStatus.textColor = .blue
    }
  }
  
  func reachabilityChanged(_ note: Notification) {
    let reachability = note.object as! Reachability
    
    if reachability.isReachable {
      updateLabelColourWhenReachable(reachability)
    } else {
      //updateLabelColourWhenNotReachable(reachability)
    }
  }
  
  deinit {
    stopNotifier()
  }
}

