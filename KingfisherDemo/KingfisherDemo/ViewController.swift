//
//  ViewController.swift
//  KingfisherDemo
//
//  Created by wangcong on 06/06/2017.
//  Copyright © 2017 ApterKing. All rights reserved.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {

    let imageURL = URL(string: "http://ww1.sinaimg.cn/large/92ce04b2gy1fgapuwrc3nj23gq2g6twu.jpg")

    let imageView: UIImageView = {
        let imgv = UIImageView(frame: CGRect(x: UIScreen.main.bounds.size.width / 2 - 100, y: UIScreen.main.bounds.size.height / 2 - 100, width: 200, height: 200))
        return imgv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.addSubview(imageView)

        /* ##############################   ImageCache   ######################## */
        // ImageCache，默认是
        var cache = ImageCache.default

        // 设置内存缓存的大小，默认是0 表示no limit (10M）
        cache.maxMemoryCost = 10 * 1024 * 1024

        // 磁盘缓存大小，默认0 表示no limit （50 * 1024）
        cache.maxDiskCacheSize = 50 * 1024 * 1024

        // 设置缓存周期 (默认1 week）
        cache.maxCachePeriodInSecond = 60 * 60 * 24 * 7

        // 存储一张图片, Key 可用于后期检索资源、删除以及在删除时的一个通知参数
        cache.store(UIImage(named: "test")!, forKey: "test")

        // 删除
        cache.removeImage(forKey: "test")

        // 检索图片
        let imgDisk = cache.retrieveImageInDiskCache(forKey: "test")
        let imgMemo = cache.retrieveImageInMemoryCache(forKey: "test")

        // 异步检索
        cache.retrieveImage(forKey: "test", options: nil) { (_, _) in

        }

        // 清除
        cache.clearDiskCache()
        cache.clearMemoryCache()
        cache.clearDiskCache {

        }

        // 清除过期缓存
        cache.cleanExpiredDiskCache()
        cache.cleanExpiredDiskCache {

        }
        cache.backgroundCleanExpiredDiskCache() // 后台清理，但不需要回调

        // 判定图片是否存在
        let cached = cache.isImageCached(forKey: "test")

        // 监听数据移除
        NotificationCenter.default.addObserver(self, selector: #selector(cleanDiskCache), name: NSNotification.Name.init("KingfisherDidCleanDiskCacheNotification"), object: nil)

        /* ##############################   ImageDownloader   ######################## */
        var downloader = ImageDownloader.default

        // 设置可信任的Host
        let hosts: Set<String> = ["http://xxxxx.com", "http://#####.com"]
        downloader.trustedHosts = hosts

        // 设置sessionConfiguration
        downloader.sessionConfiguration = URLSessionConfiguration.default

        // 设置代理，详情参考 ImageDownloaderDelegate
        downloader.delegate = self

        // 下载超时设置
        downloader.downloadTimeout = 20

        // 下载图片
        let retriveTask = downloader.downloadImage(with: URL(string: "http://xxx.com")!, retrieveImageTask: nil, options: nil, progressBlock: nil, completionHandler: {
            (_, _, _, _) in
        })

        // 取消下载
        retriveTask?.cancel()

        /* ##############################   KingfisherManager   ######################## */ 
        let kfManager = KingfisherManager.shared

        // 通过manager 获取cache
        cache = kfManager.cache

        // 通过manager 获取downloader
        downloader = kfManager.downloader

        // 设置options
        kfManager.defaultOptions = [.forceRefresh, .backgroundDecode, .onlyFromCache, .downloadPriority(1.0)]

        // 检索
        let resource = ImageResource(downloadURL: imageURL!, cacheKey: "test")
        let retriveImageTask = kfManager.retrieveImage(with: resource, options: nil, progressBlock: nil, completionHandler: {
            (_, error, _, _) in
            if error == nil {
                print("检索图片成功")
            } else {
                print("检索图片失败")
            }
        })
        retriveImageTask.cancel()

        /* ######################  UIImageView+Kingfisher ########################## */
        // 设置网络图片
        imageView.kf.setImage(with: ImageResource(downloadURL: imageURL!))

        imageView.kf.setImage(with: ImageResource(downloadURL: imageURL!), placeholder: UIImage(named: "test"), options: nil, progressBlock: nil, completionHandler: nil)

        // UIImageView 也可以设置取消加载 (两种方式）
        imageView.kf.cancelDownloadTask()

        let retriveImaeTask = imageView.kf.setImage(with: ImageResource(downloadURL: imageURL!))
        retriveImaeTask.cancel()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func cleanDiskCache(notification: Notification) {

    }

}

extension ViewController: ImageDownloaderDelegate {

    // 将要加载图片
    func imageDownloader(_ downloader: ImageDownloader, willDownloadImageForURL url: URL, with request: URLRequest?) {

    }

    // 下载图片成功
    func imageDownloader(_ downloader: ImageDownloader, didDownload image: Image, for url: URL, with response: URLResponse?) {

    }

    // 哪些statusCode可以通过
    func isValidStatusCode(_ code: Int, for downloader: ImageDownloader) -> Bool {
        return code == 200
    }

}
