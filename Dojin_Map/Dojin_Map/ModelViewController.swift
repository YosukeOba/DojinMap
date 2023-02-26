//
//  ModelViewController.swift
//  Dojin_Map
//
//  Created by 大場洋介 on 2020/02/10.
//  Copyright © 2020 BonscowCompany. All rights reserved.
//

import UIKit
import Foundation

class ModelViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let NoImage = UIImage(named: "No_Image.png")

    @IBOutlet weak var circleTextField: UITextField!
    @IBOutlet weak var placeWordTextField: UITextField!
    @IBOutlet weak var placeNumTextField: UITextField!
    @IBOutlet weak var memoTextField: UITextField!
    @IBOutlet weak var twitterTextField: UITextField!
    @IBAction func circleAddButton(_ sender: Any) {
        if(String(circleTextField.text!) != "" && String(placeWordTextField.text!) != "" && String(placeNumTextField.text!) != "" && Int(placeNumTextField.text!)! != 0) {
            //twitterIDをチェック
            if(!isTwitterID(id: twitterTextField.text!)) {
                //エラー時
                let dialog = UIAlertController(title: "入力エラー", message: "不正なtwitterIDです", preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(dialog, animated: true, completion: nil)
            } else {

                let primaryKey = generatePrimaryKey()
                circles.append([event, String(circleTextField.text!), String(placeWordTextField.text!), String(placeNumTextField.text!), placeABset, String(memoTextField.text!), String(twitterTextField.text!), primaryKey])
                //imageが入ってるか確認
                if ImgImageView.image == nil {
                    print("NoImage")
                    saveImage(image: NoImage!, filename: primaryKey)
                } else {
                    saveImage(image: ImgImageView.image!, filename: primaryKey)
                }
                print("CircleAdd")
                print(circles)
                self.performSegue(withIdentifier: "BackSegue", sender: Any?.self)
            }
        } else {
            let dialog = UIAlertController(title: "入力エラー", message: "サークル名と場所の入力は必須です", preferredStyle: .alert)
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(dialog, animated: true, completion: nil)
        }
    }

    @IBAction func imgAddButton(_ sender: Any) {
        let picker = UIImagePickerController() //アルバムを開く処理を呼び出す
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
        self.present(picker, animated: true, completion: nil)
    }
    @IBOutlet weak var eventPickerView: UIPickerView!
    @IBOutlet weak var placeABPickerView: UIPickerView!
    @IBOutlet weak var ImgImageView: UIImageView!

    let viewcontroller = ViewController();
    let events = ["C98 1日目", "C98 2日目", "C98 3日目", "C98 4日目"]
    let placeAB = ["a", "b", "ab"]
    var event: String = ""
    var placeWord: String = ""
    var placeNum: Int = 0
    var placeABset: String = ""
    var selectedTextField: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light

        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        print("model")
        event = events[0]
        placeABset = placeAB[0]
        circleTextField.delegate = self
        placeWordTextField.delegate = self
        placeNumTextField.delegate = self
        memoTextField.delegate = self
        twitterTextField.delegate = self
        eventPickerView.delegate = self
        eventPickerView.dataSource = self
        placeABPickerView.delegate = self
        placeABPickerView.dataSource = self

        placeWordTextField.autocorrectionType = .no
        placeWordTextField.autocapitalizationType = .allCharacters
        twitterTextField.autocorrectionType = .no
        twitterTextField.autocapitalizationType = .none
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func textFieldDidChange(notification: NSNotification) {
        let textField = notification.object as! UITextField
        if let text = textField.text {
            switch textField {
            case placeWordTextField:
                if text.count > 1 {
                    textField.text = String(text.prefix(1))
                }
            case placeNumTextField:
                if text.count > 2 {
                    textField.text = String(text.prefix(2))
                }
            default: break
            }
        }
    }

    //textFieldがタップされた(editが開始された)
    func textFieldDidBeginEditing(_ textField: UITextField) {
        NotificationCenter.default.removeObserver(self)
        if textField == twitterTextField || textField == memoTextField {
            // Notificationを設定する
            switch textField {
            case twitterTextField: selectedTextField = "twitterTextField"
            case memoTextField: selectedTextField = "memoTextField"
            default: break
            }
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        } else {
            print("twitterTextField is not selected")
            if self.view.frame.origin.y != 0 {
//                self.view.frame.origin.y = 0
                UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.view.frame.origin.y = 0
                }, completion: nil)
            }

            NotificationCenter.default.addObserver(self, selector: #selector(self.textFieldDidChange(notification:)), name: UITextField.textDidChangeNotification, object: placeWordTextField)
            NotificationCenter.default.addObserver(self, selector: #selector(self.textFieldDidChange(notification:)), name: UITextField.textDidChangeNotification, object: placeNumTextField)

        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == eventPickerView {
            return events.count
        } else if pickerView == placeABPickerView {
            return placeAB.count
        } else {
            return -1
        }
    }
    // UIPickerViewの最初の表示
    func pickerView(_ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int) -> String? {
        if pickerView == eventPickerView {
            return events[row]
        } else if pickerView == placeABPickerView {
            return placeAB[row]
        } else {
            return nil
        }
    }

    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int) {
        if pickerView == eventPickerView {
            event = events[row]
        } else if pickerView == placeABPickerView {
            placeABset = placeAB[row]
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            ImgImageView.image = selectedImage
            //imageViewにカメラロールから選んだ画像を表示する
        }
        self.dismiss(animated: true) //画像をImageViewに表示したらアルバムを閉じる
    }

    // 画像選択がキャンセルされた時に呼ばれる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    //UserDefaults のインスタンス生成
    let userDefaults = UserDefaults.standard

    // ドキュメントディレクトリの「ファイルURL」（URL型）定義
    var documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last

    func createLocalDataFile(filename: String) {
        // 作成するテキストファイルの名前
        let fileName = "\(filename).png"

        // DocumentディレクトリのfileURLを取得
        if documentDirectoryFileURL != nil {
            // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
            let path = documentDirectoryFileURL!.appendingPathComponent(fileName)
            documentDirectoryFileURL = path
        }
    }

    //画像を保存する関数の部分
    func saveImage(image: UIImage, filename: String) {
        createLocalDataFile(filename: filename)
        //pngで保存する場合
        let pngImageData = image.pngData()
        do {
            try pngImageData!.write(to: documentDirectoryFileURL!)
            //②「Documents下のパス情報をUserDefaultsに保存する」
            userDefaults.set(documentDirectoryFileURL, forKey: filename)
            print(filename)
        } catch {
            //エラー処理
            print("エラー")
        }
    }

    //キーボードが表示時に画面をずらす。
    @objc func keyboardWillShow(notification: NSNotification) {
        print("keyboardWillShowを実行")
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                switch selectedTextField {
                case "twitterTextField": self.view.frame.origin.y -= keyboardSize.height / 2
                case "memoTextField": self.view.frame.origin.y -= keyboardSize.height / 3
                default: break
                }
            } else {
                switch selectedTextField {
                case "twitterTextField":
                    let twitterSuggestionHeight = self.view.frame.origin.y + keyboardSize.height / 2
                    self.view.frame.origin.y -= twitterSuggestionHeight
                case "memoTextField":
                    let memoSuggestionHeight = self.view.frame.origin.y + keyboardSize.height / 3
                    self.view.frame.origin.y -= memoSuggestionHeight
                default: break
                }
            }
        }
    }
    //キーボードが降りたら画面を戻す
    @objc func keyboardWillHide(_ notification: Notification?) {
        print("keyboardWillHideを実行")
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    //戻るSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "BackSegue") {
            let vc = segue.destination as! ViewController
            vc.setupMethod()
        }
    }

    func generatePrimaryKey() -> String {
        if userDefaults.object(forKey: "primaryKey") == nil {
            userDefaults.set("0", forKey: "primaryKey")
        }
        let num = userDefaults.integer(forKey: "primaryKey")
        print(num)
        let numStr = String(num + 1)
        userDefaults.set(numStr, forKey: "primaryKey")
        return String(num)
    }

    private func isTwitterID(id: String) -> Bool {
        let NSid = id as NSString
        let pattern = "^[A-Za-z0-9_]{0,15}$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            print("false")
            return false
        }
        let matches = regex.matches(in: id, options: [], range: NSMakeRange(0, NSid.length))
        print("match", matches.count)
        return matches.count == 1
    }
}
