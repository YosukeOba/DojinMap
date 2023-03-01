//
//  CircleViewController.swift
//  Dojin_Map
//
//  Created by 大場洋介 on 2020/02/18.
//  Copyright © 2020 BonscowCompany. All rights reserved.
//

import UIKit

class CircleViewController: UIViewController, UIScrollViewDelegate {

    let twitterLink = URL(string: "https://www.twitter.com/\(circles[tableCellNum][6])")

    @IBAction func twitterButton(_ sender: Any) {
        UIApplication.shared.open(twitterLink!)
    }
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var circleNavigationBar: UINavigationBar!
    @IBOutlet weak var memoScrollView: UIScrollView!
    var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)

        memoScrollView.delegate = self
        self.memoScrollView.minimumZoomScale = 1.0
        self.memoScrollView.maximumZoomScale = 2.0
        self.memoScrollView.isScrollEnabled = true
        self.memoScrollView.showsHorizontalScrollIndicator = true
        self.memoScrollView.showsVerticalScrollIndicator = true


        circleNavigationBar.items![0].title = circles[tableCellNum][1] + " " + circles[tableCellNum][2] + circles[tableCellNum][3] + circles[tableCellNum][4]

        twitterButton.setTitle("\(circles[tableCellNum][6])", for: .normal)

        // Documentsディレクトリのpathを得る
        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
        let fileURL = URL(fileURLWithPath: filePath!).appendingPathComponent("\(circles[tableCellNum][7]).png")
        print(fileURL.path)
        if let image = UIImage(contentsOfFile: fileURL.path) {
            let image = UIImageView(image: image)
            imageView = image
            imageView.contentMode = UIView.ContentMode.scaleAspectFit
            print("指定されたファイルが見つかりました")
        } else {
            print("指定されたファイルが見つかりません")
        }
        memoScrollView.addSubview(imageView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let size = imageView.image?.size {
            // imageViewのサイズがscrollView内に収まるように調整
            let wrate = memoScrollView.frame.width / size.width
            let hrate = memoScrollView.frame.height / size.height
            let rate = min(wrate, hrate, 1)
            imageView.frame.size = CGSize(width: size.width * rate, height: size.height * rate)

            // contentSizeを画像サイズに設定
            memoScrollView.contentSize = imageView.frame.size
        }
    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        // ズームのために要指定
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print("end zoom")
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        print("start zoom")
    }

    func updateScrollInset() {
        // imageViewの大きさからcontentInsetを再計算
        // 0を下回らないようにする
        memoScrollView.contentInset = UIEdgeInsets(
            top: max((memoScrollView.frame.height - imageView.frame.height) / 2, 0),
            left: max((memoScrollView.frame.width - imageView.frame.width) / 2, 0),
            bottom: 0,
            right: 0
        );
    }
}
