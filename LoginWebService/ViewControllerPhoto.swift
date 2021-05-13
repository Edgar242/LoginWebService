//
//  ViewControllerPhoto.swift
//  LoginWebService
//
//  Created by Edgar on 08/05/21.
//

import UIKit
import Alamofire

class ViewControllerPhoto: UIViewController {

    var nombreFoto = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(nombreFoto)
        
        // TODO: Traer la imagen
        if let laURL = URL(string: "http://janzelaznog.com/DDAM/iOS/gaga/"+nombreFoto) {
            // Metodo 1
            // Facil pero no muy recomendable porque todo se ejecuta en el main thread
            do {
                let losBytes = try Data(contentsOf: laURL)
                self.showImage(losBytes)

            } catch {
                print("Error loading image content")
            }
            
            // Metodo 2
            // No tan fácil, pero mucho más recomendable
            AF.request(laURL, method: .get).response { response in
                if let losBytes = response.data {
                    self.showImage(losBytes)
                }
            }
            
        }
    }
    
    func showImage(_ losBytes: Data) {
        let laImagen = UIImage(data: losBytes)
        let contenedor = UIImageView(image: laImagen)
        contenedor.frame = self.view.frame.insetBy(dx: 20, dy: 20)
        contenedor.contentMode = .scaleAspectFit
        self.view.addSubview(contenedor)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
