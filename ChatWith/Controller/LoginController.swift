//
//  LoginController.swift
//  ChatWith
//
//  Created by 赤堀雅司 on 17/9/20.
//

import UIKit
import Firebase
import FirebaseAuth


class LoginController: UIViewController {
  
  var messagesController = MessagesController()
  
  let inputsContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.white
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = 5
    view.layer.masksToBounds = true
    //masksToBoundsをtrueにするとこの境界外に描画処理がされないようになる
    return view
  }()
  
  lazy var loginRegisterButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = UIColor(r: 191, g: 255, b: 29)
    button.setTitle("Login", for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitleColor(UIColor.white, for: .normal)
    //色の指定などにおいて、forの引数が　.normal --> 通常時, .highlighted --> タップした時の状態
    
    
    button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
    return button
  }()
  
  @objc func handleLoginRegister() {
    if loginRegisterSegmentedControl.selectedSegmentIndex == 0{
      handleLogin()
    } else {
      handleRegister()
    }
  }
  
  func handleLogin() {
    //ユーザーが既に登録されている時の処理
    guard let email = emailTextField.text, let password = passwordTextField.text else {
      print("Form is not valid")
      return
    }
    
    Auth.auth().signIn(withEmail: email, password: password, completion: {
      (user, error) in
      if error != nil {
        print(error)
        return
      }
      //login is successed
      self.messagesController.fetchUserAndSetupnavBarTitle()
      self.dismiss(animated: true, completion: nil)
    })
  }
  
  
  
  let nameTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Name"
    tf.translatesAutoresizingMaskIntoConstraints = false
    return tf
  }()
  
  let nameSeparatorView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  let emailTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Email"
    tf.translatesAutoresizingMaskIntoConstraints = false
    return tf
  }()
  
  let emailSeparatorView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  let passwordTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Password"
    tf.translatesAutoresizingMaskIntoConstraints = false
    tf.isSecureTextEntry = true
    return tf
    
  }()
  
  lazy var profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(systemName: "person")
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    
    imageView.isUserInteractionEnabled = true
    
    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
    
    
    return imageView
  }()
  
  let loginRegisterSegmentedControl: UISegmentedControl = {
    let sc = UISegmentedControl(items: ["Login", "Register"])
    //segmentのうち、Loginが0, registerが1
    sc.translatesAutoresizingMaskIntoConstraints = false
    sc.tintColor = UIColor.white
    sc.selectedSegmentIndex = 0
    //Loginを選んでいる状態にする
    
    sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
    return sc
  }()
  
  @objc func handleLoginRegisterChange() {
    //segmentが切り替えられた時の処理
    let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
    loginRegisterButton.setTitle(title, for: .normal)
    
    inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100: 150
    
    //change height of nameTextField
    nameTextFieldHeightAnchor?.isActive = false
    nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0: 1/3)
    //選んでいるsegmentがLoginの時(selectedSegmentIndex == 0の時)、nameTextFieldの高さの倍率を0に設定し、そうでない時(selectedSegmentIndex != 0の時)nameTextFieldの高さの倍率を1/3に設定する
    nameTextFieldHeightAnchor?.isActive = true
    
    //change height of emailTextField
    emailTextFieldHeightAnchor?.isActive = false
    emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
    emailTextFieldHeightAnchor?.isActive = true
    
    passwordTextFieldHeightAnchor?.isActive = false
    passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
    passwordTextFieldHeightAnchor?.isActive = true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    view.backgroundColor = UIColor(r: 191, g: 255, b: 29)
    view.addSubview(inputsContainerView)
    view.addSubview(loginRegisterButton)
    view.addSubview(profileImageView)
    view.addSubview(loginRegisterSegmentedControl)
    
    
    
    setupInputsContainerView()
    setupLoginRegisterButton()
    setupProfileImageView()
    setupLoginRegisterSegmentedControl()
    
    
  }
  
  func setupLoginRegisterSegmentedControl() {
    //need x, y, width, height constraints
    loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
    loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 2/3).isActive = true
    loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
  }
  
  func setupProfileImageView() {
    //need x, y, width, height constraints
    profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
    profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
    profileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
  }
  
  var inputsContainerViewHeightAnchor: NSLayoutConstraint?
  var nameTextFieldHeightAnchor: NSLayoutConstraint?
  var emailTextFieldHeightAnchor: NSLayoutConstraint?
  var passwordTextFieldHeightAnchor: NSLayoutConstraint?
  
  
  func setupInputsContainerView() {
    //need x, y, width, height constraints
    //Auto Layoutでは「制約（Constraint）」を設定することで、ビューの位置やサイズの決定します。
    //leadingAnchor -> 左端
    //trailingAnchor ->右端
    inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    //inputsContainerView のx軸の中心は　view のx軸中心と等しいことを記述している
    inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    //inputsContainerView のy軸の中心は　view のy軸の中心と等しいことを記述している
    inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
    //inputsContainerView の横幅は　viewの横幅より24px 短いことは記述している
    inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 100)
    
    inputsContainerViewHeightAnchor?.isActive = true
    
    //inputsContainerView の高さは　150px で固定することを記述している
    
    inputsContainerView.addSubview(nameTextField)
    inputsContainerView.addSubview(nameSeparatorView)
    inputsContainerView.addSubview(emailTextField)
    inputsContainerView.addSubview(emailSeparatorView)
    inputsContainerView.addSubview(passwordTextField)
    
    
    //need x, y, width, height constraints
    nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
    nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
    nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 0)
    nameTextFieldHeightAnchor?.isActive = true
    
    //need x, y, width, height constraints
    nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
    nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
    nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    
    emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
    emailTextField.topAnchor.constraint(equalTo: nameSeparatorView.bottomAnchor).isActive = true
    emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    
    
    emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2)
    
    emailTextFieldHeightAnchor?.isActive = true
    
    
    emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
    emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
    emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    
    
    
    passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
    passwordTextField.topAnchor.constraint(equalTo: emailSeparatorView.bottomAnchor).isActive = true
    passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    
    passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2)
    
    passwordTextFieldHeightAnchor?.isActive = true
    
    
    
  }
  
  func setupLoginRegisterButton() {
    //need x, y, width, height constraints
    loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
    loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    //StatusBar(時間やwifiの電波情報を表示する上のスペース)の色を黒色から白色にする
    return UIStatusBarStyle.lightContent
  }
  
  
  
}


extension UIColor {
  convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
    //convenience initializerは指定イニシャライザと違い、必須ではない
    //指定イニシャライザをラップし内部で指定イニシャライザを呼ぶ
    self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
  }
}
