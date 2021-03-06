//
//  EventViewController.m
//  Surbiton Food Festival
//
//  Created by Laurence Archer on 15/02/2015.
//  Copyright (c) 2015 Spirit of Seething. All rights reserved.
//

#import "EventViewController.h"
#import "UIImageView+WebCache.h"
#import "VenueViewController.h"
#import "FontAwesomeKit/FAKFontAwesome.h"
#import <UIKit/UIKit.h>
#import <Crashlytics/Crashlytics.h>

@implementation EventViewController

@synthesize eventTitleLabel, eventDateLabel, eventImageView, eventDescriptionLabel, closeButton, event, eventTimeLabel, venueLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadURL:(NSString *)urlString {
    if (![urlString hasPrefix:@"http"]) {
        urlString = [NSString stringWithFormat:@"http://%@", urlString];
    }
    NSLog(@"Loading URL %@ from view controller", urlString);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}



- (IBAction)closeButtonPressed:(id)sender {
       [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    eventDescriptionLabel.urlLinkTapHandler = ^(KILabel *label, NSString *urlString, NSRange range) {
        NSLog(@"Clicked link: %@", urlString);
        
        [self loadURL:urlString];
    };
    
    [self setFavouriteButtonIcon];
    if (![event.coverUrl isKindOfClass:[NSNull class]]) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[NSURL URLWithString:[event coverUrl]]
                              options:0
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 // progression tracking code
                             }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                if (image) {
                                    [self setImage:image];
                                    if (error != nil) {
                                        [CrashlyticsKit recordError:error];
                                    }
                                }
                            }
         ];
    } else {
        [self setImage:[UIImage imageNamed:@"logo.jpg"]];
    }
    
    // Do any additional setup after loading the view from its nib.
    eventTitleLabel.text = event.name;
    if (![[event desc] isKindOfClass:[NSNull class]]) {
        eventDescriptionLabel.text = event.desc;
    } else {
        eventDescriptionLabel.text = @"";
    }
    if (![[event location] isKindOfClass:[NSNull class]]) {
        venueLabel.text = event.location;
    } else {
        venueLabel.text = @"Surbiton";
    }
    
    NSTimeInterval startSeconds = [event.startTime doubleValue]/1000;
    NSDate *startDate = [[NSDate alloc] initWithTimeIntervalSince1970:startSeconds];
    NSDate *endDate = nil;
    if ([event.endTime isKindOfClass:[NSNull class]]) {
        endDate = nil;
    } else {
        NSTimeInterval endSeconds = [event.endTime doubleValue]/1000;
        endDate = [[NSDate alloc] initWithTimeIntervalSince1970:endSeconds];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"eee d MMMM yyyy"];
    eventDateLabel.text = [dateFormatter stringFromDate:startDate];
    
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *timeText = [dateFormatter stringFromDate:startDate];
    if (endDate != nil) {
        [dateFormatter setDateFormat:@"HH:mm"];
        NSString *endDateString = [dateFormatter stringFromDate:endDate];
        NSArray* dates = [[NSArray alloc] initWithObjects:timeText, endDateString, nil];
        timeText = [dates componentsJoinedByString:@" - "];
    }
    eventTimeLabel.text = timeText;
    
    //[self.mapButton setHidden:[event.venue isKindOfClass:[NSNull class]]];
    if ([event.venue isKindOfClass:[NSNull class]]) {
        [self.mapButton removeFromSuperview];
    }
    
    if ([event.ticketUrl isKindOfClass:[NSNull class]]) {
        [self.buyTicketsButton removeFromSuperview];
    }
    
    [Answers logContentViewWithName:event.name
                        contentType:@"Events"
                          contentId:event.id
                   customAttributes:@{}];
}

- (IBAction)shareButtonPressed:(id)sender {
    NSString *textToShare = event.name;
    NSURL *eventUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.facebook.com/events/%@", event.eventId]];
    NSArray *objectsToShare = @[textToShare, eventUrl];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo,
                                   @"com.apple.mobilenotes.SharingExtension",
                                   @"com.apple.reminders.RemindersEditorExtension"];
    
    activityVC.excludedActivityTypes = excludeActivities;
    [self presentViewController:activityVC animated:YES completion:nil];
}

-(void)setImage:(UIImage *)image {
    [eventImageView setImage:image];
    [eventImageView setNeedsLayout];
    [eventImageView layoutIfNeeded];
    if (eventImageView.frame.size.width < (eventImageView.image.size.width)) {
        _imageHeightConstraint.constant = (eventImageView.frame.size.width / (eventImageView.image.size.width)) * eventImageView.image.size.height;
    } else {
        _imageHeightConstraint.constant = image.size.height;
    }
}

-(void)setFavouriteButtonIcon {
    FAKFontAwesome *favIcon;
    if (self.event.isFavourite) {
        favIcon = [FAKFontAwesome heartIconWithSize:20];
    } else {
        favIcon = [FAKFontAwesome heartOIconWithSize:20];
    }
    FAKFontAwesome *shareIcon = [FAKFontAwesome shareSquareOIconWithSize:20];
    UIBarButtonItem *favButtonItem = [[UIBarButtonItem alloc] initWithImage:[favIcon imageWithSize:CGSizeMake(20,20)] style:UIBarButtonItemStylePlain target:self action:@selector(favouriteButtonPressed:)];
    UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc] initWithImage:[shareIcon imageWithSize:CGSizeMake(20,20)] style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonPressed:)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:favButtonItem, shareButtonItem, nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)mapButtonPressed:(id)sender {
    VenueViewController *venueVc = [[VenueViewController alloc] initWithNibName:@"VenueViewController" bundle:nil];
    [self presentViewController:venueVc animated:YES completion:nil];
    [venueVc createVenue:event.venue location:event.location];
}

- (void)favouriteButtonPressed:(id)sender {
    NSLog(@"Favourite button pressed for event %@",event.id);
    NSDictionary *dict = [NSDictionary dictionaryWithObject:self.event forKey:@"event"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"favouriteEvent"
     object:dict
     userInfo:dict];
    self.event.isFavourite = !self.event.isFavourite;
    [self setFavouriteButtonIcon];
    [Answers logContentViewWithName:[NSString stringWithFormat:@"Favourite: %@",event.name]
                        contentType:@"Favourite"
                          contentId:[NSString stringWithFormat:@"f%@",event.id]
                   customAttributes:@{}];
}

- (IBAction)ticketsButtonPressed:(id)sender {
    NSString *urlString = event.ticketUrl;
    if (![urlString hasPrefix:@"http"]) {
        urlString = [NSString stringWithFormat:@"http://%@", urlString];
    }
    NSLog(@"Loading URL %@", urlString);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

@end
