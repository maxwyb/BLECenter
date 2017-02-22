//
//  ViewController.swift
//  BluetoothCenter
//
//  Created by Yingbo Wang on 2/18/17.
//  Copyright © 2017 Yingbo Wang. All rights reserved.
//

import UIKit
import CoreBluetooth

let iPadUUID = UUID.init(uuidString: "216FA5C2-67CE-081D-B90B-D30CCD6C9A3A")!
let iPhoneUUID = UUID.init(uuidString: "0DC8E108-9FDB-AA51-2DBB-965B61450888")!

class CentralViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

  var myCentralManager: CBCentralManager?
  var discoveredPeripherals = [CBPeripheral]()
  var connectedPeripheral: CBPeripheral?
  
  var messageCharacteristic: CBCharacteristic?
  
  @IBOutlet weak var messageLabel: UILabel?
  @IBOutlet weak var textField: UITextField?
  
  @IBAction func sendButtonClicked() {
    let updatedValue = textField!.text!  // TODO: cannot be empty
    let updatedValueData = updatedValue.data(using: String.Encoding.utf8)
    
    connectedPeripheral!.writeValue(updatedValueData!, for: messageCharacteristic!, type: CBCharacteristicWriteType.withResponse)
  }
  
  @IBAction func stopScanButtonClicked() {
    myCentralManager!.stopScan()
    
    //connectToPeripheral(withUUID: iPhoneUUID)
    connectToPeripheral()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    myCentralManager = CBCentralManager.init(delegate: self, queue: nil, options: nil)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  func connectToPeripheral() {
    for discovered in discoveredPeripherals {
      /* this does not work because we haven't run discoverServices yet
       if (discovered.services!.first!.uuid == myServiceUUID) {
         print("Connecting to peripheral: \(deviceID)")
       
         connectedPeripheral = discovered
         myCentralManager!.connect(connectedPeripheral!, options: nil)
         return
       }
       */

      /*
      if (discovered.identifier == deviceID) {
        print("Connecting to peripheral: \(deviceID)")
        
        connectedPeripheral = discovered
        myCentralManager!.connect(connectedPeripheral!, options: nil)
        return
      }
      */
      
      // now we use service UUID to find the desired device to connect, not device UUID
      print("Connecting to peripheral: \(discovered.identifier)")
      
      connectedPeripheral = discovered
      myCentralManager!.connect(connectedPeripheral!, options: nil)
      return
    }
  }
  
  // MARK: CBCentralManagerDelegate
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if central.state != .poweredOn {
      print(central.state)
      return
    }
    
    //myCentralManager!.scanForPeripherals(withServices: nil, options: nil)
    myCentralManager!.scanForPeripherals(withServices: [myServiceUUID], options: nil)
  }

  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    
    var duplicatePeripheral = false
    for discovered in discoveredPeripherals {
      //let discoveredCast = discovered as! CBPeripheral  // awkward type casting!
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
    peripheral.discoverServices(nil)
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
      
      if (characteristic.uuid == myCharacteristicUUID) {
        peripheral.setNotifyValue(true, for: characteristic)
        messageCharacteristic = characteristic
        
        peripheral.readValue(for: characteristic)
      }
    }
  }
  
  // the following is called when "readValue" or a notified characteristic is updated
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

    if let data = characteristic.value {
      //let dataString = String(data: data, encoding: String.Encoding.utf8) as! String
      let dataString = String(data: data, encoding: String.Encoding.utf8)!
      print("Characteristic data for \(characteristic): \(dataString)")
      
      if characteristic.uuid == myCharacteristicUUID {
        // update text field
        messageLabel!.text = dataString
      }
    }
    
    print("Characteristic data for \(characteristic): data is nil.")

  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    if (error != nil) {
      print(error!)
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
    if (error != nil) {
      print(error!)
    }
  }
}

