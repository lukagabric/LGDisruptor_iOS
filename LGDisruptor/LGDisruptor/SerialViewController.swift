//
//  SerialViewController.swift
//  HM10 Serial
//
//  Created by Alex on 10-08-15.
//  Copyright (c) 2015 Balancing Rock. All rights reserved.
//

import UIKit
import CoreBluetooth
import QuartzCore

/// The option to add a \n or \r or \r\n to the end of the send message
enum MessageOption: Int {
    case noLineEnding,
         newline,
         carriageReturn,
         carriageReturnAndNewline
}

/// The option to add a \n to the end of the received message (to make it more readable)
enum ReceivedMessageOption: Int {
    case none,
         newline
}

final class SerialViewController: UIViewController, UITextFieldDelegate, BluetoothSerialDelegate
{
    private var msg: String = "0,0"

    var timer: Timer!
    

    init()
    {
        super.init(nibName: "SerialViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Connect", style: .plain, target: self, action: #selector(barButtonPressed(_:)))
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
            print(self.msg)
            serial.sendMessageToDevice(self.msg)
        })
        
        // init serial
        serial = BluetoothSerial(delegate: self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func reloadView() {
        // in case we're the visible view again
        serial.delegate = self

        let barButton = navigationItem.leftBarButtonItem!
        
        if serial.isReady {
            navigationItem.title = serial.connectedPeripheral!.name
            barButton.title = "Disconnect"
            barButton.tintColor = UIColor.red
            barButton.isEnabled = true
        } else if serial.centralManager.state == .poweredOn {
            navigationItem.title = "Bluetooth Serial"
            barButton.title = "Connect"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = true
        } else {
            navigationItem.title = "Bluetooth Serial"
            barButton.title = "Connect"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = false
        }
    }
        

//MARK: BluetoothSerialDelegate
    
    func serialDidReceiveString(_ message: String)
    {
        var message = message
        let pref = UserDefaults.standard.integer(forKey: ReceivedMessageOptionKey)
        if pref == ReceivedMessageOption.newline.rawValue { message += "\n" }
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?)
    {
        reloadView()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Disconnected"
        hud?.hide(true, afterDelay: 1.0)
    }
    
    func serialDidChangeState()
    {
        reloadView()
        if serial.centralManager.state != .poweredOn
        {
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.mode = MBProgressHUDMode.text
            hud?.labelText = "Bluetooth turned off"
            hud?.hide(true, afterDelay: 1.0)
        }
    }
    
//MARK: IBActions
    
    private func map(x: Int, inMin: Int, inMax: Int, outMin: Int, outMax: Int) -> Int
    {
      return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
    }
    
    @IBAction func panAction(_ sender: UIPanGestureRecognizer)
    {
        let view = sender.view!
        let rawLoc = sender.location(in: view)
        let loc = CGPoint(
            x: max(0, min(rawLoc.x, view.frame.size.width)),
            y: max(0, min(rawLoc.y, view.frame.size.height))
        )
        let mappedLoc = CGPoint(
            x: map(x: Int(loc.x), inMin: 0, inMax: Int(view.frame.size.width), outMin: 50, outMax: 140),
            y: map(x: Int(loc.y), inMin: 0, inMax: Int(view.frame.size.height), outMin: 93, outMax: 113)
        )
        msg = "\(Int(mappedLoc.y)),\(Int(mappedLoc.x))\n"
    }
    @IBAction func fireAction(_ sender: Any)
    {
        serial.sendMessageToDevice("999,999\n")
    }
    
    @IBAction func barButtonPressed(_ sender: AnyObject)
    {
        if serial.connectedPeripheral == nil
        {
            let scanner = UIStoryboard(name: "ScannerView", bundle: nil).instantiateInitialViewController()!
            present(scanner, animated: true, completion: nil)
        }
        else
        {
            serial.disconnect()
            reloadView()
        }
    }
}
