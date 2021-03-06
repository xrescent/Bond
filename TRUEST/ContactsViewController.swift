//
//  ContactsViewController.swift
//  TRUEST
//
//  Created by MichaelRevlis on 2016/10/13.
//  Copyright © 2016年 MichaelRevlis. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import FBSDKCoreKit
import ABPadLockScreen
class ContactsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,  ABPadLockScreenViewControllerDelegate {
    
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var NavigationItem: UINavigationItem!
    
    var friendList: [existedFBUser] = []
    var createNew: Bool = true // should be false, change to true for testing, it should be that pressed + and change it into true
    var selectedIndexes = [NSIndexPath]() {
        didSet {
            CollectionView.reloadData()
        }
    }
    private(set) var thePasscode: String?
    private var foregroundNotification: NSObjectProtocol!
    override func viewDidLoad() {
        super.viewDidLoad()
        thePasscode = NSUserDefaults.standardUserDefaults().stringForKey("currentPasscode")
        print(thePasscode)
        if thePasscode == nil {
        } else if self.thePasscode != nil {
            let lockScreen = ABPadLockScreenViewController(delegate: self, complexPin: false)
            lockScreen.setAllowedAttempts(3)
            lockScreen.modalPresentationStyle = UIModalPresentationStyle.FullScreen
            lockScreen.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            presentViewController(lockScreen, animated: true, completion: nil)
        } //第一次進來run一次lock//
        
        
        foregroundNotification = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
            [unowned self] notification in
            self.thePasscode = NSUserDefaults.standardUserDefaults().stringForKey("currentPasscode")
            if self.thePasscode == nil {
            } else if self.thePasscode != nil {
                let lockScreen = ABPadLockScreenViewController(delegate: self, complexPin: false)
                lockScreen.setAllowedAttempts(3)
                lockScreen.modalPresentationStyle = UIModalPresentationStyle.FullScreen
                lockScreen.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                self.presentViewController(lockScreen, animated: true, completion: nil)
            }
        }//從桌面回來也跳lock//
        print("hi I'm at ContactsViewController")
       
        ABPadLockScreenView.appearance().backgroundColor = UIColor(hue:0.61, saturation:0.55, brightness:0.64, alpha:1)
        
        ABPadLockScreenView.appearance().labelColor = UIColor.whiteColor()
        
        let buttonLineColor = UIColor(red: 229/255, green: 180/255, blue: 46/255, alpha: 1)
        ABPadButton.appearance().backgroundColor = UIColor.clearColor()
        ABPadButton.appearance().borderColor = buttonLineColor
        ABPadButton.appearance().selectedColor = buttonLineColor
        ABPinSelectionView.appearance().selectedColor = buttonLineColor
        
        
        ContactsManager.shared.delegate = self
        
        ContactsManager.shared.myFriends()

        CollectionView.delegate = self
        
        CollectionView.dataSource = self
        
        CollectionView.backgroundColor = UIColor.whiteColor()
        let logoView = UIImageView()
            logoView.frame = CGRectMake(0, 0, 50, 70)
            logoView.contentMode = .ScaleAspectFit
            logoView.image = UIImage(named: "navi_logo")
       
      
      self.NavigationItem.titleView = logoView

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()

    }
    
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        return friendList.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ContactsCell", forIndexPath: indexPath) as! ContactsCollectionViewCell
        
        let row = indexPath.row
        
        let theFriend = friendList[row]
        
        // TODO: dealing with picture "!" and the case of not having a picture. (later one consider as further feature)
        let pictureUrl = NSURL(string: theFriend.pictureUrl)
        let data = NSData(contentsOfURL: pictureUrl!)
        
        cell.setup()
        cell.imageInSmall.image = UIImage(data: data!)
        cell.contactName.text = theFriend.name
        

//        // select a colection cell and something will happen. ex. change cell color
//        if self.selectedIndexes.indexOf(indexPath) != nil { // Selected
//            
//            if self.createNew == false {
//                // show a view with SendFromOutbox and ViewThread
//            } else {
//                // create a new post and pass selected intimate to addPost as receiver
//            }
//        }
        
        return cell
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 375 110
        if let layout = CollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            
            let itemWidth = 110
            let itemHeight = itemWidth
            let edgeSpacing = (view.bounds.width - 334) / 2
            layout.sectionInset = UIEdgeInsets(top: 10, left: edgeSpacing, bottom: 15, right: edgeSpacing)
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
            layout.minimumLineSpacing = 2
            layout.minimumInteritemSpacing = 2
            layout.invalidateLayout()
        }
    }
    

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // insure what happened to selected cell did not be refresh when scrolling down
        if let indexSelectThenDo = selectedIndexes.indexOf(indexPath) {
            selectedIndexes.removeAtIndex(indexSelectThenDo)
        } else {
            selectedIndexes.append(indexPath)
        }
        
        
    }
    
    //MARK: Lock Screen Setup Delegate
//    func pinSet(pin: String!, padLockScreenSetupViewController padLockScreenViewController: ABPadLockScreenSetupViewController!) {
//        thePin = pin
//        dismissViewControllerAnimated(true, completion: nil)
//    }
    
    func unlockWasCancelledForSetupViewController(padLockScreenViewController: ABPadLockScreenAbstractViewController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Lock Screen Delegate
    func padLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController!, validatePin pin: String!) -> Bool {
        print("Validating Pin \(pin)")
        return thePasscode == pin
    }
    
    func unlockWasSuccessfulForPadLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController!) {
        print("Unlock Successful!")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func unlockWasUnsuccessful(falsePin: String!, afterAttemptNumber attemptNumber: Int, padLockScreenViewController: ABPadLockScreenViewController!) {
        print("Failed Attempt \(attemptNumber) with incorrect pin \(falsePin)")
    }
    
    func unlockWasCancelledForPadLockScreenViewController(padLockScreenViewController: ABPadLockScreenViewController!) {
        print("Unlock Cancled")
        
        
        
    }



    
    
}



extension ContactsViewController: ContactsManagerDelegate {
    
    func manager(manager: ContactsManager, didGetFriendList friendList: [existedFBUser]) {
        self.friendList = friendList
        
        self.CollectionView.reloadData()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                
            case "SelectFriendAsReceiver":
                // create a new post and pass selected intimate to addPost as receiver
                if createNew == true {
                    let addPostVC = segue.destinationViewController as! AddBondViewController
                    
                    print("segue to addPost")
                    
                    if let indexPath = self.CollectionView.indexPathForCell(sender as! UICollectionViewCell) {
                        
                        addPostVC.receiverName = friendList[indexPath.row].name
                        addPostVC.receiverNode = friendList[indexPath.row].userNode
                        print("\(addPostVC.receiverName)")
                        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
                        //self.NavigationItem.title = friendList[indexPath.row].name
                        
                    }
                    
                    FIRAnalytics.logEventWithName("selectAFriendAsReceiver", parameters: nil)
                    
                }
                
            // show a view with SendFromOutbox and ViewThread
            case "ShowMailbox": break
              
            case "ShowThread": break
                
            default:
                break
            }
        }
    }
}
