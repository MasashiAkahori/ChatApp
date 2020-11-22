//
//  ViewController.swift
//  ChatWith
//
//  Created by 赤堀雅司 on 17/9/20.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class MessagesController: UITableViewController {

  let cellId = "cellId"

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    let image = UIImage(systemName: "square.and.pencil")
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
    navigationItem.title = "Guest"
    checkIfUserIsLoggedIn()

    tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    //observeMessages()
    observeUserMessages()
  }

  var messages = [Message]()
  //this array is now empty
  var messagesDictionary = [String: Message]()
  //this dictionary is now empty

  func observeUserMessages() {
    //ユーザーが受け取ったメッセージを表示するメソッド
    guard let uid = Auth.auth().currentUser?.uid else {
      return
    }

    let ref = Database.database().reference().child("user-messages").child(uid)
    ref.observe(.childAdded, with: {(snapshot) in

      let messageId = snapshot.key
      let messagesReference = Database.database().reference().child("messages").child(messageId)

      messagesReference.observeSingleEvent(of: .value, with: {(snapshot) in
        print(snapshot)

        if let dictionary = snapshot.value as? [String: AnyObject] {
          let message = Message(dictionary: dictionary)
          //self.messages.append(message)
          //print(message.text)

          if let chatPartnerId = message.chatPartnerId() {
              self.messagesDictionary[chatPartnerId] = message

              self.messages = Array(self.messagesDictionary.values)

              self.messages.sort(by: { (message1, message2) -> Bool in

                  return message1.timestamp?.int32Value > message2.timestamp?.int32Value
              })
          }

          self.timer?.invalidate()
          self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
          
        }


      }, withCancel: nil)

    }, withCancel: nil)
  }

  var timer: Timer?
  
  @objc func handleReloadTable() {
    DispatchQueue.main.async (execute: {
    self.tableView.reloadData()
  })
    
  }
  

  //  override func numberOfSections(in tableView: UITableView) -> Int {
  //    return messages.count
  //  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell

    let message = messages[indexPath.row]
    cell.message = message

    return cell
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 72
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let message = messages[indexPath.row]

    guard let chatPartnerId = message.chatPartnerId() else {
      return
    }
    let ref = Database.database().reference().child("users").child(chatPartnerId)
    ref.observeSingleEvent(of: .value, with: {(snapshot) in
      print(snapshot)
      guard let dictionary = snapshot.value as? [String: AnyObject] else {
        return
      }
      let user = User(dictionary: dictionary)
      //user.setValuesForKeysWithDictionary(dictionary)
      user.id = chatPartnerId
      self.showChatControllerForUser(user)

    }, withCancel: nil)
  }


  @objc func handleNewMessage() {
    //tableViewの右のボタンを押したときに呼ばれるfunction
    //ボタンを押した時、NewMessageControllerが表示される
    let newMessageController = NewMessageController()
    newMessageController.messagesController = self
    //newMessageController は今から開かれるページ
    //流れ
    //MessageControllerの右上のボタンを押す --> newMessageController内のmessagesControllerをこのMessageController()と指定する-->
    //NewMessageController() 内の messagesController というものをこのコントローラ自身にする(MessagesController)(そのままだとoptionalで、initializeされていない)
    let navController = UINavigationController(rootViewController: newMessageController)
    present(navController, animated: true, completion: nil)
    //presentを使いたい時は、NavigationController にしないといけない
  }


  func checkIfUserIsLoggedIn() {
    //アプリを開いたときに実行されるfunction
    //uidが既にあるかどうか確認する
    if Auth.auth().currentUser?.uid == nil {
      //Auth.auth().currentUser で現在loginしているユーザーの情報にアクセスできる
      //uid(ユーザーID)がない時、handleLogoutを実行する
      perform(#selector(handleLogout), with: nil, afterDelay: 0)
    } else {
      //uid(ユーザーID)がある時、fetchUserAndSetupnavBarTitleを実行する
      fetchUserAndSetupnavBarTitle()
    }
  }


  func fetchUserAndSetupnavBarTitle() {
    //uid があった時
    guard let uid = Auth.auth().currentUser?.uid else {
      return
    }
    Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in

      //observeSingleEnventは1度だけトリガーするmethodで、データの１回読み取りに使う
      //snapshot にはdictionaryの情報が入っている(databseに入れた情報など)



      if let dictionary = snapshot.value as? [String: AnyObject] {

        //    self.navigationItem.title = dictionary["name"] as? String

        let user = User(dictionary: dictionary)
        self.setupNavBarWithUser(user)
      }
    }, withCancel: nil)
  }

  func setupNavBarWithUser(_ user: User) {

    messages.removeAll()
    messagesDictionary.removeAll()
    tableView.reloadData()

    observeUserMessages()

    let titleView = UIView()
    titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
    //titleView.backgroundColor = UIColor.red

    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    titleView.addSubview(containerView)


    let profileImageView = UIImageView()
    profileImageView.translatesAutoresizingMaskIntoConstraints = false
    profileImageView.contentMode = .scaleAspectFill
    profileImageView.layer.cornerRadius = 20
    profileImageView.clipsToBounds = true
    //画面外に、その画像が表示されないように制限

    if let profileImageUrl = user.profileImageUrl {
      profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
    }

    containerView.addSubview(profileImageView)
    //need x y width height
    profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
    profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
    profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true

    let nameLabel = UILabel()

    containerView.addSubview(nameLabel)

    nameLabel.text = user.name
    nameLabel.translatesAutoresizingMaskIntoConstraints = false
    //need x y width height
    nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
    nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
    nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
    nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true

    containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
    containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true

    self.navigationItem.titleView = titleView






  }

  @objc func showChatControllerForUser(_ user: User) {
    let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
    chatLogController.user = user
    navigationController?.pushViewController(chatLogController, animated: true)
  }

  @objc func handleLogout() {
    do {
      try Auth.auth().signOut()
      //Auth.auth().signOut() でauth に登録してあるlogin情報をサインアウトに変更できる(signIn --> signOut に変える)
    } catch let logoutError {
      print(logoutError)
    }

    let loginController = LoginController()
    loginController.messagesController = self
    // = self　はviewを更新したいときに用いる
    //今回の場合、selfは MessageController: UITableViewControllerであるので、上部のtitle等が更新される
    present(loginController, animated: true, completion: nil)
    //present　は他のViewを割り込むように表示させるメソッド
    print("Logout")
  }

}


//memo
//アプリを開いたときに、uidがあればデータベースから情報を取得し、ユーザーネームを設定する
//アプリを開いたときに、uidがなければ、logoutし、loginController(ログインする画面)を表示させる








