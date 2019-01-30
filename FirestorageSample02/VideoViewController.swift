//
//  VideoViewController.swift
//  FirestorageSample02
//
//  Created by Togami Yuki on 2019/01/23.
//  Copyright © 2019 Togami Yuki. All rights reserved.
//

/*
 
 ①動画保存
 ②動画をストレージへ
 ③動画名とURLをFirestoreへ保存
 ⓸動画名とURLを取得し、テーブルに表示
 ⓹ダウンロードする動画選択
 ⓺動画ダウンロード＆視聴
 
 */

import UIKit
import Firebase

class VideoViewController: UIViewController {

    @IBOutlet weak var videoTableView: UITableView!
    var videoNameList:[String] = []
    var videoURLList:[String] = []
    var cellRowNum:Int!
    //ストレージサービスへの参照を取得。
    let storage = Storage.storage()
    //ストレージへの参照を入れるための変数。
    var storageRef:StorageReference!
    let userdefaults = UserDefaults.standard
    var db:Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        videoTableView.delegate = self
        videoTableView.dataSource = self
        
        //ストレージへの参照
        storageRef = storage.reference(forURL:"ストレージのURL")
        db = Firestore.firestore()
        
        userdefaults.register(defaults: ["movieNum": 0])
        
        readVideoName()
        
        
    }
    
    //動画を撮る。
    @IBAction func takeMovie(_ sender: UIButton) {
        print("動画を撮る")
        takeVideo()
    }
    //Firestoreにあるデータ(動画ファイル名)の読み込み
    @IBAction func getMovie(_ sender: UIButton) {
        readVideoName()
    }
    
}

//ビデオに関して
extension VideoViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func takeVideo(){
        //info.plistでカメラとマイクロフォンの許可をする。
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.SourceType.camera
        // ここで動画を選択
        picker.mediaTypes = ["public.movie"]
        //デリゲートの設定
        picker.delegate = self
        picker.videoQuality = .typeHigh
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        print("memo:動画を取得しました。")
        
        if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            //print("memo:URL",url)
            print("memo:videoNameListの中身",videoNameList)
            //filePathからFirestorageに保存する(ファイル名とデータをセットで)
            let name = fileName()
            saveToStrage(videoURL:url,videoName:name)
            
            //読み込み移す。
            videoNameList.append(name)
            self.videoTableView.reloadData()
        }
        picker.dismiss(animated: true, completion:nil)
    }
}

//Firebaseに関して
extension VideoViewController{
    //ストレージに動画を保存
    func saveToStrage(videoURL:URL,videoName:String){
        let reference = storageRef.child("movie/\(videoName)")
        let uploadTask = reference.putFile(from: videoURL, metadata: nil){ (metadata, error) in
            guard let metadata = metadata else {
                print("memo:アップロードエラー")
                return
            }
            reference.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("memo:アップロードエラー")
                    return
                }
                print("memo:動画URL",url)
                let urlString = url?.absoluteString
                self.saveName(data:["filename":self.fileName(),"url":urlString])
            }
        print("memo:ストレージ動画保存の関数動作")
        }
    }
    //ファイル名の生成
    func fileName()->String{
        var movieNum = userdefaults.object(forKey: "movieNum") as! Int
        movieNum = movieNum + 1
        userdefaults.set(movieNum, forKey: "movieNum")
        return "togamin\(movieNum)"
    }
    //Firestoreへの保存
    func saveName(data:[String:Any]){
        print("memo:FirestoreにURLを保存",data)
        db.collection("MovieName").addDocument(data: data){err in
            if let err = err{
                print("memo:失敗",err)
            }else{
                print("memo:データの書き込み成功")
            }
        }
    }
    //FirestoreからFile名,URLの呼び出し(未完)。
    func readVideoName(){
        videoNameList = []
        db.collection("MovieName").getDocuments(){getData,err in
            if let err = err{
                print("読み込み失敗",err)
            }else{
                for document in (getData?.documents)!{
                    self.videoNameList.append(document.data()["filename"] as! String)
                    self.videoURLList.append(document.data()["url"] as! String)
                }
            }
            self.videoTableView.reloadData()
            print("memo",self.videoNameList)
        }
    }
    
    
    
    
    
}

//TableViewに関して
extension VideoViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoNameList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        cell.textLabel?.text = videoNameList[indexPath.row]
        cell.detailTextLabel?.text = videoURLList[indexPath.row]
        return cell
    }
    //セルが選択されたときの処理
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        print("memo:セル",indexPath.row)
        cellRowNum = indexPath.row
        performSegue(withIdentifier: "toShowVideoViewController",sender: nil)
    }
    //遷移する際に呼ばれる関数
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toShowVideoViewController") {
            let showVideoVC = segue.destination as! ShowVideoViewController
            showVideoVC.title = videoNameList[cellRowNum]
            showVideoVC.videoURL = videoURLList[cellRowNum]
        }
    }
}
