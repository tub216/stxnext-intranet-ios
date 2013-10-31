//
//  UserTableViewController.m
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "UserTableViewController.h"
#import "APIMapping.h"
#import "APIRequest.h"
#import "HTTPClient.h"
#import "HTTPClient+Cookies.h"
#import "UserListCell.h"
#import "UserDetailsTableViewController.h"

@implementation UserTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Odśwież"];
    [refresh addTarget:self action:@selector(startRefreshData)forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    _userList = [NSArray array];
    self.title = @"Lista osób";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[HTTPClient sharedClient] authCookiesPresent])
    {
        // assume you are logged in, but cookies may be invalid; send request with stored cookies
        [self downloadUsers];
    }
    else
    {
        [self showLoginScreen];
    }
}

#pragma mark Login delegate

- (void)showLoginScreen
{
    [LoginViewController presentAfterSetupWithDecorator:^(UIModalViewController *controller) {
        LoginViewController* customController = (LoginViewController*)controller;
        customController.delegate = self;
    }];
}

- (void)finishedLoginWithCode:(NSString*)code withError:(NSError*)error
{
    // Assume success, use code to fetch cookies
    [[HTTPClient sharedClient] startOperation:[APIRequest loginWithCode:code]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          // We expect 302
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:operation.response.allHeaderFields forURL:operation.response.URL];
                                          
                                          [[HTTPClient sharedClient] saveCookies:cookies];
                                          
                                          // If redirected properly
                                          if (operation.response.statusCode == 302 && cookies)
                                          {
                                              [self downloadUsers];
                                          }
                                      }];
}

- (void)startRefreshData
{
    [self downloadUsers];
}

- (void)stopRefreshData
{
    [self.refreshControl endRefreshing];
}

- (void)downloadUsers
{
    [[HTTPClient sharedClient] startOperation:[APIRequest getUsers]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          NSMutableArray* users = [NSMutableArray array];
                                          
                                          for (id user in responseObject[@"users"])
                                          {
                                              [users addObject:[RMUser mapFromJSON:user]];
                                          }
                                          
                                          _userList = users;
                                          [self.tableView reloadData];
                                          [self performSelector:@selector(stopRefreshData) withObject:nil afterDelay:0.5];
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          [self performSelector:@selector(stopRefreshData) withObject:nil afterDelay:0.5];
                                      }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RMUser* user = _userList[indexPath.row];
    
    NSLog(@"%@", user);
    
    static NSString *CellIdentifier = @"UserCell";
    UserListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[UserListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.userName.text = user.name;
    
    
    // [cell.userImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://intranet.stxnext.pl%@", user.avatarURL]] placeholderImage:nil];
    
    [self setImageForUrl:[NSString stringWithFormat:@"https://intranet.stxnext.pl%@", user.avatarURL] cell:cell];
    
    cell.userImage.layer.cornerRadius = 5;
    cell.userImage.clipsToBounds = YES;
    
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[UserDetailsTableViewController class]])
    {
        UserListCell *cell = (UserListCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        ((UserDetailsTableViewController *)segue.destinationViewController).user = _userList[indexPath.row];
        
    }
}

#pragma mark - Utilities

- (void)setImageForUrl:(NSString *)urlStr cell:(UserListCell *)cell
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [[HTTPClient sharedClient] addAuthCookiesToRequest:request];
    [cell.userImage setImageWithURLRequest:request placeholderImage:nil success:nil failure:nil];
}

@end