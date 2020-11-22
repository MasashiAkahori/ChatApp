//
//  UserCell.swift
//  ChatWith
//
//  Created by 赤堀雅司 on 4/11/20.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class UserCell: UITableViewCell {

  var message: Message? {
    didSet {

      setupNameAndProfileImage()

      detailTextLabel?.text = message?.text

      if let secondes = message?.timestamp?.doubleValue {
        let timestampDate = Date(timeIntervalSince1970: secondes)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a"
        timeLabel.text = dateFormatter.string(from: timestampDate)
      }
    }
  }

  private func setupNameAndProfileImage() {
    let chatPartnerId: String?
    if message?.fromId == Auth.auth().currentUser?.uid {
      //メッセージの送り主とユーザーが一致した時
      chatPartnerId = message?.toId
    } else {
      chatPartnerId = message?.fromId
    }

    if let id = chatPartnerId {
      //if toId has some value...
      let ref = Database.database().reference().child("users").child(id)
      ref.observeSingleEvent(of: .value, with: { (snapshot) in
        //observeSingleEnventは1度だけトリガーするmethodで、データの１回読み取りに使う
        //この時、refにある情報を読み取る
        //snapshot にはdictionaryの情報が入っている(databseに入れた情報など)

        if let dictionary = snapshot.value as? [String: AnyObject] {
          //if snapshot has some value like dictionary...
          self.textLabel?.text = dictionary["name"] as? String

          if let profileImageUrl = dictionary["profileImageUrl"] as? String {
            self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
          }
        }

      }, withCancel: nil)
    }
  }

  override func layoutSubviews() {
    //addSubviewした時、frameを変更した時に呼ばれるメソッド
    //手動で呼び出したい時はsetNeedsLayoutを呼ぶ
      super.layoutSubviews()

      textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)

      detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
  }

  let profileImageView: UIImageView = {
      let imageView = UIImageView()
      imageView.translatesAutoresizingMaskIntoConstraints = false
      imageView.layer.cornerRadius = 24
      imageView.layer.masksToBounds = true
      imageView.contentMode = .scaleAspectFill
      return imageView
  }()

  let timeLabel: UILabel = {
      let label = UILabel()
      //label.text = "HH:MM:SS"
      label.font = UIFont.systemFont(ofSize: 13)
      label.textColor = UIColor.darkGray
      label.translatesAutoresizingMaskIntoConstraints = false
      return label
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

      addSubview(profileImageView)
      addSubview(timeLabel)

      //ios 9 constraint anchors
      //need x,y,width,height anchors
      profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
      profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
      profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
      profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true

      //need x,y,width,height anchors
      timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
      timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
      timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
      timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
}



