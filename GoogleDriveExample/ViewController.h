//
// Created by Kirill on 07.08.14.
// Copyright (c) 2014 Kirill Pyulzyu. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "KP_GoogleDriveModel.h"

#import "KP_GoogleDriveChooser.h"


@interface ViewController : UIViewController <KP_GoogleDriveChooserDelegate>

@property (nonatomic, strong) KP_GoogleDriveChooser *kpGoogleDriveChooser;

@end