//
//  LoginController+handlers.swift
//  ChatWith
//
//  Created by 赤堀雅司 on 29/9/20.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func handleRegister() {
    //ユーザーを登録する時の処理
    guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
      print("Form is not valid")
      return
    }
    
    
    Auth.auth().createUser(withEmail: email, password: password, completion: { (AuthResult, error) in
      if error != nil {
        print(error ?? "Firebase error")
        return
      }
      //この時点でauthに登録された
      //これ以降はデータベースに登録する作業
      
      //      let uid = UUID().uuidString
      
      guard let uid = AuthResult?.user.uid else {
        return
      }
      
      let imageName = NSUUID().uuidString
      //imageName　はimageごとにランダムな文字列にする
      let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
      //storageの参照を決める(root)
      //if let uploadData = self.profileImageView.image!.jpegData(compressionQuality: 0.1) {
      
      if let profileImage = self.profileImageView.image, let uploadData = self.profileImageView.image!.jpegData(compressionQuality: 0.1) {
        
        
        
        //      if let uploadData = self.profileImageView.image!.pngData() {
        //profileImageViewに設定されている画像を保存するため、画像を選んだ段階では、その画像をprofileImageViewに設定することをすればよい
        //profileImageViewに画像が何かしらあったら(nilでない時)
        storageRef.putData(uploadData, metadata: nil, completion: { (_, err) in
          //upload するデータはpngData
          //Metadata contains the detail of files info like size content-type etc...
          //MARK:- putData --> その階層にデータを置く
          //MARK:- downloadURL --> その階層の写真をダウンロードする
          //このfunction の中ではこれらを同時にしている
          if let error = err {
            print(error)
            return
          }
          storageRef.downloadURL(completion: {(url, err) in
            if let err = err {
              print(err)
              return
            }
            guard let url = url else {
              //if url is empty
              return
            }
            let values = ["name": name, "email": email, "profileImageUrl": url.absoluteString]
            
            self.registerUserIntoDatabaseWithUID(uid, values: values as [String: AnyObject])
            //values の中にはname, email, profileImageUrl の情報が入っている状態(dictionary型で)
          })
        })
      }
      
      
    })
  }
  
  
  
  fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
    //values の中にはname, email, profileImageUrl の情報が入っている状態(dictionary型で)
    //入力されたデータを元に、データベースにユーザーを登録する
    let ref = Database.database().reference()
    let userReference = ref.child("users").child(uid)
    
    userReference.updateChildValues(values, withCompletionBlock: {(err, ref) in
      //users > uid(ユーザーによって異なる)と言う名前のディレクトリの後のchildを変更(更新)する--> values
      if err != nil {
        print(err)
        return
      }
      
      
      // self.messagesController.navigationItem.title = values["name"] as? String
      
      let user = User(dictionary: values)
      //values の中にはname, email, profileImageUrl の情報が入っている状態(dictionary型で)
      //dictionary: values はinitializeしている(User.swift参照)
      self.messagesController.setupNavBarWithUser(user)
      self.dismiss(animated: true, completion: nil)
    })
  }
  
  @objc func handleSelectProfileImageView() {
    //This function is called when The Person icon is tapped
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.allowsEditing = true
    
    present(picker, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    //Pickerで写真が選ばれた後の処理を記述する
    
    let info = convertFromUIImagePickerControllerInfoKeyDictionay(info)
    //info is the information of a pic that the user picked
    
    var selectedImageFromPicker: UIImage?
    
    if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
      selectedImageFromPicker = editedImage
    }  else if let originalImage = info["UIImagePIckerCOntrollerOriginalImage"] as? UIImage {
      selectedImageFromPicker = originalImage
    }
    
    if let selectedImage = selectedImageFromPicker {
      profileImageView.image = selectedImage
    }
    dismiss(animated: true, completion: nil)
    
    print(info)
  }
  
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
}


fileprivate func convertFromUIImagePickerControllerInfoKeyDictionay(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
  //infoはUIImagePickerCOntrollerMediaTypeやURL, fileの位置等様々な情報が記入されているが、dictionaryの最初の文字がStringでないため、扱いづらい　そこで、この関数でdictionary の最初の文字をstringに変換し、didFinishPickingMediaWithInfoで扱いやすくしている
  return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
