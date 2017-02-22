//
//  MainViewController.swift
//  BluetoothCenter
//
//  Created by Yingbo Wang on 2/20/17.
//  Copyright © 2017 Yingbo Wang. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
    
  @IBAction func centralButtonClicked() {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    storyboard.instantiateViewController(withIdentifier: "CentralViewController")
  }
  
  @IBAction func peripheralButtonClicked() {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    storyboard.instantiateViewController(withIdentifier: "PeripheralViewController")
  }
}
