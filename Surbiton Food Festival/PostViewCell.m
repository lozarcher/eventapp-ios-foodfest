//
//  PostViewCell.m
//  IYAF 2015
//
//  Created by Loz Archer on 29/05/2015.
//  Copyright (c) 2015 Spirit of Seething. All rights reserved.
//

#import "PostViewCell.h"
#import "PostListViewController.h"
#import "UIImageView+WebCache.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

@implementation PostViewCell

@synthesize messageLabel, delegate, linkLabel, dateLabel, cardView, postImageView;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.bounds = [UIScreen mainScreen].bounds;

    self.fd_enforceFrameLayout = YES;

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat newFrameWidth = screenRect.size.width;
    CGFloat newFrameHeight = 0;
    CGRect newFrame = CGRectMake(0, 0, newFrameWidth, newFrameHeight);
    //    self.postImageHeight = 0;
    //    self.imageHeightConstraint.constant = 0;
    [self.postImageView setFrame:newFrame];
    [self.postImageView setImage:nil];
    
    // Initialization code
    messageLabel.urlLinkTapHandler = ^(KILabel *label, NSString *urlString, NSRange range) {
        NSLog(@"Clicked link");
        [self.delegate loadURL:urlString];

    };
}

-(void)preloadImage:(Post *)post {
    if ((post.id != nil) && ![[post pictureUrl] isKindOfClass:[NSNull class]]) {
        // asynchronously download the image
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        if (post.cachedImage== nil) {
            [manager downloadImageWithURL:[NSURL URLWithString:[post pictureUrl]] options:0
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 }
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                    post.cachedImage = image;
                                    [self setPostImage:image];
                                    if (error != nil) {
                                        [CrashlyticsKit recordError:error];
                                    }
                                }];
        }
    }
}

-(void)populateDataInCell:(Post *)post indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    self.indexPath = indexPath;
    self.tableView = tableView;
    self.textLabel.text = @"";
    NSString *message = @" ";


    if (![[post message] isKindOfClass:[NSNull class]]) {
        message = [post message];
    }
    if (![[post link] isKindOfClass:[NSNull class]]) {
        NSString *link = [post link];

        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"http.*www\\.facebook\\.com.*\\/photos\\/"
                                                                          options:0
                                                                            error:nil];
        
        if (link != NULL) {
            long matches = [regex numberOfMatchesInString:link
                                            options:0
                                              range:NSMakeRange(0, [link length])];
            
            
            if (!matches){
                //Matches
                if ([message isEqualToString:@""]) {
                    message = [post link];
                } else {
                    // dedupe links if already present in message
                    if (![message containsString:[post link]]) {
                        message = [NSString stringWithFormat:@"%@\n\n%@", message, [post link]];
                    }
                }
            }
        }
    }
    [self.messageLabel setText:message];
    
    if (![[post createdDate] isKindOfClass:[NSNull class]]) {
        NSTimeInterval createdSeconds = [post.createdDate doubleValue]/1000;
        NSDate *createdDate = [[NSDate alloc] initWithTimeIntervalSince1970:createdSeconds];
        [self.dateLabel setText:[self dateDiff:createdDate]];
    
    }
    self.tag = indexPath.row;

    if (post.cachedImage != nil) {
        [self setPostImage:post.cachedImage];
    } else {
        // image is null
        self.imageHeightConstraint.constant = 0;
        [self.postImageView setImage:nil];
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
}

-(void)setPostImage:(UIImage *)image {
    [self.tableView beginUpdates];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat newFrameWidth = screenRect.size.width;
    CGFloat newFrameHeight = image.size.height * (newFrameWidth / image.size.width);
    CGRect newFrame = CGRectMake(0, 0, newFrameWidth, newFrameHeight);
    [self.postImageView setFrame:newFrame];
    [self.postImageView setImage:image];
    self.imageHeightConstraint.constant = newFrameHeight;
    [self.tableView endUpdates];
}

// If you are not using auto layout, override this method, enable it by setting
// "fd_enforceFrameLayout" to YES.
- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat totalHeight = 0;
    totalHeight += [self.dateLabel sizeThatFits:size].height;
    if ([self.dateLabel sizeThatFits:size].height != 0) {
        totalHeight += 5;
    }
    totalHeight += self.imageHeightConstraint.constant;
    if (self.imageHeightConstraint.constant != 0) {
        totalHeight += 20;
    }
    totalHeight += [self.messageLabel sizeThatFits:size].height;
    if ([self.messageLabel sizeThatFits:size].height != 0) {
        totalHeight += 60;
    }
    return CGSizeMake(size.width, totalHeight);
}

-(NSString *)dateDiff:(NSDate *)date {
    NSDate *todayDate = [NSDate date];
    double ti = [date timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    if(ti < 1) {
        return @"Just now";
    } else     if (ti < 60) {
        return @"Just now";
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        if (diff == 1) {
            return [NSString stringWithFormat:@"%d minute ago", diff];
        } else {
            return [NSString stringWithFormat:@"%d minutes ago", diff];
        }
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        if (diff == 1) {
            return[NSString stringWithFormat:@"%d hour ago", diff];
        } else {
            return[NSString stringWithFormat:@"%d hours ago", diff];
        }
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        if (diff == 1) {
            return[NSString stringWithFormat:@"%d day ago", diff];
        } else {
            return[NSString stringWithFormat:@"%d days ago", diff];
        }
    } else {
        int diff = round(ti / 60 / 60 / 24 / 30);
        if (diff == 1) {
            return[NSString stringWithFormat:@"%d month ago", diff];
        } else {
            return[NSString stringWithFormat:@"%d months ago", diff];
        }
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.postImageView sd_cancelCurrentImageLoad];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    [self.cardView setAlpha:1];
    self.cardView.layer.masksToBounds = NO;
    self.cardView.layer.cornerRadius = 4;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
