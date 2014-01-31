//
//  MNSNumberTableViewController.m
//  Mensa
//
//  Created by Jordan Kay on 12/5/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "MNSNumber.h"
#import "MNSNumberView.h"
#import "MNSNumberViewController.h"
#import "MNSNumberTableViewController.h"
#import "MNSPrimeFlag.h"
#import "MNSPrimeFlagViewController.h"

#define COUNT 83
#define FONT_SIZE_MAX 105

@interface MNSNumberTableViewController ()

@property (nonatomic) NSMutableArray *objects;

@end

@implementation MNSNumberTableViewController

- (void)_setupObjects
{
    self.objects = [NSMutableArray arrayWithCapacity:COUNT];
    for (NSInteger i = 1; i <= COUNT; i++) {
        MNSNumber *number = [[MNSNumber alloc] initWithValue:i];
        [self.objects addObject:number];
//        if (number.isPrime) {
//            MNSPrimeFlag *flag = [[MNSPrimeFlag alloc] initWithNumber:number];
//            [self.objects addObject:flag];
//        }
    }
}

#pragma mark - NSObject

+ (void)initialize
{
    if (self == [MNSNumberTableViewController class]) {
        [MNSViewControllerRegistrar registerViewControllerClass:[MNSNumberViewController class] forModelClass:[MNSNumber class]];
        [MNSViewControllerRegistrar registerViewControllerClass:[MNSPrimeFlagViewController class] forModelClass:[MNSPrimeFlag class]];
    }
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self _setupObjects];
    }
    return self;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - MNSDataMediatorDelegate

- (void)dataMediator:(MNSDataMediator *)dataMediator didUseViewController:(MNSHostedViewController *)viewController withObject:(id)object
{
    if ([object isKindOfClass:[MNSNumber class]]) {
        // Custom font size changing behavior for this table view controller
        MNSNumber *number = (MNSNumber *)object;
        CGFloat fontSize = FONT_SIZE_MAX - number.value;
        MNSNumberView *view = (MNSNumberView *)[viewController viewForObject:number];
        view.valueLabel.font = [view.valueLabel.font fontWithSize:fontSize];
    }
}

- (NSArray *)sections
{
    return @[[MNSSection sectionWithTitle:@"Numbers and Prime Flags" objects:self.objects]];
}

@end
