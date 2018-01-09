//
//  ViewController.swift
//  蓝牙Swift
//
//  Created by 曹相召 on 2018/1/8.
//  Copyright © 2018年 MOKO. All rights reserved.
//

import UIKit
import CoreBluetooth
class ViewController: UIViewController,CBCentralManagerDelegate, CBPeripheralDelegate {
    //添加属性
    var manager: CBCentralManager!             //中心设备类
    var peripheral: CBPeripheral!              //外围设备类
    var writeCharacteristic: CBCharacteristic! //设备特征类
    
    var textFiled:UITextField!
    var textLabel:UILabel!
    var sendButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.manager = CBCentralManager.init(delegate: self, queue: nil)
        self.initUI()
    }
    
    func initUI() -> Void {
        self.view.backgroundColor = UIColor.yellow
        self.textFiled = UITextField.init(frame: CGRect.init(x: 20, y: 100, width: 200, height: 40))
        self.textFiled.backgroundColor = UIColor.red
        self.view.addSubview(self.textFiled)
        
        self.sendButton = UIButton.init(frame: CGRect.init(x: 240, y: 100, width: 80, height: 40))
        self.sendButton.addTarget(self, action: #selector(sendButtonClick), for: .touchUpInside)
        self.sendButton.backgroundColor = UIColor.blue
        self.sendButton.setTitle("发送", for: .normal)
        self.view.addSubview(self.sendButton)

        self.textLabel = UILabel.init(frame: CGRect.init(x: 20, y: 180, width: self.view.frame.width - 40, height: 40))
        self.textLabel.backgroundColor = UIColor.brown
        self.view.addSubview(self.textLabel)
    }
    
    //发送点击事件
    @objc func sendButtonClick() -> Void {
        let sentStr = self.textFiled.text
        if((sentStr) != nil){
            let sentData = sentStr?.data(using: .utf8)
            //写入其他设备写入数据
            self.peripheral .writeValue(sentData!, for: self.writeCharacteristic, type: .withResponse)
        }
    }
    
    //写入数据的回调
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if(error != nil){
            print("写入设备 === \(String(describing: error?.localizedDescription))")
            return;
        }
        let data = characteristic.value
        if(data != nil){
            let dataStr = String.init(data: data!, encoding: .utf8)
            print("写入成功 === \(String(describing: dataStr))")
        }
        print("写入成功\(characteristic)")
    }
    
    //1.获取蓝牙的状态
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("unknown")
        case .resetting:
            print("resetting")
        case .unsupported:
            print("unsupported")
        case .unauthorized:
            print("unauthorized")
        case .poweredOff:
            print("poweredOff")
        case .poweredOn:
            do {
            print("poweredOn")
                //若蓝牙处于开状态,则开始扫描
                self.manager.scanForPeripherals(withServices: nil, options: nil)
               }
       }
    }
    
    //2.扫描外设
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("扫描出来的外设name:\(String(describing: peripheral.name)) as Any")
        if(peripheral.name == "曹相召的MacBook Pro"){
            //找到需要的蓝牙设备，停止搜索，保存数据
            self.manager.stopScan()        //停止扫描
            self.peripheral = peripheral  //记录连接的设备
            self.manager.connect(peripheral, options: nil)//连接
        }
    }
    
    //3.连接代理 didConnect(连接) didFailToConnect(连接失败) didDisconnectPeripheral(连接丢失)
    //1)连接成功
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("连接外设名称 ===\(String(describing: peripheral.name))")
        self.peripheral.delegate = self;
        self.peripheral.discoverServices(nil)
    }
    //2)连接失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("连接外设失败===\(String(describing: error))")
    }
    //3)丢失连接
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("丢失连接===\(String(describing: error))")
    }
    
    //4.获得外围设备的服务
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if((error) != nil){
            print("Discovered services \(String(describing: peripheral.name) ) \(String(describing: error?.localizedDescription))")
            return;
        }
        print("发现设备的服务")
        //服务并不是我们的目标，也没有实际意义。我们需要用的是服务下的特征，查询（每一个服务下的若干）特征
        for service:CBService in peripheral.services! {
            print("Service found with UUID : \(service.uuid)")
            service.peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    // 5.获得服务的特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if((error) != nil){
            print("didDiscoverCharacteristicsForService error : \(String(describing: error?.localizedDescription))")
            return;
        }
        print("获得服务的特征")
        for cha:CBCharacteristic in service.characteristics! {
            //Subscribing to a Characteristic’s Value 订阅
            peripheral.setNotifyValue(true, for: cha)
            //read the characteristic’s value，回调didUpdateValueForCharacteristic
            peripheral.readValue(for: cha)
            self.writeCharacteristic = cha;
        }
    }
    
    //收到数据的回调
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if(error != nil){
            print("didUpdateValueForCharacteristic error : \(String(describing: error?.localizedDescription))")
            return
        }
        let data = characteristic.value
        let dataStr = String.init(data: data!, encoding: .utf8)
        print("接收到的数据是dataStr === \(String(describing: dataStr))")
        self.textLabel.text = dataStr
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}

