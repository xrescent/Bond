//
//  DrawerViewController.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/5.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import UIKit
import CoreData

class DrawerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

   
    @IBOutlet weak var NavigationItem: UINavigationItem!
    @IBOutlet weak var DrawerTableView: UITableView!
    var postcardsInDrawer = [PostcardInDrawer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // NavigationLogo.shared.setup()
       //
       // NavigationItem.titleView = NavigationLogo.shared.titleView
        let logoView = UIImageView()
        logoView.frame = CGRectMake(0, 0, 50, 70)
        logoView.contentMode = .ScaleAspectFit
        logoView.image = UIImage(named: "navi_logo")
        
        
        self.NavigationItem.titleView = logoView
        print("this is Drawer")
        
        // request Postcard from core data
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Postcard")
        do {
            let results = try managedContext.executeFetchRequest(request) as! [Postcard]
            
            for result in results {
                guard let  title = result.title,
                                receiver = result.receivers as? String!,
                                receiver_name = result.receiver_name as String!,
                                context = result.context,
                                signature = result.signature,
                                created_time = result.created_time,
                                delivered_time = result.delivered_time,
                                image = result.image else { fatalError() }
                
                postcardsInDrawer.append(PostcardInDrawer(receiver: receiver, receiver_name: receiver_name, created_time: created_time, delivered_time: delivered_time, title: title, context: context, signature: signature, image: image))
            }
            
        }catch{
            fatalError("Failed to fetch data: \(error)")
        }
        
        
        DrawerTableView.delegate = self
        DrawerTableView.dataSource = self
        
        self.DrawerTableView.rowHeight = 120

        if self.DrawerTableView != nil {
            self.DrawerTableView.reloadData()
        }
        
     }
    
    override func viewDidAppear(animated: Bool) {
 
        super.viewDidAppear(true)
      //  NavigationLogo.shared.setup()
      //  NavigationItem.titleView = NavigationLogo.shared.titleView
        

        print ("rly")
    }
    

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postcardsInDrawer.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DrawerCell", forIndexPath: indexPath) as! DrawerTableViewCell
        
        let thePostcard = postcardsInDrawer[indexPath.row]
        
//        cell.cellBackground.frame = CGRectMake(20, 20, self.view.frame.width - 40 , 80)  //之後改成依device的大小自動變化
        
        cell.title.text = thePostcard.title
        cell.title.font = UIFont(name: "Avenir Next", size: 12)

        cell.imageInSmall.frame = CGRectMake(35, 35, 50, 50)
        cell.imageInSmall.layer.cornerRadius = cell.imageInSmall.frame.height / 2
        cell.imageInSmall.contentMode = .ScaleAspectFit
        cell.imageInSmall.image = UIImage(data: thePostcard.image)
        cell.imageInSmall.clipsToBounds = true
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        cell.lastEditedLabel.text = dateFormatter.stringFromDate(thePostcard.created_time)
        cell.lastEditedLabel.textColor = UIColor.grayColor()
        cell.lastEditedLabel.font = UIFont(name: "Avenir Next", size: 12)
        
        cell.receivers.text = thePostcard.receiver_name

        cell.ContentView.addSubview(cell.imageInSmall)
        
        return cell
    }
    
}
