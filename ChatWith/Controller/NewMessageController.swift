//
//  NewMessagesController.swift
//  ChatWith
//
//  Created by 赤堀雅司 on 29/9/20.
//

import UIKit
import Firebase
import FirebaseDatabase

class NewMessageController: UITableViewController {

  let cellId = "cellId"
  var users = [User]()
  //usersはUser.swift をモデルにした

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    //tableViewにcellを登録する(どのcellを使うか指定する)
    //cellを再利用する際はregister function を事前に呼び出しておく
    //用意したcell今回の場合、(UserCell) をcellのテンプレートとして登録する
    tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    //table view（またはcollection view）を使うとき、多くの場合カスタムセルクラスを作ってtable viewにregisterしてからdequeueする、という決まった手順を踏むことになる
    //tableViewにデータをセットする

    fetchUser()
  }

  func fetchUser() {
    //in this part, fetch the user infornmations to set the cells
    Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
      //usersはすべてのユーザーの情報が載っているリスト

      //observe(.childAdded はアイテム(要素)のリストを取得するfunction

      //その他のfunction↓
      //observe(.childChanged はリスト内のアイテム(要素)に変更がないか確認するfunction(子ノードが変更されるとトリガーされる)
      //observe(.childRemoved はリストから削除されるアイテムがないか確認するfunction(子ノードが削除されるとトリガーされる)
      //observe(.childMoved はリストの項目の順番が変更を確認する(並べ替えかされるたびにトリガーされる)
      //print(snapshot)
      //now, snapshot include email value and name value like this.

      //      Snap (FAE5B252-D923-4E61-A18B-72E0DEED1FF3) {
      //          email = "Test1@gmail.com";
      //          name = Panda2;
      //      }

      if let dictionary = snapshot.value as? [String: AnyObject] {
        //ここでいうuserはメッセージを送る相手のことをいう
        let user = User(dictionary: dictionary)

        user.id = snapshot.key
        self.users.append(user)

        DispatchQueue.main.async(execute: {
          self.tableView.reloadData()
        })

      }
    }, withCancel: nil)

  }



  @objc func handleCancel() {
    dismiss(animated: true, completion: nil)
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
    //dequeueReusableCell(withIdentifier:for:)　は再利用可能なcellがあればそれを、なければ新しく作成したcellを返すことでロードの回数を減らすことができる
    //Reuse Queue
    //TableViewは裏側でreuse queueというものを持っており、reuseIdentifierごとにreuse queueが存在します。画面外に出たcellは、自身のidentifierに紐づいたreuse queueに追加されます。そして、同じidentifierのcellが表示されようとする時、queueから取り出されます。

    let user = users[indexPath.row]
    //usersを順に呼び出す
    cell.textLabel?.text = user.name
    cell.detailTextLabel?.text = user.email

    //cell.imageView?.image = UIImage(systemName: "person")
    //cell.imageView?.contentMode = .ScaleAspectFill

    if let profileImageUrl = user.profileImageUrl {
      cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
    }




    //textLabelにはその列のindexPathに対応したnameを、detailTextlabelにはその列のindexPathに対応したemailを表示させるようにする
    return cell

  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 72
  }

  var messagesController: MessagesController?

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //ユーザーのリストの中から、欄をタップすると、ユーザーのリストを消し、ChatControllerを表示させる
    dismiss(animated: true) {
      print("Dismiss completed")
      let user = self.users[indexPath.row]
      self.messagesController?.showChatControllerForUser(user)
    }

  }




}


