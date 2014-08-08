//
//  KP_GoogleDriveChooser.m
//  skyDriveExample
//
//  Created by Kirill on 05.08.14.
//  Copyright (c) 2014 Kirill. All rights reserved.
//

#import "KP_GoogleDriveChooser.h"

@interface KP_GoogleDriveChooser ()

@end

@implementation KP_GoogleDriveChooser


- (id)initWithClientId:(NSString *)clientId andClientSecret:(NSString *)clientSecret
{
    VCFolderTable *vc = [[VCFolderTable alloc] init];
    self = [super initWithRootViewController:vc];
    if (self)
    {
        self.vcFolderTable = vc;
        vc.delegate = self;

        self.clientId = clientId;
        self.clientSecret = clientSecret;
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.




//    self.navigationItem.leftBarButtonItems = @[bCancel];
//    NSLog(@"%@", self.navigationItem);

    //[self.navigationItem setLeftBarButtonItem:bCancel animated:YES];
}



- (void)viewDidAppear:(BOOL)animated
{
    if (!self.kpGoogleDriveModel)
    {
        self.kpGoogleDriveModel = [[KP_GoogleDriveModel alloc] initWithClientId:self.clientId
                                                              clientSecretKey:self.clientSecret
                                                                    vcContext:self.vcFolderTable];


        [self.vcFolderTable setKPGoogleDriveModel:self.kpGoogleDriveModel andFolderId:nil];
    }

}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIActivityIndicatorView *)activityIndicatorView
{
    if (!_activityIndicatorView)
    {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicatorView.center = self.view.center;
        _activityIndicatorView.hidesWhenStopped = YES;
        _activityIndicatorView.color = [UIColor grayColor];
        [self.view addSubview:_activityIndicatorView];
    }

    return _activityIndicatorView;
}


- (UIView *)vOverlay
{
    if (!_vOverlay)
    {
        _vOverlay = [[UIView alloc] initWithFrame:self.view.frame];
        _vOverlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        [self.view addSubview:_vOverlay];
    }

    return _vOverlay;
}





#pragma mark folders delegate

- (void)fileSelected:(NSDictionary *)fileInfo
{
    self.choosedFileInfo = [fileInfo mutableCopy];
    [self popToRootViewControllerAnimated:YES];

    self.kpGoogleDriveModel.delegate = self;

    [self.kpGoogleDriveModel makeFilePublic:fileInfo[@"id"]];
}

- (void)canceled
{
    [self.delegate KP_GoogleDriverChooserCanceled:self];
}




#pragma mark - SkyDrive delegate



- (void)willLoadData
{
    self.vOverlay.hidden = NO;
    [self.activityIndicatorView startAnimating];
}



- (void)didLoadData
{
    self.vOverlay.hidden = YES;
    [self.activityIndicatorView stopAnimating];
}

- (void)didMakeFilePublic:(NSString *)fileId
{
    [self.delegate KP_GoogleDriveChooser:self fileChoosed:self.choosedFileInfo];
}


- (void)authOrOperationCanceled
{
    [self.delegate KP_GoogleDriverChooserCanceled:self];
}


@end
