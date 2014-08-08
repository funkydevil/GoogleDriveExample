//
//  KP_GoogleDriveChooser.h
//  skyDriveExample
//
//  Created by Kirill on 05.08.14.
//  Copyright (c) 2014 Kirill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCFolderTable.h"
#import "KP_GoogleDriveModel.h"

@class KP_GoogleDriveChooser;


@protocol KP_GoogleDriveChooserDelegate
    -(void)KP_GoogleDriveChooser:(KP_GoogleDriveChooser *)kpGoogleDriveChooser fileChoosed:(NSDictionary *)fileInfo;
    -(void)KP_GoogleDriverChooserCanceled:(KP_GoogleDriveChooser *)kpGoogleDriveChooser;
@end


@interface KP_GoogleDriveChooser : UINavigationController <VCFolderTableDelegate, KP_GoogleDriveModelDelegate>
@property (nonatomic, strong) VCFolderTable *vcFolderTable;
@property (nonatomic, strong) KP_GoogleDriveModel *kpGoogleDriveModel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, weak) id <KP_GoogleDriveChooserDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary *choosedFileInfo;
@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, strong) UIView *vOverlay;


- (id)initWithClientId:(NSString *)appId andClientSecret:(NSString *)clientSecret;
@end
