//
//  PODDetailsViewController.swift
//  Dolphin
//
//  Created by Ninth Coast on 2/15/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit
import SVProgressHUD

class PODDetailsViewController: DolphinViewController, UITableViewDataSource, UITableViewDelegate, PostTableViewCellDelegate, PODMembersTableViewCellDelegate, ChooseSourceTypeViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableViewPosts: UITableView!
    @IBOutlet weak var actionMenuBackground: UIView!
    
    let networkController = NetworkController.sharedInstance
    let kPageQuantity: Int = 10
    
    var pListener : UpdateProtocol?
    var pod: POD?
    var needToReloadPod = false
    var postOfPOD: [Post] = []
    var actionMenu: UIView? = nil
    var page: Int = 0
    var prevViewController: AnyObject!
    
    var chooseSoureTypeView: ChooseSourceTypeView!
    var overlayView: UIView!
    var picker: UIImagePickerController = UIImagePickerController()

    required init() {
        super.init(nibName: "PODDetailsViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        registerCells()
        
        // setup delegate and datesource
        tableViewPosts.delegate           = self
        tableViewPosts.dataSource         = self
        tableViewPosts.separatorStyle     = .none
        tableViewPosts.estimatedRowHeight = 400
        tableViewPosts.backgroundColor    = UIColor.lightGrayBackground()
        
        tableViewPosts.addPullToRefresh { () -> Void in
            self.loadData(true)
        }
        
        tableViewPosts.addInfiniteScrolling { () -> Void in
            self.loadNextPosts()
        }
        
        // Add bottom blue bar
        let fakeTabBar = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - 113, width: UIScreen.main.bounds.size.width, height: 49))
        fakeTabBar.backgroundColor = UIColor.blueDolphin()
        
        // Add plus button
        let plusButton = UIButton(frame: CGRect(x: (UIScreen.main.bounds.size.width / 2.0) - 40, y: UIScreen.main.bounds.size.height - 130, width: 80, height: 80))
        plusButton.isEnabled = true
        plusButton.layer.cornerRadius = 40
        plusButton.layer.borderColor = UIColor.white.cgColor
        plusButton.layer.borderWidth = 3
        plusButton.setImage(UIImage(named: "TabbarPlusIcon"), for: UIControlState())
        plusButton.addTarget(self , action: #selector(PODDetailsViewController.plusButtonTouchUpInside), for: .touchUpInside)
        plusButton.backgroundColor = UIColor.blueDolphin()
        self.view.addSubview(fakeTabBar)
        self.view.addSubview(plusButton)
        
        if needToReloadPod {
            self.refreshCurrentPod()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableViewPosts.reloadData()
        loadData(false)
        
    }
    
    override func goBackButtonPressed(_ sender: UIBarButtonItem) {
        super.goBackButtonPressed(sender)
        if(self.pListener != nil)
        {
            self.pListener?.updatePodUI()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation bar
    
    func setupNavigationBar() {
        setBackButton()
        title = pod?.name
        self.checkRightActionButton()
    }
    
    func checkRightActionButton() {
        if networkController.currentUserId == self.pod?.owner?.id {
            setRightButtonItemWithText("Edit", target: self, action: #selector(editPod))
        }
        else {
            
            if self.pod?.users != nil {
                var isMember = false
                for u in (self.pod?.users)! {
                    if u.id == networkController.currentUserId {
                        isMember = true
                        break;
                    }
                }
                
                if isMember == true {
                    setRightButtonItemWithText("Withdraw", target: self, action: #selector(withdrawMember))
                } else {
                    setRightButtonItemWithText("Join", target: self, action: #selector(joinMember))
                }
            }
        }
    }
    
    // MARK: - Auxiliary methods
    
    func registerCells() {
        tableViewPosts.register(UINib(nibName: "PostTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "PostTableViewCell")
        tableViewPosts.register(UINib(nibName: "PODMembersTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "PODMembersTableViewCell")
    }
    
    // MARK: - TableView datasource
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Only header for comments section
        if section == 0 {
            return 25
        } else {
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Only header for comments section
        if section == 0 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 25))
            headerView.backgroundColor = UIColor.skyBlueDolphinMembersHeader()
            let headerLabel = UILabel(frame: CGRect(x: 15, y: 0, width: 50, height: 25))
            headerLabel.text = "Members"
            headerLabel.textColor = UIColor.gray
            headerLabel.font = headerLabel.font.withSize(11)
            headerView.addSubview(headerLabel)
            
            if pod?.owner?.id == networkController.currentUserId {
                //let editButton = UIButton(frame: CGRect(x: headerView.frame.width - 35, y: 0, width: 25, height: 25))
                let editButton = UIButton(frame: CGRect(x: 70, y: 0, width: 25, height: 25))
                editButton.setImage(UIImage(named: "edit_icon"), for: UIControlState())
                editButton.addTarget(self, action: #selector(didTapEditMember), for: .touchUpInside)
                headerView.addSubview(editButton)
            }
            return headerView
        } else {
            return UIView()
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1;
        } else {
            return postOfPOD.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableViewPosts.dequeueReusableCell(withIdentifier: "PODMembersTableViewCell") as? PODMembersTableViewCell
            if cell == nil {
                cell = PODMembersTableViewCell()
            }
            cell?.configureWithPOD(pod!)
            cell?.delegate = self
            cell?.selectionStyle = .none
            return cell!
            
        } else {
            var cell = tableViewPosts.dequeueReusableCell(withIdentifier: "PostTableViewCell") as? PostTableViewCell
            if cell == nil {
                cell = PostTableViewCell()
            }
            cell?.configureWithPost(postOfPOD[indexPath.row], indexPath: indexPath)
            cell?.delegate = self
            cell?.selectionStyle = .none
            return cell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
        
    }
    
    // MARK: - TableView delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let postDetailsVC = PostDetailsViewController()
            postDetailsVC.post = postOfPOD[indexPath.row]
            postDetailsVC.pod = self.pod
            navigationController?.pushViewController(postDetailsVC, animated: true)
        }
    }
    
    
    // MARK: - Plus button Actions
    
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
    
    // MARK: - Close button Actions.
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
    
    // MARK: - Web post button Actions.
    @IBAction func postLinkButtonTouchUpInside(_ sender: AnyObject) {
        let createLinkPostVC = CreateURLPostViewController()
        createLinkPostVC.podId = pod?.id
        navigationController?.pushViewController(createLinkPostVC, animated: true)
        actionMenu?.removeFromSuperview()
        print("Post link button pressed")
        
    }
    
    // MARK: - Photo post button Actions.
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
    
    // MARK: - Text post button Actions.
    @IBAction func postTextButtonTouchUpInside(_ sender: AnyObject) {
        closeNewPostViewButtonTouchUpInside(self)
        let createTextPostVC = CreateTextPostViewController()
        createTextPostVC.pod = pod
        createTextPostVC.isPresentMode = true
        let textPostNavController = UINavigationController(rootViewController: createTextPostVC)
        present(textPostNavController, animated: true, completion: nil)
        print("Post text button pressed")
        
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
            finishImagePostVC.podId = self.pod?.id
            self.navigationController?.pushViewController(finishImagePostVC, animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func actionMenuBackgroundTapped() {
        // Overlay was tapped, so we close the new post view
        closeNewPostViewButtonTouchUpInside(self)
    }
    
    // MARK: - Network
    
    func loadData(_ pullToRefresh: Bool) {
        page = 0
        tableViewPosts.showsInfiniteScrolling = true
        if !pullToRefresh {
            SVProgressHUD.show(withStatus: "Loading")
        }
        networkController.filterPost(nil, types: nil, fromDate: nil, toDate: nil, userId:  nil, quantity: kPageQuantity, page: 0, podId: pod?.id, filterByUserInterests: false, sort_by: nil, completionHandler: { (posts, error) -> () in
            if error == nil {
                self.postOfPOD = posts
                if self.postOfPOD.count > 0 {
                    self.removeTableEmtpyMessage()
                } else {
                    self.addTableEmptyMessage("No content has been posted\n\nwhy don't post something?")
                }
                self.tableViewPosts.reloadData()
                
                if !pullToRefresh {
                    SVProgressHUD.dismiss()
                } else {
                    self.tableViewPosts.pullToRefreshView.stopAnimating()
                }
                
            } else {
                let errors: [String]? = error!["errors"] as? [String]
                let alert: UIAlertController
                if errors != nil && errors![0] != "" {
                    alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .alert)
                } else {
                    alert = UIAlertController(title: "Error", message: "Unknown error", preferredStyle: .alert)
                }
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                if !pullToRefresh {
                    SVProgressHUD.dismiss()
                }
                self.tableViewPosts.pullToRefreshView.stopAnimating()
            }
        })
    }
    
    
    func loadNextPosts() {
        page = page + 1
        networkController.filterPost(nil, types: nil, fromDate: nil, toDate: nil, userId: nil, quantity: kPageQuantity, page: page, podId: pod?.id, filterByUserInterests: false, sort_by: nil, completionHandler: { (posts, error) -> () in
            if error == nil {
                if posts.count > 0 {
                    self.postOfPOD.append(contentsOf: posts)
                    self.tableViewPosts.reloadData()
                } else {
                    // remove the infinite scrolling because we don't have more elements
                    self.tableViewPosts.showsInfiniteScrolling = false
                }
                
                
            } else {
                // decrease the page
                self.page = self.page - 1
                let errors: [String]? = error!["errors"] as? [String]
                let alert: UIAlertController
                if errors != nil && errors![0] != "" {
                    alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .alert)
                } else {
                    alert = UIAlertController(title: "Error", message: "Unknown error", preferredStyle: .alert)
                }
                let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
            self.tableViewPosts.infiniteScrollingView.stopAnimating()
        })
    }
    
    func addTableEmptyMessage(_ message: String) {
        let labelBackground = UILabel(frame: CGRect(x: 0, y: 0, width: tableViewPosts.frame.width, height: 200))
        labelBackground.text = message
        labelBackground.textColor = UIColor.blueDolphin()
        labelBackground.textAlignment = .center
        labelBackground.numberOfLines = 0
        Utils.setFontFamilyForView(labelBackground, includeSubViews: true)
        tableViewPosts.backgroundView = labelBackground
    }
    
    func removeTableEmtpyMessage() {
        tableViewPosts.backgroundView = nil
    }
    
    // MARK: PostTableViewCell Delegate.
    func downloadedPostImage(_ indexPath: IndexPath?) {
        tableViewPosts.reloadRows(at: [indexPath!], with: UITableViewRowAnimation.none)
    }
    
    func tapURL(_ url: String?) {
        let webVC = WebViewController()
        webVC.siteLink = url
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    func tapLike(_ post: Post?, cell: PostTableViewCell?) {
        if !(post?.isLikedByUser)! {
            SVProgressHUD.show(withStatus: "Loading")
            networkController.createLike("\(post!.postId!)", completionHandler: { (like, error) -> () in
                if error == nil {
                    if like?.id != nil {
                        post?.isLikedByUser = true
                        post?.postNumberOfLikes = (post?.postNumberOfLikes)! + 1
                        cell?.configureWithPost(post!)
                    }
                    SVProgressHUD.dismiss()
                    
                } else {
                    let errors: [String]? = error!["errors"] as? [String]
                    let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
            })
        } else {
            
            SVProgressHUD.show(withStatus: "Loading")
            networkController.deleteLike("\(post!.postId!)", completionHandler: { (error) -> () in
                if error == nil {
                    post?.postNumberOfLikes = (post?.postNumberOfLikes)! - 1
                    post?.isLikedByUser = false
                    cell?.configureWithPost(post!)
                    SVProgressHUD.dismiss()
                    
                } else {
                    let errors: [String]? = error!["errors"] as? [String]
                    let alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
            })
        }
    }

    func tapUserInfo(_ userInfo: User?) {
        let userView = OtherProfileViewController(userInfo: userInfo)
        navigationController?.pushViewController(userView, animated: true)
    }
    
    //Edit Members.
    func didTapEditMember() {
        let nextView = EditPodMemberViewController()
        nextView.pod = self.pod
        navigationController?.pushViewController(nextView, animated: true)
    }
    
    func editPod()  {
        let createPODVC = CreatePodViewController()
        createPODVC.podUpdate = self.pod;
        navigationController?.pushViewController(createPODVC, animated: true)
    }
    
    // MARK: Delete Pod
    func deletePod() {
        let alertWarning = UIAlertController(title: "Warning", message: "Are you sure your work with this POD is complete?", preferredStyle: UIAlertControllerStyle.alert)
        alertWarning.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
            // delete the pod
            let podIdString = String(self.pod!.id!)
            
            SVProgressHUD.show(withStatus: "Deleting...")
            self.networkController.deletePOD(podIdString) { (error) -> () in
                SVProgressHUD.dismiss()
                if error == nil {
                    print("pod deleted")
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Constants.Notifications.DeletedPod), object: nil, userInfo: ["pod":self.pod!])

                    if self.prevViewController != nil {
                        if self.prevViewController is PODsListViewController {
                            let listViewController = self.prevViewController as! PODsListViewController
                            listViewController.deletedPod(self.pod!)
                        } else if self.prevViewController is SettingsViewController {
                            let settingsViewController = self.prevViewController as! SettingsViewController
                            settingsViewController.refreshView()
                        }
                    }
                    let _ = self.navigationController?.popViewController(animated: true)
                    
                } else {
                    let errors: [String]? = error!["errors"] as? [String]
                    let alert: UIAlertController
                    if errors != nil && errors![0] != "" {
                        alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .alert)
                    } else {
                        alert = UIAlertController(title: "Error", message: "Unknown error", preferredStyle: .alert)
                    }
                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }))
        alertWarning.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.cancel, handler: nil))
        
        // show the alert
        self.present(alertWarning, animated: true, completion: nil)
    }
    
    // MARK: Withdraw Member.
    func withdrawMember() {
        let alertWarning = UIAlertController(title: "Warning", message: "Are you sure to withdraw member with this POD?", preferredStyle: UIAlertControllerStyle.alert)
        alertWarning.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
            // withdraw member from pod
            let podIdString = String(self.pod!.id!)
            let userIdString = String(self.networkController.currentUserId!)
            
            SVProgressHUD.show()
            self.networkController.deletePodMember(podIdString, userId: userIdString) { (error) -> () in
                if error == nil {
                    self.refreshCurrentPod()
                    
                } else {
                    SVProgressHUD.dismiss()
                    
                    let errors: [String]? = error!["errors"] as? [String]
                    let alert: UIAlertController
                    if errors != nil && errors![0] != "" {
                        alert = UIAlertController(title: "Error", message: errors![0], preferredStyle: .alert)
                    } else {
                        alert = UIAlertController(title: "Error", message: "Unknown error", preferredStyle: .alert)
                    }
                    let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }))
        alertWarning.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.cancel, handler: nil))
        
        // show the alert
        self.present(alertWarning, animated: true, completion: nil)
    }
    
    // MARK: Join Member.
    func joinMember() {
        SVProgressHUD.show()
        self.networkController.joinPodMember(String(pod!.id!), completionHandler: { (error) in
            if error != nil {
                SVProgressHUD.dismiss()
                Utils.presentAlertMessage("Error", message: "Error to join", cancelActionText: "Ok", presentingViewContoller: self)
            } else {
                self.refreshCurrentPod()
            }
        })
    }
    
    func refreshCurrentPod() {
        self.networkController.getPodById(String(self.pod!.id!), completionHandler: { (pod, error) in
            SVProgressHUD.dismiss()
            if(error == nil) {
                self.pod = pod
                self.tableViewPosts.reloadData()
                self.checkRightActionButton()
                
                if self.prevViewController != nil {
                    if self.prevViewController is PODsListViewController {
                        let listViewController = self.prevViewController as! PODsListViewController
                        listViewController.updatedPod(self.pod!)
                    } else if self.prevViewController is SettingsViewController {
                        let settingsViewController = self.prevViewController as! SettingsViewController
                        settingsViewController.refreshView()
                    }
                }
            }
        })
    }
}
