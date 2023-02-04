//
//  DetailsVC.swift
//  artBook
//
//  Created by Fırat İlhan on 23.11.2022.
//

import UIKit
import CoreData


class DetailsVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            saveButton.isHidden = true
            // core data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name  = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
                
            } catch {
                print("hata")
                
            }
        }
        else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
           
        }

        let gestureRegocnizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRegocnizer)
                
        //kullanıcı görsele tıklayabilsin...
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    
        let klavyeKapat = UITapGestureRecognizer(target: self, action: #selector(kapatt))
        view.addGestureRecognizer(klavyeKapat)
        
    }
    
    @objc func kapatt() {
        view.endEditing(true)
    }
   

   
    
    @IBAction func saveButton(_ sender: Any) {
      
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
        newPainting.setValue(UUID(),forKey: "id")
        
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "year")
        }
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        
        newPainting.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("Başarılı")
        } catch {
            print("hata var")
        }
        
     // NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        // self.navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    //galeriye ulaşabilmek için picker kullanıyoruz...
    @objc func selectImage(){
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func hideKeyboard(){
        //ekranda boş yere tıklandığında klavyeyi kapatmaya yarar
        view.endEditing(true)
    }
}
