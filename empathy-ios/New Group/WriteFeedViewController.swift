//
//  WriteFeedViewController.swift
//  empathy-ios
//
//  Created by Suji Kim on 22/11/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit

class WriteFeedViewController: UIViewController {

    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var titleWordCountLabel: UILabel!
    @IBOutlet weak var detailWordCountLabel: UILabel!
    @IBOutlet weak var selectedPictureImageView: UIImageView!
    
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        titleTextView.delegate = self
        titleTextView.isScrollEnabled = false
        detailTextView.delegate = self
        detailTextView.isScrollEnabled = false
    }
    @IBAction func tapCancel(_ sender: UIButton) {
    }
    
    @IBAction func tapConfirm(_ sender: UIButton) {
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
        if textView.text == "" {
            switch textView {
            case titleTextView :
                textView.text = "제목을 입력해주세요."
                titleWordCountLabel.text = "0/20"
                textView.textColor = UIColor.lightGray
            default:
                textView.text = "설명을 입력해주세요."
                detailWordCountLabel.text = "0/40"
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
}
