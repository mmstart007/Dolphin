//
//  ChooseSourceTypeView.swift
//  Dolphin
//
//  Created by Joachim on 8/22/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import UIKit

@objc protocol ChooseSourceTypeViewDelegate{
    @objc optional func closedDialog()
    @objc optional func selectedCamera()
    @objc optional func selectedPhotoGallery()
}


class ChooseSourceTypeView: UIView {
    var delegate: ChooseSourceTypeViewDelegate?

    class func instanceFromNib() -> ChooseSourceTypeView {
        return UINib(nibName: "ChooseSourceTypeView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ChooseSourceTypeView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 10
        self.layer.cornerRadius = 3.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func didTapClose() {
        self.delegate?.closedDialog!()
    }
    
    @IBAction func didTapCamera() {
        self.delegate?.selectedCamera!()
    }
    
    @IBAction func didTapPhotoGallery() {
        self.delegate?.selectedPhotoGallery!()
    }
}
