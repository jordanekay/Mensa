//
//  MNSPropertyViewController.h
//  Mensa
//
//  Created by Jordan Kay on 12/15/13.
//  Copyright (c) 2013 toxicsoftware. All rights reserved.
//

#import "MNSHostedViewController.h"

@class MNSProperty;

@interface MNSPropertyViewController : MNSHostedViewController <UITextFieldDelegate>

@property (nonatomic) MNSProperty *inputProperty;

@end
