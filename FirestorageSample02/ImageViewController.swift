//
//  ImageViewController.swift
//  FirestorageSample02
//
//  Created by Togami Yuki on 2019/01/23.
//  Copyright © 2019 Togami Yuki. All rights reserved.
//

import UIKit
import Firebase

class ImageViewController: UIViewController {

    @IBOutlet weak var saveImageView: UIImageView!
    let userdefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userdefaults.register(defaults: ["imgNum": 0])
        
    }
    //保存する画像の選択
    @IBAction func selectImage(_ sender: UIButton) {
        print("画像の選択")
        imagePickUp()
    }
    //Firestorageに画像を保存
    @IBAction func saveImage(_ sender: UIButton) {
        print("画像の保存")
        saveToStrage(image:saveImageView.image!)
    }
    //Firestorageに入れた画像を読み出す
    @IBAction func readImage(_ sender: UIButton) {
        print("画像の読み出し")
    }
    
}

//イメージピッカーに関して
extension ImageViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    //ImagePickerの表示
    func imagePickUp(){
        let picker: UIImagePickerController! = UIImagePickerController()
        //ライブラリから画像を選択
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        //デリゲートの設定
        picker.delegate = self
        //ピッカーの表示
        present(picker, animated: true, completion: nil)
    }
    //画像が選択された時に呼ばれる関数
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            saveImageView.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
}

//Firestoreに関して
extension ImageViewController{
    //ストレージに画像を保存
    func saveToStrage(image:UIImage){
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL:"gs://firestoragesample02.appspot.com")//作成したストレージのURLを入れる
        //保存する画像を置く場所のPath生成
        let reference = storageRef.child("images/\(fileName())")
        //保存する画像をNSData型へ
        let data = image.pngData()
        //storageに画像を保存
        reference.putData(data!, metadata: nil, completion: { metaData, error in
            print("memo:metaData",metaData)
            print("memo:error",error)
            print("memo:データの保存完了")
        })
    }
    //ファイル名の生成
    func fileName()->String{
        var imgNum = userdefaults.object(forKey: "imgNum") as! Int
        imgNum = imgNum + 1
        userdefaults.set(imgNum, forKey: "imgNum")
        return "togamin\(imgNum)"
    }
}

//Firestorageに関して
extension ImageViewController{
    
}
