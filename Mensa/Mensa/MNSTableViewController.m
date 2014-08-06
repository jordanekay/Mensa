//
//  MNSTableViewController.m
//  Mensa
//
//  Created by Jonathan Wight on 7/26/13.
//  Copyright (c) 2013 Jordan Kay. All rights reserved.
//

#import "MNSTableViewController.h"

@interface MNSTableViewController ()

@property (nonatomic) MNSDataMediator *dataMediator;

@end

@implementation MNSTableViewController

@synthesize sections = _sections;

static NSString *cellIdentifier = @"MNSTableViewCell";

- (void)reloadDataAndUpdateTableView
{
    [self.dataMediator reloadDataWithUpdate:YES];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.dataMediator = [[MNSDataMediator alloc] initWithDelegate:self];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.dataMediator reloadDataWithUpdate:NO];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0f;
    id object = [self.dataMediator backingObjectForRowAtIndexPath:indexPath];
    MNSHostingTableViewCell *metricsCell = (MNSHostingTableViewCell *)[self.dataMediator metricsCellForClass:[object class]];

    if (metricsCell) {
        // We need to adjust the metrics cell’s frame to handle table width changes (e.g. rotations)
        CGRect frame = metricsCell.frame;
        frame.size.width = self.tableView.bounds.size.width - metricsCell.layoutInsets.left - metricsCell.layoutInsets.right - 1.0f;
        metricsCell.frame = frame;

        // Set up the metrics cell using real populated content
        //[self.dataMediator useViewController:metricsCell.hostedViewController withObject:object];

        // Force a layout
        [metricsCell layoutIfNeeded];

        // Get the layout size; we ignore the width, in fact the width *could* conceivably be zero
        // Note: Using content view is intentional
        CGSize size = [metricsCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        height = size.height + 1.0f;
    }

    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataMediator backingObjectForRowAtIndexPath:indexPath];
    MNSHostingTableViewCell *cell = (MNSHostingTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self.dataMediator selectObject:object forViewController:cell.hostedViewController];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataMediator backingObjectForRowAtIndexPath:indexPath];
    MNSHostingTableViewCell *cell = (MNSHostingTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    return [self.dataMediator canSelectObject:object forViewController:cell.hostedViewController];
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataMediator backingObjectForRowAtIndexPath:indexPath];
    MNSHostingTableViewCell *cell = (MNSHostingTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.hostedViewController setViewHighlighted:YES forObject:object];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataMediator backingObjectForRowAtIndexPath:indexPath];
    MNSHostingTableViewCell *cell = (MNSHostingTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.hostedViewController setViewHighlighted:NO forObject:object];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataMediator numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataMediator numberOfObjectsInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.dataMediator titleForSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [self.dataMediator summaryForSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MNSHostingTableViewCell *cell;
    id object = [self.dataMediator backingObjectForRowAtIndexPath:indexPath];
    Class viewControllerClass = [MNSViewControllerRegistrar viewControllerClassForModelClass:[object class]];

    if (viewControllerClass) {
        NSString *reuseIdentifier = [viewControllerClass reuseIdentifierForObject:object];
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        if ([self respondsToSelector:@selector(dataMediator:willLoadHostedViewForViewController:)]) {
            [self dataMediator:self.dataMediator willLoadHostedViewForViewController:cell.hostedViewController];
        }

        [MNSViewHosting setParentViewController:self forCell:cell withObject:object];
        cell.userInteractionEnabled = [cell.hostedViewController viewForObject:object].userInteractionEnabled;
        [self.dataMediator useViewController:cell.hostedViewController withObject:object];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    return cell;
}

#pragma mark - MNSDataMediatorDelegate

- (Class)cellClass:(MNSDataMediator *)dataMediator
{
    return [MNSHostingTableViewCell class];
}

- (void)dataMediator:(MNSDataMediator *)dataMediator didReloadDataWithUpdate:(BOOL)update
{
    if (update) {
        [self.tableView reloadData];
    }
}

- (void)dataMediator:(MNSDataMediator *)dataMediator willUseCellClass:(Class)cellClass forReuseIdentifiers:(NSArray *)reuseIdentifiers
{
    for (NSString *reuseIdentifier in reuseIdentifiers) {
        [self.tableView registerClass:cellClass forCellReuseIdentifier:reuseIdentifier];
    }
}

- (void)dataMediator:(MNSDataMediator *)dataMediator willUseMetricsCell:(MNSHostingTableViewCell *)metricsCell
{
    [metricsCell useAsMetricsCellInTableView:self.tableView];
}

@end
