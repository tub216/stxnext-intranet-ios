//
//  UserDetailsViewController.h
//  Intranet
//
//  Created by Adam on 30.10.2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "APIMapping.h"

@interface UserDetailsTableViewController : UITableViewController <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneDeskLabel;
@property (weak, nonatomic) IBOutlet UILabel *skypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *ircLabel;
@property (weak, nonatomic) IBOutlet UILabel *userName;

@property (weak, nonatomic) IBOutlet UITableViewCell *phoneDeskCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *phoneCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *emailCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *skypeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *ircCell;

@property (strong, nonatomic) RMUser *user;

@end