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
        //       TAREA 2
        // 1 VALIDA  si hay conexión a internet
        // 2 Implementa las validaciones necesarias para que los cuadreos de texto no estén vacio y el password sea siempre de 10 caracteres
        // en ambos casos: pressenta los mesajes apropiados para el usuario
        
        if !checkInternetConexion() {
            return
        }
        
        if !validateTextFields() {
            return
        }
        
        let passwordCifrado = cifrar(txtPassword.text!)
        let laUrl = "http://janzelaznog.com/DDAM/iOS/WS/login.php"
        let parametros = ["username": txtUser.text!, "password": passwordCifrado]
        AF.request(laUrl, method:.post, parameters: parametros).responseJSON { response in

            print(response)
            
            if case .success(let value) = response.result {
                self.showAlert(context: self, title: "Error", message: "During request \(value)")
                if let dict = response.value as? [String: Any] {
                    let codigo = (dict["code"] as? String) ?? ""
                    if codigo == "200" { // logingOK
                        // Suponiendo que el login es correcto
                        self.performSegue(withIdentifier: "loginOK", sender: self)
                    }
                }
            }
                

        }
    }
    
    func checkInternetConexion() -> Bool {
        let monitor = NWPathMonitor()  // monitoreamos todas las interfaces de datos
        monitor.start(queue: .global())
        let queue = DispatchQueue(label: "Monitor")
        var internetEstatus = 1
        monitor.pathUpdateHandler = { Path in
            if Path.status == .satisfied {
                print("There is Internet")
                if Path.isExpensive {
                    internetEstatus = 0 // Plan de datos
                    print("Plan de datos")
                }
            } else {
                internetEstatus = -1 // No hay internet
                print("No Internet")
            }
            monitor.start(queue: queue)
        } // closure: bloque de código, que se puede usar como una variable
        
        if internetEstatus != 1 { // No hay internet o es solo celular
            print("No internet")
            return false
        }
        print("Internet, ok!")
        return true
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
        
    }
    
    func cifrar(_ str: String) -> String {
        guard let bytes = str.data(using: .utf8) else { return "" }
        let passCifrado = SHA512.hash(data: bytes)
        let stringFinal = passCifrado.compactMap{ String(format: "%02x", $0)}.joined()
        
        return stringFinal
    }
}
