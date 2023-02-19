//
//  ViewController.swift
//  Dojin_Map
//
//  Created by 大場洋介 on 2020/02/09.
//  Copyright © 2020 BonscowCompany. All rights reserved.
//

import UIKit

var circles = [[String]]()
//var circlesMenuImage = [UIImage]()
var tableCellNum = -1

class ViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    private var MainScrollView: UIScrollView!
    private var mapScrollView: UIScrollView!
    private var tableView: UITableView!
    private var pageControl: UIPageControl!
    private var navigationBar: UINavigationBar!
//    @IBOutlet var RightEdgePanGesture: UIScreenEdgePanGestureRecognizer!
    var mainScrollcoor = 0
    let userDefaults = UserDefaults.standard
    //var tempImage = [Data]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        view.backgroundColor = UIColor.lightGray
//        RightEdgePanGesture.edges = .right
        // Do any additional setup after loading the view.
        //readCSV()
        
        if userDefaults.object(forKey: "circles") == nil /*|| userDefaults.object(forKey: "circlesMenuImage") == nil*/{
            userDefaults.set(circles, forKey: "circles")
            //userDefaults.set(tempImage, forKey: "circlesMenuImage")
        }
        
        circles = userDefaults.array(forKey: "circles") as! [[String]]
        //tempImage = userDefaults.array(forKey: "circlesMenuImage") as! [Data]
        //circlesMenuImage = [UIImage]()
//        for i in 0 ..< tempImage.count {
//            circlesMenuImage.append(UIImage(data: tempImage[i])!)
//        }
        
        //print("tempImage.count = " , tempImage.count)
//        print("circlesMenuImage.count = " , circlesMenuImage.count)
        
        creatScrollView()
        creatNavigationBar()
        tableView.tableFooterView = UIView()
    }
    
    func creatNavigationBar(){
        //navigationBarの生成
        navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 33, width: self.view.frame.size.width, height: 60))
        //navigationItemの生成
        let navigationItem: UINavigationItem = UINavigationItem(title: "同人マップ")
        //ナビゲーションバー右のボタンを設定
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "＋", style: UIBarButtonItem.Style.plain, target: self, action: #selector(barButtonTapped(_:)))
        
        navigationItem.leftBarButtonItem = self.editButtonItem
        //Viewにナビゲーションバーを追加
        self.view.addSubview(navigationBar)
        //ナビゲーションバーにアイテムを追加
        navigationBar.pushItem(navigationItem, animated: true)
    }
    
    //+ボタンが押された時の挙動
    @objc func barButtonTapped(_ sender: UIBarButtonItem) {
        mainScrollcoor = Int(MainScrollView.contentOffset.x)
        self.performSegue(withIdentifier: "ModelSegue", sender: self)
    }
    
    func creatScrollView(){
        //MainScrollViewの画面上の大きさを指定
        MainScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        //MainScrollViewのページ数(配列的意味のサイズ)(普通に実質的に入る容量のサイズ)を横向き縦向きそれぞれに指定
        MainScrollView.contentSize = CGSize(width: self.view.frame.size.width * 2, height: self.view.frame.size.height)
        MainScrollView.contentOffset.x = CGFloat(mainScrollcoor)
        //MainScrollViewの画面遷移をMainScrollView自身で行う
        MainScrollView.delegate = self
        //MainScrollViewの水平方向のスクロールバーを非表示
        MainScrollView.showsHorizontalScrollIndicator = false
        //MainScrollViewでページ単位でスクロールする
        MainScrollView.isPagingEnabled = true
        //ViewControllerにMainScrollViewをSubviewとして追加
        self.view.addSubview(MainScrollView)
        //MainScrollViewの1ページ目に画像を追加(ページ指定はwidthの幅)
        creatMapScrollView()
        
        self.tableView = {
            let tableView = UITableView(frame: CGRect(x: self.view.frame.size.width, y: 76, width: self.view.frame.size.width, height: self.view.frame.size.height - 176), style: .plain)
            tableView.autoresizingMask = [
                .flexibleWidth,
                .flexibleHeight
            ]
            
            tableView.delegate = self
            tableView.dataSource = self

            MainScrollView.addSubview(tableView)
            
            return tableView
        }()
        
        // pageControlの表示位置とサイズの設定
        pageControl = UIPageControl(frame: CGRect(x: 0, y: self.view.frame.size.height - 50, width: self.view.frame.size.width, height: 30))
        // pageControlのページ数を設定
        pageControl.numberOfPages = 2
        // pageControlのドットの色
        pageControl.pageIndicatorTintColor = UIColor.gray
        // pageControlの現在のページのドットの色
        pageControl.currentPageIndicatorTintColor = UIColor.white
        self.view.addSubview(pageControl)
        
        /*let imageView2 = createImageView(x: self.view.frame.size.width, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height, image: "bamper.jpg")
        MainScrollView.addSubview(imageView2)*/
    }
    
    func creatMapScrollView(){
        mapScrollView = UIScrollView(frame: CGRect(x: 0, y: 76, width: self.view.frame.size.width, height: self.view.frame.size.height - 176))
        mapScrollView.contentSize = CGSize(width: 3313, height: 4683)
        mapScrollView.delegate = self
        mapScrollView.bounces = false
        mapScrollView.showsHorizontalScrollIndicator = true
        mapScrollView.showsVerticalScrollIndicator = true
        MainScrollView.addSubview(mapScrollView)
        let imageView = createImageView(x: 0, y: 0, width: 3313, height: 4683, image: "testMap.jpg")
        mapScrollView.addSubview(imageView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == MainScrollView{
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        }
//        else if scrollView == mapScrollView{
//            //MainScrollView.contentOffset.x = 0
//            //MainScrollView.isScrollEnabled = false
//        }
    }
    
//    //EdgePanについて
//    @IBAction func EdgePanGesture(_ sender: UIScreenEdgePanGestureRecognizer) {
//        mapScrollView.isScrollEnabled = false
//        print("Edge")
//    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return circles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        //イベントのラベルをcellに追加
        let circleLabel = UILabel() // ラベルの生成
        circleLabel.frame = CGRect(x: 10, y: 0, width: UIScreen.main.bounds.size.width, height: 44) // 位置とサイズの指定
        circleLabel.textAlignment = NSTextAlignment.left // 横揃えの設定
        circleLabel.text = circles[indexPath.row][0] // テキストの設定
        circleLabel.textColor = UIColor.black // テキストカラーの設定
        circleLabel.font = UIFont(name: "HiraKakuProN-W6", size: 17) // フォントの設定
        cell.addSubview(circleLabel) // ラベルの追加
        
        //サークル名を追加
        cell.textLabel?.text = circles[indexPath.row][1]
        
        //説明やつ
        cell.detailTextLabel?.text = circles[indexPath.row][5]
        
        //場所のラベルを追加
        let placeLabel = UILabel() // ラベルの生成
        placeLabel.frame = CGRect(x: UIScreen.main.bounds.size.width-110, y: 28, width: 100, height: 44) // 位置とサイズの指定
        placeLabel.textAlignment = NSTextAlignment.right // 横揃えの設定
        placeLabel.text = circles[indexPath.row][2] + circles[indexPath.row][3] + circles[indexPath.row][4] // テキストの設定
        placeLabel.textColor = UIColor.black // テキストカラーの設定
        placeLabel.font = UIFont(name: "HiraKakuProN-W6", size: 17) // フォントの設定
        cell.addSubview(placeLabel) // ラベルの追加
//        let placeLabel = UILabel() // ラベルの生成
//        placeLabel.frame = CGRect(x: UIScreen.main.bounds.size.width-10, y: 28, width: UIScreen.main.bounds.size.width, height: 44) // 位置とサイズの指定
//        placeLabel.textAlignment = NSTextAlignment.right // 横揃えの設定
//        placeLabel.text = circles[indexPath.row][2] + circles[indexPath.row][3] + circles[indexPath.row][4] // テキストの設定
//        placeLabel.textColor = UIColor.black // テキストカラーの設定
//        placeLabel.font = UIFont(name: "HiraKakuProN-W6", size: 17) // フォントの設定
//        cell.addSubview(placeLabel) // ラベルの追加
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected! \(circles[indexPath.row])")
        tableCellNum = indexPath.row
        self.performSegue(withIdentifier: "CircleSegue", sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    //セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        //override前の処理を継続してさせる
        super.setEditing(editing, animated: animated)
        //tableViewの編集モードを切り替える
        tableView.isEditing = editing //editingはBool型でeditButtonに依存する変数
    }

    //スワイプしたセルを削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            print("indexPath.row = " , indexPath.row)
            
            var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
            let fileName = "\(circles[indexPath.row][7]).png"
            // DocumentディレクトリのfileURLを取得
            if documentDirectoryFileURL != nil {
                // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
                let path = documentDirectoryFileURL!.appendingPathComponent(fileName)
                documentDirectoryFileURL = path
            }
            /*do {
                try FileManager.default.removeItem( atPath: path(documentDirectoryFileURL!) )
            } catch {
                //エラー処理
                print("menu画像削除error")
            }*/
            userDefaults.removeObject(forKey: "\(circles[indexPath.row][7])")
            circles.remove(at: indexPath.row)
            //tempImage.remove(at: indexPath.row)
            //circlesMenuImage.remove(at :indexPath.row)
            
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
            userDefaults.set(circles, forKey: "circles")
            
            //userDefaults.set(tempImage, forKey: "circlesMenuImage")
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            return .delete
        }
        return .none
    }
    
    func createImageView(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, image: String) -> UIImageView {
        let imageView = UIImageView(frame: CGRect(x: x, y: y, width: width, height: height))
        let image = UIImage(named:  image)
        imageView.image = image
        return imageView
    }
    
//    func readCSV(){
//        guard let csvPath = Bundle.main.path(forResource: "circle", ofType: "csv")
//        else {
//            print("error")
//            return
//        }
//        do{
//            let csvString = try String(contentsOfFile: csvPath, encoding: String.Encoding.utf8)
//            circles = csvString.components(separatedBy: .newlines)
//            //csvファイルに強制で入る最終行をcircles配列から削除
//            circles.removeLast()
//        }catch let error as NSError {
//            print("エラー: \(error)")
//            return
//        }
//    }
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue){
    if(unwindSegue.identifier=="BackSegue"){
         }
     }
    
    func setupMethod(){
        userDefaults.set(circles, forKey: "circles")
        //tempImage.append(circlesMenuImage[circlesMenuImage.count - 1].pngData()!)
//        for i in 0 ..< circlesMenuImage.count {
//            tempImage[i] = circlesMenuImage[i].pngData()!
//        }
        //userDefaults.set(tempImage, forKey: "circlesMenuImage")
        MainScrollView.removeFromSuperview();
        viewDidLoad()
    }
}

