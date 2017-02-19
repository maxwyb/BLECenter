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
  
  var subscribedCharacteristic: CBCharacteristic?
  
  @IBOutlet weak var messageLabel: UILabel?
  @IBOutlet weak var textField: UITextField?
  
  @IBAction func sendButtonClicked() {
    let updatedValue = textField!.text!  // TODO: cannot be empty
    let updatedValueData = updatedValue.data(using: String.Encoding.utf8)
    
    var didSendValue = myPeripheralManager?.updateValue(updatedValueData!, for: myCharacteristic!, onSubscribedCentrals: nil)
  }
  
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
    // Syntax: bitwise OR equals square bracket
    myCharacteristic = CBMutableCharacteristic.init(type: myCharacteristicUUID,
                                                    properties: [CBCharacteristicProperties.read, CBCharacteristicProperties.write, CBCharacteristicProperties.notify],
                                                    value: myValueData! as Data,
                                                    permissions: [CBAttributePermissions.readable, CBAttributePermissions.writeable])
    myService = CBMutableService.init(type: myServiceUUID, primary: true)
    
    if var characteristics = myService?.characteristics {  // tricky optional unwraping
      characteristics.append(myCharacteristic!)
    } else {
      myService?.characteristics = [myCharacteristic!]
    }
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
    if (request.characteristic.uuid == myCharacteristic!.uuid) {
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
  
  func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {

    // TODO: potentially more than 1 requests
    myCharacteristic!.value = requests.first!.value
    
    print("didReceiveWrite requests: \(myCharacteristic?.value)")
  }
  
  func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
    print("\(central) didSubscribeTo: \(characteristic)")
    
    //subscribedCharacteristic = characteristic
  }

}
