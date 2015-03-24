//
//  EventViewController.h
//  Surbiton Food Festival
//
//  Created by Laurence Archer on 15/02/2015.
//  Copyright (c) 2015 Spirit of Seething. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "GAITrackedViewController.h"

@interface EventViewController : GAITrackedViewController
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (retain,nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (retain,nonatomic) IBOutlet UILabel *eventDateLabel;
@property (retain,nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueLabel;
- (IBAction)mapButtonPressed:(id)sender;
@property (nonatomic, weak) IBOutletCollection(NSLayoutConstraint) NSArray *topConstraint;
@property (nonatomic) BOOL reminderSet;
@property (retain,nonatomic) Event *event;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
@end
