//
//  NSObject+UIAppearance_Swift.h
//  GoRun
//
//  Created by MARTIN ZUNIGA on 1/2/16.
//  Copyright © 2016 hattrick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (UIAppearance_Swift)
/// @param containers An array of Class<UIAppearanceContainer>
+ (instancetype)my_appearanceWhenContainedWithin: (NSArray *)containers;
@end

@interface UIBarButtonItem (UIAppearance_Swift)
/// @param containers An array of Class<UIAppearanceContainer>
+ (instancetype)my_appearanceWhenContainedWithin: (NSArray *)containers;
@end
