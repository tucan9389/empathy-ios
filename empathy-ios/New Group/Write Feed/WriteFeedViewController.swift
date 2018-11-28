//
//  WriteFeedViewController.swift
//  empathy-ios
//
//  Created by Suji Kim on 22/11/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit

class WriteFeedViewController: UIViewController {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var titleWordCountLabel: UILabel!
    @IBOutlet weak var detailWordCountLabel: UILabel!
    @IBOutlet weak var selectedPictureImageView: UIImageView!
    @IBOutlet weak var privateSwitch: UISwitch!
    
    @IBOutlet weak var topHorizontalLineConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomHorizontalLineConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingVerticalLineConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingVerticalLineConstraint: NSLayoutConstraint!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        titleTextView.delegate = self
        titleTextView.isScrollEnabled = false
        detailTextView.delegate = self
        detailTextView.isScrollEnabled = false
        
        privateSwitch.onTintColor = #colorLiteral(red: 0.1647058824, green: 0.1725490196, blue: 0.2039215686, alpha: 1)
        dateLabel.text = getCurrentDate()
        
        topHorizontalLineConstraint.constant = view.frame.width/3
        bottomHorizontalLineConstraint.constant = view.frame.width/3
        leadingVerticalLineConstraint.constant = view.frame.width/3
        trailingVerticalLineConstraint.constant = view.frame.width/3
        
        
        selectedPictureImageView.image = image
        hideKeyboardByTap()
    }
    
    @IBAction func tapCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapConfirm(_ sender: UIButton) {
    }
    
    func getCurrentDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "kr_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        return dateFormatter.string(from: date)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension WriteFeedViewController : UITextViewDelegate {
    // MARK: - UITextViewDelegates
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        // TO-DO : 글을 옆으로 계속 칠 경우 (설명부분) -> 밑으로 이동이 안됨
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                if estimatedSize.height > 58 {
                    constraint.constant = 58
                }
                else {
                    constraint.constant = estimatedSize.height
                    
                    // TO-DO : 엔터 두번치고나서 더이상 입력이 안 되도록하기
                }
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "제목을 입력해주세요." || textView.text == "설명을 입력해주세요." {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        switch textView {
        case titleTextView :
            titleWordCountLabel.text = "\(textView.text.count)/20"
            if textView.text.count == 0 {
                textView.text = "제목을 입력해주세요."
                textView.textColor = UIColor.lightGray
            }
        default:
            detailWordCountLabel.text = "\(textView.text.count)/40"
            if textView.text.count == 0 {
                textView.text = "설명을 입력해주세요."
                textView.textColor = UIColor.lightGray
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var length = 20
        if textView == titleTextView {
            length = 20
            titleWordCountLabel.text = "\(textView.text.count)/20"
        }
        else {
            length = 40
            detailWordCountLabel.text = "\(textView.text.count)/40"
        }
        
        return textView.text.count + (text.count - range.length) <= length
    }
    
    func hideKeyboardByTap() {
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
