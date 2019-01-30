//
//  ImageViewController.swift
//  FirestorageSample02
//
//  Created by Togami Yuki on 2019/01/23.
//  Copyright © 2019 Togami Yuki. All rights reserved.
//


//容量の大きい画像が上手く読み込まれない問題(未解決).
//①アップロードする際にサイズを落とす。
//②ダウンロードする際にサイズを落とす(SDWebImageを利用して非同期で画像データを取得する方法が不明)。
    /*
 
    islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
        if let error = error {
        } else {
            let image = UIImage(data: data!)
        }
    }
 
    */
//③サイズが大きくても読み込めるようにする。
//⓸そもそも読み込まれない問題は画像サイズの問題ではない。



import UIKit
import Firebase
import SDWebImage
import FirebaseUI

class ImageViewController: UIViewController {

    @IBOutlet weak var saveImageView: UIImageView!
    let userdefaults = UserDefaults.standard
    var db:Firestore!
    var imageNameList:[String] = []
    let margin:CGFloat = 3//コレクションセルの幅
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    //ストレージサービスへの参照を取得。
    let storage = Storage.storage()
    //ストレージへの参照を入れるための変数。
    var storageRef:StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userdefaults.register(defaults: ["imgNum": 0])
        //ストレージサービスへの参照
        db = Firestore.firestore()
        //ストレージへの参照
        storageRef = storage.reference(forURL:"ストレージのURL")
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        
        readURL()
        
        myCollectionView.register(UINib(nibName:"CollectionViewCell",bundle:nil),forCellWithReuseIdentifier:"Cell")
    }
    //保存する画像の選択
    @IBAction func selectImage(_ sender: UIButton) {
        print("画像の選択")
        imagePickUp()
    }
    //Firestorageに画像を保存
    @IBAction func saveImage(_ sender: UIButton) {
        print("画像の保存")
        //Firestorageに画像を保存。URLをFirestoreへ。
        saveToStrage(image:saveImageView.image!)
    }
    //Firestorageに入れた画像を読み出す
    @IBAction func readImage(_ sender: UIButton) {
        print("画像の読み出し")
        readURL()
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

//Firestore、storageに関して
extension ImageViewController{
    //ストレージに画像を保存
    func saveToStrage(image:UIImage){
        //保存する画像を置く場所のPath生成
        let name:String = fileName()
        let reference = storageRef.child("image/\(name)")
        //pathをFirestoreへ
        saveURL(data:["fileName":name])
        //保存する画像をNSData型へ
        let data = image.pngData()
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        //storageに画像を保存
        reference.putData(data!, metadata: meta, completion: { metaData, error in
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
    //URLをFirestoreに保存する関数
    func saveURL(data:[String:Any]){
        print("memo:FirestoreにURLを保存",data)
        db.collection("ImageName").addDocument(data: data){err in
            if let err = err{
                print("memo:失敗",err)
            }else{
                print("memo:データの書き込み成功")
            }
        }
    }
    //画像の読み込み
    func readURL(){
        imageNameList = []
        db.collection("ImageName").getDocuments(){getData,err in
            if let err = err{
                print("読み込み失敗",err)
            }else{
                for document in (getData?.documents)!{
                    self.imageNameList.append(document.data()["fileName"] as! String)
                }
                self.myCollectionView.reloadData()
            }
            print("memo",self.imageNameList)
        }
    }
}

//コレクションViewに関して
extension ImageViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNameList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        let reference = storageRef.child("image/\(imageNameList[indexPath.row])")
        
        print("memo:reference",reference)
        
        //読み込めない場合はとがみんの写真が表示される。
        cell.myImageView.sd_setImage(with: reference, placeholderImage:UIImage(named: "togaminnnn.jpg"))
        
        return cell
    }
    //セルのサイズ指定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = myCollectionView.frame.width//コレクションViewの幅
        let cellNum:CGFloat = 1
        let cellSize = (width - margin * (cellNum + 1))/cellNum//一個あたりのサイズ
        return CGSize(width:cellSize,height:cellSize)
    }
    //セル同士の縦の間隔を決める。
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    //セル同士の横の間隔を決める。
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    
    
}
