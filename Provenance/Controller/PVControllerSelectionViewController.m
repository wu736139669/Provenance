//
//  PVControllerSelectionViewController.m
//  Provenance
//
//  Created by James Addyman on 19/09/2015.
//  Copyright © 2015 James Addyman. All rights reserved.
//

#import "PVControllerSelectionViewController.h"
#import "PVControllerManager.h"

@interface PVControllerSelectionViewController ()

@end

@implementation PVControllerSelectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

#if TARGET_OS_TV
    [self.splitViewController setTitle:@"Controller Settings"];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundView:nil];
#else
    [self setTitle:@"Controller Settings"];
#endif
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"controllerCell"];

    if ([indexPath row] == 0)
    {
        [cell.textLabel setText:@"Player 1"];
        if ([[PVControllerManager sharedManager] player1])
        {
            [cell.detailTextLabel setText:[[[PVControllerManager sharedManager] player1] vendorName]];
        }
        else
        {
            [cell.detailTextLabel setText:@"None Selected"];
        }
    }
    else
    {
        [cell.textLabel setText:@"Player 2"];
        if ([[PVControllerManager sharedManager] player2])
        {
            [cell.detailTextLabel setText:[[[PVControllerManager sharedManager] player2] vendorName]];
        }
        else
        {
            [cell.detailTextLabel setText:@"None Selected"];
        }
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Controller Assignment";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Select a controller for Player %zd", ([indexPath row] + 1)]
                                                                         message:@""
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    if ([self.traitCollection userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [[actionSheet popoverPresentationController] setSourceView:self.tableView];
        [[actionSheet popoverPresentationController] setSourceRect:[self.tableView rectForRowAtIndexPath:indexPath]];
    }

    for (GCController *controller in [GCController controllers])
    {
        NSString *title = [controller vendorName];
        if (controller == [[PVControllerManager sharedManager] player1])
        {
            title = [title stringByAppendingString:@" (Player 1)"];
        }

        if (controller == [[PVControllerManager sharedManager] player2])
        {
            title = [title stringByAppendingString:@" (Player 2)"];
        }

        [actionSheet addAction:[UIAlertAction actionWithTitle:title
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          if ([indexPath row] == 0)
                                                          {
                                                              [[PVControllerManager sharedManager] setPlayer1:controller];
                                                          }
                                                          else if ([indexPath row] == 1)
                                                          {
                                                              [[PVControllerManager sharedManager] setPlayer2:controller];
                                                          }

                                                          [self.tableView reloadData];
                                                      }]];
    }

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Not Playing" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([indexPath row] == 0)
        {
            [[PVControllerManager sharedManager] setPlayer1:nil];
        }
        else if ([indexPath row] == 1)
        {
            [[PVControllerManager sharedManager] setPlayer2:nil];
        }

        [self.tableView reloadData];
    }]];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:NULL]];



    [self presentViewController:actionSheet animated:YES completion:NULL];
}

@end
