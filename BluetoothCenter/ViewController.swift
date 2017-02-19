//
//  ViewController.swift
//  BluetoothCenter
//
//  Created by Yingbo Wang on 2/18/17.
//  Copyright © 2017 Yingbo Wang. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

  var myCentralManager: CBCentralManager?
  var discoveredPeripherals: NSArray = []
  var connectedPeripheral: CBPeripheral?
  
  @IBAction func stopScanButtonClicked() {
      myCentralManager!.stopScan()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    myCentralManager = CBCentralManager.init(delegate: self, queue: nil, options: nil)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  func connectToPeripheral() {
    connectedPeripheral = discoveredPeripherals[0] as! CBPeripheral
    
    myCentralManager!.connect(connectedPeripheral!, options: nil)
    
    connectedPeripheral!.discoverServices(nil)
    
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
    print("didDiscover: \(peripheral), \(RSSI)" )
    
    self.discoveredPeripherals.adding(peripheral)
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    print("didConnect: \(peripheral)")
    
    peripheral.delegate = self
  }
  
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

