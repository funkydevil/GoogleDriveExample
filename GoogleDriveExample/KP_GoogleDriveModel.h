//
// Created by Kirill on 07.08.14.
// Copyright (c) 2014 Kirill Pyulzyu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"

@protocol KP_GoogleDriveModelDelegate
-(void)willLoadData;
-(void)didLoadData;

@optional
-(void)didlLoadFolderWithId:(NSString *)folderId data:(NSArray *)arrData;
-(void)didLoadRootFolderData:(NSArray *)arrData;
-(void)authOrOperationCanceled;
-(void)didMakeFilePublic:(NSString *)fileId;
@end


@interface KP_GoogleDriveModel : NSObject

@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *clientSecretKey;
@property (nonatomic, strong) UIViewController *vcContext;
@property (nonatomic, strong) GTLServiceDrive *driveService;
@property (nonatomic, weak) id <KP_GoogleDriveModelDelegate> delegate;

- (instancetype)initWithClientId:(NSString *)clientId clientSecretKey:(NSString *)clientSecretKey vcContext:(UIViewController *)vcContext;


- (void)getFolderWithId:(NSString *)folderId;

- (void)makeFilePublic:(NSString *)fileId;
@end