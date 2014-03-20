//
//  NewPokerSessionTableViewController.h
//  Intranet
//
//  Created by Adam on 11.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PokerSession.h"
#import "TextInputViewController.h"
#import "CardsTypeTableViewController.h"
#import "TeamsTableViewController.h"
#import "PokerVoteViewController.h"
#import "PlaningPokerViewController.h"

typedef NS_ENUM(NSUInteger, PokerSessionType)
{
    PokerSessionTypeNewQuick,
    PokerSessionTypeNewNormal,
    PokerSessionTypeEdit,
    PokerSessionTypePlay
};

@protocol PokerSessionTableViewControllerDelegate;
@interface PokerSessionTableViewController : UITableViewController <TextInputViewControllerDelegate, CardsTypeTableViewControllerDelegate, TeamsTableViewControllerDelegate>
{
    BOOL isDatePickerHidden;
    UIDatePicker *datePicker;
    NSInteger itemToChange;
}

//@property (nonatomic, strong) NSMutableArray *ticketList;
@property (nonatomic, strong) id<PokerSessionTableViewControllerDelegate> delegate;
@property (nonatomic, assign) PokerSessionType pokerSessionType;
@property (nonatomic, strong) PokerSession *pokerSession;

@end

@protocol PokerSessionTableViewControllerDelegate <NSObject>

- (void)pokerSessionTableViewController:(PokerSessionTableViewController *)pokerSessionTableViewController didFinishWithPokerSession:(PokerSession *)pokerSession;

@end