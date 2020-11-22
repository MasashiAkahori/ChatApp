//
//  Extensions.swift
//  ChatWith
//
//  Created by 赤堀雅司 on 2/10/20.
//


import UIKit

let imageCache = NSCache<NSString, AnyObject>()
//ここにキャッシュ化されたものが保存される

//イメージなどをURLから読み込むような処理をしていると、毎回読み込みに時間がかかります。そこでイメージをキャシュ化し、iOSのメモリに保存します。それにより、再度読み込む必要がなくなり、処理を高速化します。
//NSCache の型　-> key, value のセット(保存したいデータがvalue, 保存したデータを取り出すためのkey)

extension UIImageView {
  
  //this extension can be used when you use UIImageView
  func loadImageUsingCacheWithUrlString(_ urlString: String) {
    //引数は読み込むURL(String)とする

    self.image = nil

    if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
      //引数で渡されたurlが既にキャッシュとして保存されている場合 --> キャッシュからimageを取り出し、self.image に代入
      self.image = cachedImage
      return
    }
    
    
    //引数で渡されたURLがまだキャッシュに保存されていない時
    //以下でキャッシュ化する
    let url = URL(string: urlString)
    
    //URLSessionクラスのdataTaskメソッドで、urlを元にして、バックグランドでサーバーと通信を行う。
    //{(data,...　以降は通信が終了したときに実行される
    //dataはサーバーからの返り値。(Image のデータ)
    //responseは、HTTPヘッダーやHTTPステータスコードなどの情報。
    //リクエストが失敗したときに、errorに値が入力される。
    URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
      //非同期で通信を行う
      //http通信を行い、そのURLから様々なデータを取得するときに用いる
      
      if error != nil {
        print(error)
        return
      }
      
      //UIKitのオブジェクトは必ずメインスレッドで実行しなければならないので、DispatchQueue.mainでメインキューに処理を追加する。非同期で登録するので、asyncで実装。
      DispatchQueue.main.async {
        //iosではUIの処理はメインスレッドで実行しなければならない
        //DispatchQueue ->送信待ち行列 処理待ちタスクを追加するときに使う
        //DispatchQueue.main は直列処理、UI表示系のタスクはここで行わないと動かない(UIの表示を変える等)
        
        if let downloadedImage = UIImage(data: data!) {
          
          
          imageCache.setObject(downloadedImage, forKey: urlString as NSString)
          //keyをimageUrlStringとして、imageToCacheをキャッシュとして保存する。
          
          self.image = downloadedImage
        }
        
      }
      
    }).resume()
  }
}


//memo
//HTTPSが使用されているURLから特定されるリソースを非同期で提供するシステムこれをするために、URLSessionをつかう
//URLSession は関連するネットワーク上のデータ転送処理群をまとめるクラス
//基本的なリクエストはsharedを使ってデータを取得する
//URLSessionDataTask -> response in memory -> not supported in background sessions


