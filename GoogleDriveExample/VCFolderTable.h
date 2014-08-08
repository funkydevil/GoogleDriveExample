//
// Created by Kirill on 05.08.14.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KP_GoogleDriveModel.h"


@protocol VCFolderTableDelegate
    -(void)fileSelected:(NSDictionary *)fileInfo;
    -(void)canceled;
@end


@interface VCFolderTable : UIViewController <UITableViewDelegate, UITableViewDataSource, KP_GoogleDriveModelDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSString *folderId;
@property (nonatomic, strong) NSArray *arrDatasource;
@property (nonatomic, strong) KP_GoogleDriveModel *kpGoogleDriveModel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, weak) id <VCFolderTableDelegate> delegate;


- (void)setKPGoogleDriveModel:(KP_GoogleDriveModel *)kpGoogleDriveModel andFolderId:(NSString *)folderId;

@end