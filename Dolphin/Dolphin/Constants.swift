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
    
    struct Notifications {
        static let CreatedPost: String              = "CreatedPostNotification"
    }
    
    struct Messages {
        static let UnsupportedEmailTitle: String    = "Could Not Send Email"
        static let UnsupportedEmail: String         = "Your device could not send e-mail.  Please check e-mail configuration and try again."
        
        static let UnsupportedSMSTitle: String      = "Could Not Send SMS"
        static let UnsupportedSMS: String           = "Your device could not send SMS.  Please check SMS configuration and try again."
        
        static let Error_Report: String             = "Can't report this post."

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
    
    struct Fonts {
        static let Raleway_Regular: String          = "Raleway-Regular"
        static let Raleway_Bold: String             = "Raleway-Bold"
    }
    
    //Settings's Dolphin
    static let iTunesURL: String        = "https://itunes.apple.com/us/app/dolphin-web-browser-for-ipad/id460812023?mt=8"
    static let FacebookURL: String      = "https://www.facebook.com/lLoveDolphins/"
    static let InstagramURL: String     = "https://www.instagram.com/miami_dolphinsnews_/"
    static let TwitterURL: String       = "https://twitter.com/miamidolphins"
    
    
    //Setting's Support.
    static let FrequentlyAskedQuestionsURL: String          = "http://grants.nih.gov/grants/frequent_questions.htm"
    static let TermsOfUseURL: String                        = "http://dolphin.com/terms-of-use-for-dolphin-browser/"
    static let PrivacyPolicyURL: String                     = "http://dolphin.com/privacy/privacy-policy-for-dolphin-browser/"
    static let AdminEmail: String                           = "dolphin@admin.com"
    
}