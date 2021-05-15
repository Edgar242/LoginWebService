//
//  ViewController.swift
//  LoginWebService
//
//  Created by Edgar on 07/05/21.
//

import UIKit
import Alamofire
import CryptoKit
import Network

class ViewController: UIViewController {

    @IBOutlet weak var txtUser: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBAction func btnEnviar(_ sender: Any) {

        
        if !checkInternetConexion() {
            return
        }
        
        if !validateTextFields() {
            return
        }
        
//        Equipo1
//        aA&8DcB%WX
        
        let passwordCifrado = cifrar(txtPassword.text!)
        let laUrl = "http://janzelaznog.com/DDAM/iOS/WS/login.php"
        let parametros = ["username": txtUser.text!, "password": passwordCifrado]
        AF.request(laUrl, method:.post, parameters: parametros).responseJSON { response in

            print(response)
            
            if case .success(let value) = response.result {
                if let dict = response.value as? [String: Any] {
                    let codigo = (dict["code"] as? String) ?? ""
                    if codigo == "200" { // logingOK
                        // Suponiendo que el login es correcto
                        self.showAlert(context: self, title: "Success", message: "Login exitoso!")
//                        self.performSegue(withIdentifier: "loginOK", sender: self)
                    }
                    
                }
            }
                

        }
    }
    
    func checkInternetConexion() -> Bool {
        let monitor = NWPathMonitor(requiredInterfaceType: .wifi)  // monitoreamos todas las interfaces de datos
        if monitor.currentPath.status == .satisfied {
            print ("Conexion a internet disponible")
            return true
        } else {
            print ("Internet is \(monitor.currentPath.status)")
        }
//        monitor.start(queue: .global())
//        let queue = DispatchQueue(label: "Monitor")
//        var internetEstatus = 1
        monitor.pathUpdateHandler = { Path in
            var message = ""
            if Path.status == .satisfied {
                message = "Conexion a internet disponible"
                if Path.isExpensive {
                        //                    internetEstatus = 0 // Plan de datos
                        message += "Plan de datos"
        
                } else {
                    message += "Es por WiFi"
                }
            } else {
//                internetEstatus = -1 // No hay internet
                message = "Internet is \(Path.status)"
            }
            self.showAlert(context: self, title: "Internet Status", message: message)
        } // closure: bloque de código, que se puede usar como una variable
        
        let queueNetworkMonitor = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queueNetworkMonitor)
        
//
//        if internetEstatus != 1 { // No hay internet o es solo celular
//            print("No internet")
//            return false
//        }
//        print("Internet, ok!")
//        return true
        return false
    }
    
    func validateTextFields() -> Bool {
        if txtUser.text == nil || txtPassword.text == nil {
            return false
        }
        if txtUser.text!.isEmpty || txtPassword.text!.isEmpty {
            showAlert(context: self, title: "Error", message: "Fields cannot be empty")
            return false
        }
        
        if txtPassword.text?.count != 10 {
            print ("Error password length must be of 10")
            showAlert(context: self, title: "Error", message: "Password length must be of 10 characters")
            return false
        }
        
        return true
    }
    
    func showAlert(context: UIViewController, title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let aa = UIAlertAction(title: "ok", style: .default, handler: nil)
        ac.addAction(aa)
        context.present(ac, animated:true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let monitor = NWPathMonitor()  // monitoreamos todas las interfaces de datos
        monitor.pathUpdateHandler = { Path in
            var internetEstatus = 1
            if Path.status == .satisfied {
                if Path.isExpensive {
                    internetEstatus = 0
                    print("Plan de datos de celular")
                }
                else {
                    // Si hay conexión a internet por WiFi, entonces que descargue los datos
//                    self.descargarInfo()
                    print("WiFi conexion")
                }
            }
            else {
                internetEstatus = -1
                print("no internet")
            }
            if internetEstatus != 1 { // No hay internet o es solo celular
                DispatchQueue.main.async {  // ES INDISPENSABLE regresar al hilo principal para poder presentar el alert, porque implica un cambio en la UI
                    let alert = UIAlertController(title:"Internet Status", message:"", preferredStyle: .alert)
                    var boton1:UIAlertAction
                    if internetEstatus == 0 {
                        alert.message = "Conexion a internet disponible por datos celulares, desea descargar la info?"
                        boton1 = UIAlertAction(title:"cancelar", style:.destructive, handler: nil)
                        let boton2 = UIAlertAction(title: "adelante", style: .default, handler:{ elAlert in
//                            self.descargarInfo()
                        })
                        alert.addAction(boton2)
                    }
                    else {
                        alert.message = "Conexion a internet NO disponible"
                        boton1 = UIAlertAction(title:"enterado", style: .default, handler: nil)
                    }
                    alert.addAction(boton1)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } // closure: bloque de código, que se puede usar como una variable
        let elKiu = DispatchQueue (label: "NetworkMonitor")
        monitor.start(queue: elKiu)
        
    }
    
    func cifrar(_ str: String) -> String {
        guard let bytes = str.data(using: .utf8) else { return "" }
        let passCifrado = SHA512.hash(data: bytes)
        let stringFinal = passCifrado.compactMap{ String(format: "%02x", $0)}.joined()
        
        return stringFinal
    }
}
