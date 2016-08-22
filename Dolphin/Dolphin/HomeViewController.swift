//
//  HomeViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 11/25/15.
//  Copyright © 2015 Ninth Coast. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class HomeViewController : DolphinTabBarViewController, UISearchBarDelegate, UITabBarControllerDelegate, CLLocationManagerDelegate, ChooseSourceTypeViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var actionMenu: UIView? = nil
    var searchBar: UISearchBar?
    var locationManager: CLLocationManager!
    var chooseSoureTypeView: ChooseSourceTypeView!
    var overlayView: UIView!
    var picker: UIImagePickerController = UIImagePickerController()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        self.init(nibName: "HomeViewController", bundle: nil)
    }
    
    @IBOutlet weak var actionMenuBackground: UIView!
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Enable Swipe gesture for sidebar
        revealViewController().panGestureRecognizer().enabled = true
        
        // if the login is the rootViewController we have to change it for HomeViewController
        if navigationController!.viewControllers[0].isKindOfClass(LoginViewController) {
            navigationController?.setViewControllers([self], animated: true)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Dolphin"
        setMenuLeftButton()
        setSearchRightButton()
        setupTabbarController()
        initLocationService()
        
        self.delegate = self
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Disable Swipe gesture for sidebar
        revealViewController().panGestureRecognizer().enabled = false
    }
    
    // MARK: Appearance and Initialization
    
    func setupTabbarController() {
        // Set appearance of TabBar
        UITabBar.appearance().barTintColor = UIColor.blueDolphin()
        UITabBar.appearance().tintColor = UIColor.yellowHighlightedMenuItem()
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSFontAttributeName: UIFont(name:"ArialRoundedMTBold", size:11)!,
                NSForegroundColorAttributeName: UIColor.whiteColor()],
            forState: .Normal)
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSFontAttributeName: UIFont(name:"ArialRoundedMTBold", size:11)!,
                NSForegroundColorAttributeName: UIColor.yellowHighlightedMenuItem()],
            forState: .Selected)
        
        let controller1 = RecentsViewController(likes: false)
        let controller2 = MyFeedViewController(likes: false)
        let controller3 = UIViewController()
        let controller4 = PopularViewController()
        let controller5 = PODsListViewController()
        
        
        controller1.tabBarItem = UITabBarItem(title: "Recent",
            image: UIImage(named:"TabbarLatestIcon")!.imageWithRenderingMode(.AlwaysOriginal),
            selectedImage: UIImage(named:"TabbarLatestIcon"))
        
        controller2.tabBarItem = UITabBarItem(title: "My Feed",
            image: UIImage(named:"SidebarDolphinIcon")!.imageWithRenderingMode(.AlwaysOriginal),
            selectedImage: UIImage(named:"SidebarDolphinIcon"))
        
        controller3.tabBarItem = UITabBarItem(title: "", image: UIImage(named: ""), selectedImage: UIImage(named: ""))
        
        controller4.tabBarItem = UITabBarItem(title: "Popular",
            image: UIImage(named:"SidebarGlassesIcon")!.imageWithRenderingMode(.AlwaysOriginal),
            selectedImage: UIImage(named:"SidebarGlassesIcon"))
        
        controller5.tabBarItem = UITabBarItem(title: "PODs",
            image: UIImage(named:"SidebarMyPODsIcon")!.imageWithRenderingMode(.AlwaysOriginal),
            selectedImage: UIImage(named:"SidebarMyPODsIcon"))
        
        let tabViewControllers = [controller1, controller2, controller3, controller4, controller5]
        viewControllers = tabViewControllers
        
        // Add plus button
        let plusButton = UIButton(frame: CGRect(x: (UIScreen.mainScreen().bounds.size.width / 2.0) - 40, y: UIScreen.mainScreen().bounds.size.height - 130, width: 80, height: 80))
        plusButton.enabled = true
        plusButton.layer.cornerRadius = 40
        plusButton.layer.borderColor = UIColor.whiteColor().CGColor
        plusButton.layer.borderWidth = 3
        plusButton.setImage(UIImage(named: "TabbarPlusIcon"), forState: .Normal)
        plusButton .addTarget(self , action: #selector(plusButtonTouchUpInside), forControlEvents: .TouchUpInside)
        plusButton.backgroundColor = UIColor.blueDolphin()
        self.view.addSubview(plusButton)
        
        // put recent as marked
        selectedIndex = 1
    }
    
    // MARK: Plus button Actions
    
    func plusButtonTouchUpInside() {
        print("Plus button pressed")
        let subViewsArray = NSBundle.mainBundle().loadNibNamed("NewPostMenu", owner: self, options: nil)
        self.actionMenu = subViewsArray[0] as? UIView
        actionMenuBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionMenuBackgroundTapped)))
        self.actionMenu?.frame = CGRect(x: 0, y: (UIApplication.sharedApplication().keyWindow?.frame.size.height)!, width: (UIApplication.sharedApplication().keyWindow?.frame.size.width)!, height: (UIApplication.sharedApplication().keyWindow?.frame.size.height)!)
        UIApplication.sharedApplication().keyWindow?.addSubview(actionMenu!)
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.actionMenu?.frame = CGRect(x: 0, y: 0, width: (UIApplication.sharedApplication().keyWindow?.frame.size.width)!, height: (UIApplication.sharedApplication().keyWindow?.frame.size.height)!)
            }) { (finished) -> Void in
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.actionMenuBackground.alpha = 0.4
                })
        }
    }
    
    @IBAction func closeNewPostViewButtonTouchUpInside(sender: AnyObject) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.actionMenuBackground.alpha = 0
            }) { (finished) -> Void in
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.actionMenu?.frame = CGRect(x: 0, y: (UIApplication.sharedApplication().keyWindow?.frame.size.height)!, width: (UIApplication.sharedApplication().keyWindow?.frame.size.width)!, height: (UIApplication.sharedApplication().keyWindow?.frame.size.height)!)
                    }) { (finished) -> Void in
                        self.actionMenu?.removeFromSuperview()
                }
        }
    }
    
    @IBAction func postLinkButtonTouchUpInside(sender: AnyObject) {
        let createLinkPostVC = CreateURLPostViewController()
        navigationController?.pushViewController(createLinkPostVC, animated: true)
        actionMenu?.removeFromSuperview()
        print("Post link button pressed")
        
    }
    @IBAction func postPhotoButtonTouchUpInside(sender: AnyObject) {
        actionMenu?.removeFromSuperview()
        
        self.overlayView = UIView()
        self.overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        self.overlayView.frame = (UIApplication.sharedApplication().keyWindow?.frame)!
        UIApplication.sharedApplication().keyWindow?.addSubview(self.overlayView)
        
        self.chooseSoureTypeView = ChooseSourceTypeView.instanceFromNib()
        self.chooseSoureTypeView.frame = CGRectMake(0, 0, 300, 200)
        self.chooseSoureTypeView.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height/2.0)
        self.chooseSoureTypeView.delegate = self
        UIApplication.sharedApplication().keyWindow?.addSubview(self.chooseSoureTypeView!)
        
        self.chooseSoureTypeView.transform = CGAffineTransformMakeScale(0.01, 0.01)
        UIView.animateWithDuration(0.1, animations: { 
            self.chooseSoureTypeView.transform = CGAffineTransformMakeScale(1.2, 1.2)
            UIView.animateWithDuration(0.05, animations: {
                self.chooseSoureTypeView.transform = CGAffineTransformIdentity
            }) { (finished) in
            }
        }) { (finished) in
            
        }
    }
    
    // MARK: ChooseSourceTypeViewDelegate
    func closedDialog() {
        self.overlayView.removeFromSuperview()
        self.chooseSoureTypeView.removeFromSuperview()
    }
    
    func selectedCamera() {
        self.closedDialog()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            self.picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.picker.delegate   = self
            self.picker.allowsEditing = true
            self.presentViewController(picker, animated: true, completion: nil)
        }
        else {
            Utils.presentAlertMessage("Error", message: "Device has no camera", cancelActionText: "Ok", presentingViewContoller: self)
        }
    }
    
    func selectedPhotoGallery() {
        self.closedDialog()
        
        self.picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.picker.delegate   = self
        self.picker.allowsEditing = true
        self.picker.navigationBar.tintColor = UIColor.whiteColor()
        self.picker.navigationBar.barStyle = UIBarStyle.Black
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("didFinishPickingMediaWithInfo")
        dismissViewControllerAnimated(true) { 
            let image = info[UIImagePickerControllerEditedImage] as? UIImage
            let finishImagePostVC = CreateImagePostFinishPostingViewController(image: image)
            self.navigationController?.pushViewController(finishImagePostVC, animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func postTextButtonTouchUpInside(sender: AnyObject) {
        let createTextPostVC = CreateTextPostViewController()
        navigationController?.pushViewController(createTextPostVC, animated: true)
        actionMenu?.removeFromSuperview()
        print("Post text button pressed")
    }
    
    func actionMenuBackgroundTapped() {
        // Overlay was tapped, so we close the new post view
        closeNewPostViewButtonTouchUpInside(self)
    }
    
    // MARK: Search
    
    func searchButtonPressed() {
        if searchBar == nil {
            searchBar                    = UISearchBar(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 40))
        }
        removeAllItemsFromNavBar()
        
        navigationItem.titleView     = searchBar
        searchBar?.tintColor = UIColor.whiteColor()
        UITextField.my_appearanceWhenContainedWithin([UISearchBar.classForCoder()]).tintColor = UIColor.blueDolphin()
        searchBar?.becomeFirstResponder()
        searchBar?.showsCancelButton = true
        searchBar?.delegate          = self
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        filterContentForSearchText("")
        removeSearchBar()
        selectedViewController?.performSelector("userDidCancelSearch", withObject: nil)
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func removeSearchBar() {
        removeAllItemsFromNavBar()
        searchBar?.text = ""
        title = "Dolphin"
        searchBar?.resignFirstResponder()
        setSearchRightButton()
    }
    
    func filterContentForSearchText(searchText: String) {
        selectedViewController?.performSelector("filterResults:", withObject: searchText)
    }
    
    func hideSearchField() {
        self.searchBar?.resignFirstResponder()
    }
    
    // MARK: TabbarControllerDelegate
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        removeSearchBar()
        setSearchRightButton()
    }
    
    // MARK: Location Services.
    func initLocationService() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            let firstLoc = locations[0]
            Globals.currentLat = firstLoc.coordinate.latitude
            Globals.currentLng = firstLoc.coordinate.longitude
            
            CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
                if (error != nil) {
//                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
                
                if placemarks?.count > 0 {
                    let pm = placemarks![0] as CLPlacemark
                    
                    var locality: String = ""
                    if pm.locality != nil {
                        locality = pm.locality!
                    }
                    
                    var postalCode: String = ""
                    if pm.postalCode != nil {
                        postalCode = "," + pm.postalCode!
                    }
                    
                    var administrativeArea: String = ""
                    if pm.administrativeArea != nil {
                        administrativeArea = "," + pm.administrativeArea!
                    }
                    
                    var country: String = ""
                    if pm.country != nil {
                        country = "," + pm.country!
                    }
                    
                    Globals.currentAddress = locality + postalCode + administrativeArea + country
                    
                } else {
                    print("Problem with the data received from geocoder")
                }
            })
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("location service error = \(error)")
    }
   
}