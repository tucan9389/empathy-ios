//
//  MyFeedViewController.swift
//  empathy-ios
//
//  Created by byungtak on 23/11/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import Kingfisher
import UIKit

class MyFeedViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    private let cellIdentifier = "my_feed_cell"
    private var myFeeds: [MyFeed] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        //dummy
        myFeeds.append(MyFeed(date: "11.03 2017", title: "왕십리 시장 탐험을 다녀오다", imageUrl: ""))
        myFeeds.append(MyFeed(date: "11.03 2017", title: "왕십리 시장 탐험을 다녀오다", imageUrl: ""))
        myFeeds.append(MyFeed(date: "11.03 2017", title: "왕십리 시장 탐험을 다녀오다", imageUrl: ""))
        myFeeds.append(MyFeed(date: "11.03 2017", title: "왕십리 시장 탐험을 다녀오다", imageUrl: ""))
        myFeeds.append(MyFeed(date: "11.03 2017", title: "왕십리 시장 탐험을 다녀오다", imageUrl: ""))
        myFeeds.append(MyFeed(date: "11.03 2017", title: "왕십리 시장 탐험을 다녀오다", imageUrl: ""))
    }
    
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let remove = UITableViewRowAction(style: .default, title: "") { action, indexPath in
            print("delete button tapped")
        }
        
//        remove.backgroundColor = UIView()
        
        return [remove]
    }
}
