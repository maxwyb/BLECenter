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
  
  //let myValue = "Hello Bluetooth LE!"
  let myValue = "The quick brown fox jumps over the lazy dog. Can the value of a characteristic has size larger than 20 bytes?"
  
  @IBOutlet weak var messageLabel: UILabel?
  @IBOutlet weak var textField: UITextField?
  
  @IBAction func sendButtonClicked() {
    let updatedValue = textField!.text!  // TODO: cannot be empty
    let updatedValueData = updatedValue.data(using: String.Encoding.utf8)
    
    let didSendValue = myPeripheralManager?.updateValue(updatedValueData!, for: myCharacteristic!, onSubscribedCentrals: nil)
    print("didSendValue: \(didSendValue)")
  }
  
  @IBAction func stopAdvertisingButtonClicked() {
    myPeripheralManager!.stopAdvertising()
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
    
    // Syntax: bitwise OR equals square bracket
    
    // TODO: read and notify permissions cannot be added to myCharacteristic
    /*
    myCharacteristic = CBMutableCharacteristic.init(type: myCharacteristicUUID,
                                                    properties: [CBCharacteristicProperties.read,
                                                                 CBCharacteristicProperties.write,
                                                                 CBCharacteristicProperties.notify],
                                                    value: myValueData! as Data,
                                                    permissions: [CBAttributePermissions.readable,
                                                                  CBAttributePermissions.writeable])
    */
    // OK. if myCharacteristic is set to be read-only, it is cached so didReceiveReadRequest would never be called.
    /*
    myCharacteristic = CBMutableCharacteristic.init(type: myCharacteristicUUID,
                                                    properties: [CBCharacteristicProperties.read],
                                                    value: myValueData! as Data,
                                                    permissions: [CBAttributePermissions.readable])
    */
    
    // Run-time exception. Don't initialize characteristic value if it includes permissions other than readbale. Respond the value in didReceiveReadRequest instead
    /*
    myCharacteristic = CBMutableCharacteristic.init(type: myCharacteristicUUID,
                                                    properties: [CBCharacteristicProperties.read,
                                                                 CBCharacteristicProperties.write,
                                                                 CBCharacteristicProperties.notify],
                                                    value: nil,
                                                    permissions: [CBAttributePermissions.readable,
                                                                  CBAttributePermissions.writeable])
    myCharacteristic!.value = myValueData! as Data
    */
    
    myCharacteristic = CBMutableCharacteristic.init(type: myCharacteristicUUID,
                                                    properties: [CBCharacteristicProperties.read,
                                                                 CBCharacteristicProperties.write,
                                                                 CBCharacteristicProperties.notify],
                                                    value: nil,
                                                    permissions: [CBAttributePermissions.readable,
                                                                  CBAttributePermissions.writeable])
    myService = CBMutableService.init(type: myServiceUUID, primary: true)
    
    if var characteristics = myService?.characteristics {  // tricky optional unwraping
      characteristics.append(myCharacteristic!)
    } else {
      myService!.characteristics = [myCharacteristic!]
    }
    myPeripheralManager!.add(myService!)
    
    myPeripheralManager!.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [myService!.uuid]])
    
    print("startAdvertising.")
  }
  
  func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
    if (error != nil) {
      print(error!)
    }
  }
  
  func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
    if (error != nil) {
      print(error!)
    }
  }
  
  func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
    print("didReceiveRead: \(request)")
    
    let myValueData = myValue.data(using: String.Encoding.utf8)
    
    if (request.characteristic.uuid == myCharacteristic!.uuid) {
      /*
      // TODO: not sure "count" method call is correct
      if (request.offset > myCharacteristic!.value!.count) {
        myPeripheralManager?.respond(to: request, withResult: CBATTError.invalidOffset)
        return
      }
      
      let dataRange = Range(uncheckedBounds: (request.offset + 1, myCharacteristic!.value!.count))
      /* this code is used when the characteristic is read-only. This method is not called anyway
      request.value = myCharacteristic!.value?.subdata(in: dataRange)
      */
      request.value = myValueData!.subdata(in: dataRange)
      */
      
      // EXPERIMENT: transfer data in one response even if it may be large'
      request.value = myValueData!
      myPeripheralManager?.respond(to: request, withResult: CBATTError.success)
      print("respond: \(request)")
    }
  }
  
  func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {

    // potentially more than 1 request; only respond the first request
    myCharacteristic!.value = requests.first!.value
    
    print("didReceiveWrite requests: \(myCharacteristic!.value)")
    // update text label
    let myNewValue = String(data: myCharacteristic!.value!, encoding: String.Encoding.utf8)!
    messageLabel!.text = myNewValue
  }
  
  func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
    print("\(central) didSubscribeTo: \(characteristic)")
    
    //subscribedCharacteristic = characteristic
  }

}
