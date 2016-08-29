//
//  Constants.swift
//  Dolphin
//
//  Created by Ninth Coast on 3/11/16.
//  Copyright © 2016 Ninth Coast. All rights reserved.
//

import Foundation

class Constants {
    
    struct RESTAPIConfig {
        struct Developement {
            static let BaseUrl: String = "http://dolphin-api.ninthcoast.com/"
        }
    }
    
    struct Globals {
        static let ImageCompression: CGFloat        = 0.5
        static let ImageMaxWidth: CGFloat           = 500
    }
    
    struct Notifications {
        static let CreatedPost: String              = "CreatedPostNotification"
        static let DeletedPost: String              = "DeletedPostNotification"
        static let CreatedPod: String               = "CreatedPodNotification"
        
    }
    
    struct Messages {
        
        static let UnsupportedEmailTitle: String    = "Could Not Send Email"
        static let UnsupportedEmail: String         = "Your device could not send e-mail.  Please check e-mail configuration and try again."
        static let UnsupportedSMSTitle: String      = "Could Not Send SMS"
        static let UnsupportedSMS: String           = "Your device could not send SMS.  Please check SMS configuration and try again."
        static let Error_Report: String             = "Can't report this post."
        static let ShareSuffix: String              = "sent from Dolphin, a new App for Educators"
        
        //Login & Sign up
        static let EmailErrorTitle: String          = "Email error"
        static let EmailErrorMsg: String            = "Wrong format"
        static let PasswordErrorTitle: String       = "Password error"
        static let PasswordErrorMsg: String         = "Password should be at least 5 characters long"
        static let UsernameErrortitle: String       = "Username error"
        static let UsernameErrorMsg: String         = "Username empty"
        static let PostTitleErrorMsg: String        = "Please input valid title."
        
        //
        static let RemovePostMsg: String            = "Are you sure to remove post?"
    }
    
    struct InviteType {
        static let Invite_Contact: Int              = 0
        static let Invite_Facebook: Int             = 1
        static let Invite_Twitter: Int              = 2
        static let Invite_Instagram: Int            = 3
    }
    
    struct Popular {
        static let Topic_Limit: Int                 = 9
        static let Pod_Limit: Int                   = 3
        static let Post_Limit: Int                  = 25
    }
    
    struct ShareType {
        static let Share_Other: Int                 = 0
        static let Share_Mail: Int                  = 1
        static let Share_SMS: Int                   = 2
        static let Share_Facebook: Int              = 3
        static let Share_Twitter: Int               = 4
    }
    
    struct Fonts {
        static let Raleway_Regular: String          = "Raleway-Regular"
        static let Raleway_Bold: String             = "Raleway-Bold"
    }
    
    //Settings's Dolphin
    static let iTunesURL: String                    = "https://itunes.apple.com/us/app/dolphin-web-browser-for-ipad/id460812023?mt=8"
    static let FacebookURL: String                  = "https://www.facebook.com/lLoveDolphins/"
    static let InstagramURL: String                 = "https://www.instagram.com/miami_dolphinsnews_/"
    static let TwitterURL: String                   = "https://twitter.com/miamidolphins"
    
    
    //Setting's Support.
    static let FrequentlyAskedQuestionsURL: String          = "http://grants.nih.gov/grants/frequent_questions.htm"
    static let TermsOfUseURL: String                        = "http://dolphin.com/terms-of-use-for-dolphin-browser/"
    static let PrivacyPolicyURL: String                     = "http://dolphin.com/privacy/privacy-policy-for-dolphin-browser/"
    static let AdminEmail: String                           = "dolphin@admin.com"
    
    
    enum UIUserInterfaceIdiom : Int
    {
        case Unspecified
        case Phone
        case Pad
    }
    
    struct ScreenSize
    {
        static let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
        static let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height
        static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    }
    
    struct DeviceType
    {
        static let IS_IPHONE_4_OR_LESS  = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
        static let IS_IPHONE_5          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
        static let IS_IPHONE_6          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
        static let IS_IPHONE_6P         = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
        static let IS_IPAD              = UIDevice.currentDevice().userInterfaceIdiom == .Pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
        static let IS_IPAD_PRO          = UIDevice.currentDevice().userInterfaceIdiom == .Pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
    }
}