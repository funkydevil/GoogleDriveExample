//
// Created by Kirill on 05.08.14.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "VCFolderTable.h"


@implementation VCFolderTable
{

}






- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];

    [self setTopButtons];
}



- (void)viewDidAppear:(BOOL)animated
{
    if (self.kpGoogleDriveModel && self.navigationController.viewControllers.count>1)
        self.kpGoogleDriveModel.delegate = self;


}






#pragma mark - general


-(void)setTopButtons
{
    UIBarButtonItem *bCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                             target:self action:@selector(onCancelTapped:)];
    self.navigationItem.rightBarButtonItem = bCancel;
}




-(void)setKPGoogleDriveModel:(KP_GoogleDriveModel *)kpGoogleDriveModel andFolderId:(NSString *)folderId
{
    self.kpGoogleDriveModel = kpGoogleDriveModel;
    self.kpGoogleDriveModel.delegate = self;

    self.folderId = folderId;

    if (folderId)
        [self.kpGoogleDriveModel getFolderWithId:folderId];
}



-(void)segueToFolderWithId:(NSString *)folderId
{
    VCFolderTable *vcFolderTable = [[VCFolderTable alloc] init];
    [vcFolderTable setKPGoogleDriveModel:self.kpGoogleDriveModel andFolderId:folderId];
    vcFolderTable.delegate = self.navigationController;

    [self.navigationController pushViewController:vcFolderTable animated:YES];
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



-(void)onCancelTapped:(id)sender
{
    [self.delegate canceled];
}




#pragma mark - table delegate



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrDatasource.count;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }

    NSDictionary *dictItem = self.arrDatasource[indexPath.row];

    cell.textLabel.text = dictItem[@"name"];


    if ([dictItem[@"type"] isEqualToString:@"folder"])
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;


    return cell;
}





- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictItem = self.arrDatasource[indexPath.row];

    if ([dictItem[@"type"] isEqualToString:@"folder"])
    {
        [self segueToFolderWithId:dictItem[@"id"]];
    }
    else
    {
        [self.delegate fileSelected:dictItem];
    }
}







#pragma mark - kp google drive model delegate


- (void)didlLoadFolderWithId:(NSString *)folderId data:(NSArray *)arrData
{
    if ([folderId isEqualToString:self.folderId]) {
        self.arrDatasource = arrData;
        [self.tableView reloadData];
    }
}



- (void)didLoadRootFolderData:(NSArray *)arrData
{
    self.arrDatasource = arrData;
    [self.tableView reloadData];
}




- (void)willLoadData
{
    [self.activityIndicatorView startAnimating];
}



- (void)didLoadData
{
    [self.activityIndicatorView stopAnimating];
}




- (void)authOrOperationCanceled
{
    [self.delegate canceled];
}

@end