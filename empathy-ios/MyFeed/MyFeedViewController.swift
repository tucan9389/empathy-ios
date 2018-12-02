//
//  MyFeedViewController.swift
//  empathy-ios
//
//  Created by byungtak on 23/11/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import Kingfisher
import Alamofire
import UIKit

class MyFeedViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    private let cellIdentifier = "my_feed_cell"
    private var myFeeds: [MyFeed] = []
    
    var imagePicker = UIImagePickerController()
    
    var userInfo:UserInfo?
    var myJourneyLists:[MyJourney]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        
        if let info = userInfo {
            fetchMyFeeds(ownerId: info.userId)
//            initializeNotificationObserver()
        }
        
//        //dummy
//        myFeeds.append(MyFeed(contents: "왕십리 시장 탐험을 다녀오다", creationTime: "11.03 2018", imageUrl: "", journeyId: 1, location: "서울", ownerProfileUrl: "", title: "왕십리 시장 텀험을 다녀오다"))
    }
    @IBAction func tapBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
//    @objc func didReceiveMyFeedsNotification(_ noti: Notification) {
//        guard let myFeeds: [MyFeed] = noti.userInfo?["myFeeds"] as? [MyFeed] else {
//            return
//        }
//
//        self.myFeeds = myFeeds
//
////        DispatchQueue.main.async {
//            if myFeeds.count == 0 {
//                self.emptyView.isHidden = false
//            } else {
//                self.emptyView.isHidden = true
//                self.tableView.reloadData()
//            }
////        }
//    }
    
//    private func initializeNotificationObserver() {
//        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveMyFeedsNotification(_:)), name: DidReceiveMyFeedsNotification, object: nil)
//    }
    
    private func showDeleteMyFeedAlert(indexPath: IndexPath) {
        let alertController = UIAlertController(title: "여정 삭제하기", message: "작성 하신 여정을 삭제하시겠어요?", preferredStyle: UIAlertController.Style.alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "삭제", style: .default) { (action: UIAlertAction) in
            self.myFeeds.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
//            self.tableView.reloadData()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func tapWriteFeed(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
}

extension MyFeedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myFeeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: MyFeedTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? MyFeedTableViewCell else {
            return UITableViewCell()
        }
        
        let myFeed = myFeeds[indexPath.row]
    
        cell.roundView.layer.cornerRadius = cell.roundView.frame.size.width / 2
        cell.roundView.clipsToBounds = true
        cell.dateMonth.text = "11.03"
        cell.dateYear.text = "2017"
        cell.title.text = myFeed.title
        cell.feedImage.kf.setImage(with: URL(string: ""))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            showDeleteMyFeedAlert(indexPath: indexPath)
        }
    }
    
}

extension MyFeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let remove = UITableViewRowAction(style: .default, title: "") { action, indexPath in
//            print("delete button tapped")
//        }
//
//        remove.backgroundColor = UIColor(patternImage: UIImage(named: "iconRemove")!)
//
//        return [remove]
//    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            success(true)
        })

        deleteAction.backgroundColor = UIColor(red: 42/255.0, green: 44/255.0, blue: 52/255.0, alpha: 1.0)
        deleteAction.image = UIImage(named: "iconRemove")

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// album
extension MyFeedViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let viewController = UIStoryboard.init(name: "WriteFeed", bundle: nil).instantiateViewController(withIdentifier: "WriteFeedViewController") as? WriteFeedViewController {
            if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                viewController.image = img
                viewController.userInfo = userInfo
            }
            self.dismiss(animated: true) {
                self.present(viewController, animated: true, completion: nil)
            }
        }
    }
}


// request
extension MyFeedViewController {
    func fetchMyFeeds(ownerId: Int) {
        let urlPath = Commons.baseUrl + "/journey/myjourney/\(ownerId)"
//        Alamofire.request(urlPath).response
        Alamofire.request(urlPath).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            if let json = response.result.value as? [MyJourney] {
                print("JSON: \(json)") // serialized json response
                // TODO : 초기화 -> cell에 뿌리는 부분!
                
            }
            
            if let data = response.data {
                let decoder = JSONDecoder()
                print("JSON: \(data)")
                do {
                } catch let e {
                    print(e)
                }
            }
            
            if let info = self.myJourneyLists {
                self.update(myJourneyList: info)
            }
            else {
                self.update(myJourneyList: [])
            }
        }
    }
    func update(myJourneyList:[MyJourney]) {
        if myJourneyList.count == 0 {
            emptyView.isHidden = false
        }
        else {
            emptyView.isHidden = true
            tableView.reloadData()
        }
        
    }
}
