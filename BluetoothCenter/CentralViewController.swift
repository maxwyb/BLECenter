//
//  ViewController.swift
//  BluetoothCenter
//
//  Created by Yingbo Wang on 2/18/17.
//  Copyright © 2017 Yingbo Wang. All rights reserved.
//

import UIKit
import CoreBluetooth

class CentralViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

  var myCentralManager: CBCentralManager?
  var discoveredPeripherals = [CBPeripheral]()
  var connectedPeripheral: CBPeripheral?
  
  let iPadUUID = UUID.init(uuidString: "216FA5C2-67CE-081D-B90B-D30CCD6C9A3A")!
  
  @IBAction func stopScanButtonClicked() {
    myCentralManager!.stopScan()
    
    connectToPeripheral(withUUID: iPadUUID)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    myCentralManager = CBCentralManager.init(delegate: self, queue: nil, options: nil)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  func connectToPeripheral(withUUID deviceID: UUID) {
    for discovered in discoveredPeripherals {
      if (discovered.identifier == deviceID) {
        print("Connecting to peripheral: \(iPadUUID)")
        
        connectedPeripheral = discovered
        myCentralManager!.connect(connectedPeripheral!, options: nil)
        
        connectedPeripheral!.discoverServices(nil)
      }
    }
  }
  
  // MARK: CBCentralManagerDelegate
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if central.state != .poweredOn {
      print(central.state)
      return
    }
    
    myCentralManager!.scanForPeripherals(withServices: nil, options: nil)
  }

  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    
    var duplicatePeripheral = false
    for discovered in discoveredPeripherals {
      //let discoveredCast = discovered as! CBPeripheral  // TODO: awkward!
      if (discovered.identifier == peripheral.identifier) {
        duplicatePeripheral = true
      }
    }
    if (!duplicatePeripheral) {
      print("didDiscover: \(peripheral), \(RSSI)" )
      self.discoveredPeripherals.append(peripheral)
    }
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    print("didConnect: \(peripheral)")
    
    peripheral.delegate = self
  }
  
  // MARK: CBPeripheralDelegate
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    for service in peripheral.services! {
      print("didDiscoverService: \(service)")
      
      peripheral.discoverCharacteristics(nil, for: service)
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    for characteristic in service.characteristics! {
      print("didDiscoverCharacteristicsFor \(service): \(characteristic)")
      
      peripheral.readValue(for: characteristic)
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    let data = characteristic.value
    
    print("Characteristic data: \(data)")
  }
}

