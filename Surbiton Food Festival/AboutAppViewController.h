//
//  AboutAppViewController.h
//  Surbiton Food Festival
//
//  Created by Loz Archer on 19/03/2015.
//  Copyright (c) 2015 Spirit of Seething. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import <MessageUI/MFMessageComposeViewController.h>

@interface AboutAppViewController : GAITrackedViewController <MFMessageComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *lozButton;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end
