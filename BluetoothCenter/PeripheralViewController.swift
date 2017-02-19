//
//  PeripheralViewController.swift
//  BluetoothCenter
//
//  Created by Yingbo Wang on 2/18/17.
//  Copyright © 2017 Yingbo Wang. All rights reserved.
//

import UIKit
import CoreBluetooth

let myServiceUUID = CBUUID.init(string: "9B1F32B2-95FA-4E5A-8D10-5F704AC73DAB")
let myCharacteristicUUID = CBUUID.init(string: "7E1DF8E3-AA0E-4F16-B9AB-43B28D73AF25")

class PeripheralViewController: UIViewController, CBPeripheralManagerDelegate {

  var myPeripheralManager: CBPeripheralManager?
  
  var myCharacteristic: CBMutableCharacteristic?
  var myService: CBMutableService?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    myPeripheralManager = CBPeripheralManager.init(delegate: self, queue: nil, options: nil)
    
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
  }
  
  // MARK: CBPeripheralManagerDelegate
  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    if (peripheral.state != .poweredOn) {
      print(peripheral.state)
      return
    }
    
    let myValue = "Hello Bluetooth LE!"
    let myValueData = myValue.data(using: String.Encoding.utf8)
    // TODO: add write permission
    myCharacteristic = CBMutableCharacteristic.init(type: myCharacteristicUUID,
                                                    properties: CBCharacteristicProperties.read, value: myValueData! as Data,
                                                    permissions: CBAttributePermissions.readable)
    myService = CBMutableService.init(type: myServiceUUID, primary: true)
    myService!.characteristics?.append(myCharacteristic!)
    
    myPeripheralManager!.add(myService!)
    
    myPeripheralManager!.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [myService!.uuid]])
    print("startAdvertising.")
  }
  
  func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
    if (error != nil) {
      print(error)
    }
  }
  
  func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
    if (error != nil) {
      print(error)
    }
  }
  
  func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
    print("didReceiveRead: \(request)")
    if (request.characteristic.uuid == myCharacteristic?.uuid) {
      // TODO: not sure "count" method call is correct
      if (request.offset > myCharacteristic!.value!.count) {
        myPeripheralManager?.respond(to: request, withResult: CBATTError.invalidOffset)
        return
      }
      
      let dataRange = Range(uncheckedBounds: (request.offset + 1, myCharacteristic!.value!.count))
      request.value = myCharacteristic!.value?.subdata(in: dataRange)
      
      myPeripheralManager?.respond(to: request, withResult: CBATTError.success)
      print("respond: \(request)")
    }
  }

}
