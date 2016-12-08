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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        self.init(nibName: "HomeViewController", bundle: nil)
    }
    
    @IBOutlet weak var actionMenuBackground: UIView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Enable Swipe gesture for sidebar
        revealViewController().panGestureRecognizer().isEnabled = true
        
        // if the login is the rootViewController we have to change it for HomeViewController
        if navigationController!.viewControllers[0].isKind(of: LoginViewController.self) {
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
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Disable Swipe gesture for sidebar
        revealViewController().panGestureRecognizer().isEnabled = false
    }
    
    // MARK: Appearance and Initialization
    
    func setupTabbarController() {
        // Set appearance of TabBar
        UITabBar.appearance().barTintColor = UIColor.blueDolphin()
        UITabBar.appearance().tintColor = UIColor.yellowHighlightedMenuItem()
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSFontAttributeName: UIFont(name:"ArialRoundedMTBold", size:11)!,
                NSForegroundColorAttributeName: UIColor.white],
            for: UIControlState())
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSFontAttributeName: UIFont(name:"ArialRoundedMTBold", size:11)!,
                NSForegroundColorAttributeName: UIColor.yellowHighlightedMenuItem()],
            for: .selected)
        
        let controller1 = RecentsViewController(likes: false)
        let controller2 = MyFeedViewController(likes: false)
        let controller3 = UIViewController()
        let controller4 = PopularViewController()
        let controller5 = PODsListViewController()
        
        
        controller1.tabBarItem = UITabBarItem(title: "Recent",
            image: UIImage(named:"TabbarLatestIcon")!.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named:"TabbarLatestIcon"))
        
        controller2.tabBarItem = UITabBarItem(title: "My Feed",
            image: UIImage(named:"SidebarDolphinIcon")!.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named:"SidebarDolphinIcon"))
        
        controller3.tabBarItem = UITabBarItem(title: "", image: UIImage(named: ""), selectedImage: UIImage(named: ""))
        
        controller4.tabBarItem = UITabBarItem(title: "Popular",
            image: UIImage(named:"SidebarGlassesIcon")!.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named:"SidebarGlassesIcon"))
        
        controller5.tabBarItem = UITabBarItem(title: "PODs",
            image: UIImage(named:"SidebarMyPODsIcon")!.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named:"SidebarMyPODsIcon"))
        
        let tabViewControllers = [controller1, controller2, controller3, controller4, controller5]
        viewControllers = tabViewControllers
        
        // Add plus button
        let plusButton = UIButton(frame: CGRect(x: (UIScreen.main.bounds.size.width / 2.0) - 40, y: UIScreen.main.bounds.size.height - 130, width: 80, height: 80))
        plusButton.isEnabled = true
        plusButton.layer.cornerRadius = 40
        plusButton.layer.borderColor = UIColor.white.cgColor
        plusButton.layer.borderWidth = 3
        plusButton.setImage(UIImage(named: "TabbarPlusIcon"), for: UIControlState())
        plusButton .addTarget(self , action: #selector(plusButtonTouchUpInside), for: .touchUpInside)
        plusButton.backgroundColor = UIColor.blueDolphin()
        self.view.addSubview(plusButton)
        
        // put recent as marked
        selectedIndex = 1
    }
    
    // MARK: Plus button Actions
    
    func plusButtonTouchUpInside() {
        print("Plus button pressed")
        let subViewsArray = Bundle.main.loadNibNamed("NewPostMenu", owner: self, options: nil)
        self.actionMenu = subViewsArray![0] as? UIView
        actionMenuBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionMenuBackgroundTapped)))
        self.actionMenu?.frame = CGRect(x: 0, y: (UIApplication.shared.keyWindow?.frame.size.height)!, width: (UIApplication.shared.keyWindow?.frame.size.width)!, height: (UIApplication.shared.keyWindow?.frame.size.height)!)
        UIApplication.shared.keyWindow?.addSubview(actionMenu!)
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.actionMenu?.frame = CGRect(x: 0, y: 0, width: (UIApplication.shared.keyWindow?.frame.size.width)!, height: (UIApplication.shared.keyWindow?.frame.size.height)!)
            }, completion: { (finished) -> Void in
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    self.actionMenuBackground.alpha = 0.4
                })
        }) 
    }
    
    @IBAction func closeNewPostViewButtonTouchUpInside(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.actionMenuBackground.alpha = 0
            }, completion: { (finished) -> Void in
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    self.actionMenu?.frame = CGRect(x: 0, y: (UIApplication.shared.keyWindow?.frame.size.height)!, width: (UIApplication.shared.keyWindow?.frame.size.width)!, height: (UIApplication.shared.keyWindow?.frame.size.height)!)
                    }, completion: { (finished) -> Void in
                        self.actionMenu?.removeFromSuperview()
                }) 
        }) 
    }
    
    @IBAction func postLinkButtonTouchUpInside(_ sender: AnyObject) {
        let createLinkPostVC = CreateURLPostViewController()
        navigationController?.pushViewController(createLinkPostVC, animated: true)
        actionMenu?.removeFromSuperview()
        print("Post link button pressed")
        
    }
    @IBAction func postPhotoButtonTouchUpInside(_ sender: AnyObject) {
        actionMenu?.removeFromSuperview()
        
        self.overlayView = UIView()
        self.overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        self.overlayView.frame = (UIApplication.shared.keyWindow?.frame)!
        UIApplication.shared.keyWindow?.addSubview(self.overlayView)
        
        self.chooseSoureTypeView = ChooseSourceTypeView.instanceFromNib()
        self.chooseSoureTypeView.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
        self.chooseSoureTypeView.center = CGPoint(x: self.view.frame.size.width / 2.0, y: self.view.frame.size.height/2.0)
        self.chooseSoureTypeView.delegate = self
        UIApplication.shared.keyWindow?.addSubview(self.chooseSoureTypeView!)
        
        self.chooseSoureTypeView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration: 0.1, animations: { 
            self.chooseSoureTypeView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            UIView.animate(withDuration: 0.05, animations: {
                self.chooseSoureTypeView.transform = CGAffineTransform.identity
            }, completion: { (finished) in
            }) 
        }, completion: { (finished) in
            
        }) 
    }
    
    // MARK: ChooseSourceTypeViewDelegate
    func closedDialog() {
        self.overlayView.removeFromSuperview()
        self.chooseSoureTypeView.removeFromSuperview()
    }
    
    func selectedCamera() {
        self.closedDialog()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            self.picker.sourceType = UIImagePickerControllerSourceType.camera
            self.picker.delegate   = self
            self.picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
        else {
            Utils.presentAlertMessage("Error", message: "Device has no camera", cancelActionText: "Ok", presentingViewContoller: self)
        }
    }
    
    func selectedPhotoGallery() {
        self.closedDialog()
        
        self.picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.picker.delegate   = self
        self.picker.allowsEditing = true
        self.picker.navigationBar.tintColor = UIColor.white
        self.picker.navigationBar.barStyle = UIBarStyle.black
        self.present(picker, animated: true, completion: nil)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("didFinishPickingMediaWithInfo")
        dismiss(animated: true) { 
            let image = info[UIImagePickerControllerEditedImage] as? UIImage
            let finishImagePostVC = CreateImagePostFinishPostingViewController(image: image)
            self.navigationController?.pushViewController(finishImagePostVC, animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func postTextButtonTouchUpInside(_ sender: AnyObject) {
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
            searchBar                    = UISearchBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        }
        removeAllItemsFromNavBar()
        
        navigationItem.titleView     = searchBar
        searchBar?.tintColor = UIColor.white
        UITextField.my_appearanceWhenContained(within: [UISearchBar.classForCoder()]).tintColor = UIColor.blueDolphin()
        searchBar?.becomeFirstResponder()
        searchBar?.showsCancelButton = true
        searchBar?.delegate          = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filterContentForSearchText("")
        removeSearchBar()
        selectedViewController?.perform(Selector(("userDidCancelSearch")), with: nil)
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func removeSearchBar() {
        removeAllItemsFromNavBar()
        searchBar?.text = ""
        title = "Dolphin"
        searchBar?.resignFirstResponder()
        setSearchRightButton()
    }
    
    func filterContentForSearchText(_ searchText: String) {
        selectedViewController?.perform(Selector(("filterResults:")), with: searchText)
    }
    
    func hideSearchField() {
        self.searchBar?.resignFirstResponder()
    }
    
    // MARK: TabbarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
                        Globals.currentCity = pm.locality!
                    }
                    
                    var postalCode: String = ""
                    if pm.postalCode != nil {
                        postalCode = "," + pm.postalCode!
                        Globals.currentZip = pm.postalCode!
                    }
                    
                    var administrativeArea: String = ""
                    if pm.administrativeArea != nil {
                        administrativeArea = "," + pm.administrativeArea!
                    }
                    
                    var country: String = ""
                    if pm.country != nil {
                        country = "," + pm.country!
                        Globals.currentCountry = pm.country!
                    }
                    
                    Globals.currentAddress = locality + postalCode + administrativeArea + country
                    
                } else {
                    print("Problem with the data received from geocoder")
                }
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location service error = \(error)")
    }
   
}
