//
//  PostDetailsViewController.m
//  Nooves
//
//  Created by Nkenna Aniedobe on 7/31/18.
//  Copyright © 2018 Nikki Tran. All rights reserved.
//

#import "PostDetailsViewController.h"
#import <FIRDatabase.h>
#import "ProfileViewController.h"
#import "PureLayout/PureLayout.h"
@interface PostDetailsViewController ()
@property (strong, nonatomic) Post *post;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) UILabel *phoneNumberLabel;
@property (strong, nonatomic) UIImageView *profilePicImage;
@property (strong, nonatomic) UILabel *activityTitleLabel;
@property (strong, nonatomic) UILabel *activityDescriptionLabel;
@property (strong, nonatomic) UILabel *activityDateAndTimeLabel;
@property (strong, nonatomic) UILabel *activityTypeLabel;
@property (strong, nonatomic) UILabel *activtyLocationLabel;
@property (nonatomic) BOOL going;
@property (strong, nonatomic) UIButton *goingButton;
@end

@implementation PostDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    FIRDatabaseReference *reference = [[FIRDatabase database] reference];
    FIRDatabaseHandle *databaseHandle = [[[reference child:@"Users"]child:self.post.userID] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *usersDictionary = snapshot.value;
        if (![snapshot.value isEqual:[NSNull null]]) {
            self.user = [[User alloc] initFromDatabase:usersDictionary];
            if (![self.user.profilePicURL isEqualToString:@"nil"]){
                NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:self.user.profilePicURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if(error){
                        NSLog(@"%@", error);
                        return;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.profilePicImage.image = [UIImage imageWithData:data];
                    });
                }];
                [task resume];
            }
        }
        else {
            FIRDatabaseReference *userRef = [[reference child:@"Users"]child:self.post.userID];
            [userRef setValue:@{@"Age":@(0), @"Bio":@"nil", @"Name":@"Unnamed User",@"PhoneNumber":@(0), @"ProfilePicURL":@"nil",@"EventsGoing":@[@"a"]}];
        }
    }];
    self.going = NO;
    for (NSString *uid in self.post.usersGoing){
        if ([[FIRAuth auth].currentUser.uid isEqualToString:uid]){
            self.going = YES;
            break;
        }
    }
    self.profilePicImage = [[UIImageView alloc] init];
    self.profilePicImage.image = [UIImage imageNamed:@"profile-blank"];
    self.profilePicImage.frame = CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.height*9/20));
    [self.view addSubview:self.profilePicImage];
    if(self.post){
        self.activityTitleLabel = [[UILabel alloc] init];
        self.activityTitleLabel.text = self.post.activityTitle;
        [self.activityTitleLabel sizeToFit];
        [self.activityTitleLabel.font fontWithSize:80];
        self.activityTitleLabel.center = self.view.center;
        [self.view addSubview:self.activityTitleLabel];
        self.activityTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height/2+30, 10, 10)];
        self.activityTypeLabel.text = [@"Activity Type: " stringByAppendingString:[Post activityTypeToString:self.post.activityType]];
        [self.activityTypeLabel sizeToFit];
        [self.view addSubview:self.activityTypeLabel];
        self.activityDateAndTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height/2+60, 10, 10)];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"MM/dd HH:mm"];
        NSString *dateString = [formatter stringFromDate:self.post.activityDateAndTime];
        self.activityDateAndTimeLabel.text = [@"Date and Time: " stringByAppendingString:dateString];
        [self.activityDateAndTimeLabel sizeToFit];
        [self.view addSubview:self.activityDateAndTimeLabel];
        self.activtyLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height/2+90, 10, 10)];
        self.activtyLocationLabel.text = [@"Location: " stringByAppendingString:self.post.activityLocation];
        [self.activtyLocationLabel sizeToFit];
        [self.view addSubview:self.activtyLocationLabel];
        self.activityDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height/2+120, 10, 10)];
        self.activityDescriptionLabel.text = [@"Description: " stringByAppendingString:self.post.activityDescription];
        [self.activityDescriptionLabel sizeToFit];
        [self.view addSubview:self.activityDescriptionLabel];
        self.goingButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x, self.view.frame.size.height/2+150, 20, 20)];
        [self.goingButton setTitle:@"Going" forState:UIControlStateNormal];
        if(self.going){
            [self.goingButton setTitle:@"Not Going" forState:UIControlStateNormal];
            self.goingButton.backgroundColor = [UIColor blueColor];
        }
        self.goingButton.backgroundColor = [UIColor greenColor];
        [self.goingButton setCenter:CGPointMake(self.view.center.x, self.view.frame.size.height/2+150)];
        [self.goingButton sizeToFit];
        [self.goingButton addTarget:self action:@selector(didTapGoing) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:self.goingButton];
        
    }
}
- (void)didTapGoing{
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    if(!self.going){
        self.going = YES;
        NSMutableArray *imGoing = [NSMutableArray arrayWithArray:self.post.usersGoing];
        [imGoing addObject:[FIRAuth auth].currentUser.uid];
        self.post.usersGoing = [NSArray arrayWithArray:imGoing];
        [[[[ref child:@"Posts"] child:self.post.userID] child:self.post.fireBaseID] updateChildValues:@{@"UsersGoing":self.post.usersGoing}];
        [[[ref child:@"Users"] child:[FIRAuth auth].currentUser.uid] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSDictionary *myDict = snapshot.value;
            NSArray *amIGoing = myDict[@"EventsGoing"];
            NSMutableArray *youAre = [NSMutableArray arrayWithArray:amIGoing];
            [youAre addObject:self.post.fireBaseID];
            NSArray *finishedEvent = [NSArray arrayWithArray:youAre];
            [[[ref child:@"Users"] child:[FIRAuth auth].currentUser.uid] updateChildValues:@{@"EventsGoing":finishedEvent}];
        }];
        self.going=YES;
        self.goingButton.backgroundColor = [UIColor blueColor];
        [self.goingButton setTitle:@"Not Going" forState:UIControlStateNormal];
        [self.goingButton sizeToFit];
    }
    else {
        NSMutableArray *imGoing = [NSMutableArray arrayWithArray:self.post.usersGoing];
        [imGoing removeObject:[FIRAuth auth].currentUser.uid];
        self.post.usersGoing = [NSArray arrayWithArray:imGoing];
        [[[ref child:@"Posts"] child:self.post.fireBaseID] updateChildValues:@{@"UsersGoing":self.post.usersGoing}];
        [[[ref child:@"Users"] child:[FIRAuth auth].currentUser.uid] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            NSDictionary *myDict = snapshot.value;
            NSArray *myEvents = myDict[@"EventsGoing"];
            NSMutableArray *imOut = [NSMutableArray arrayWithArray:myEvents];
            [imOut removeObject:self.post.fireBaseID];
            NSArray *imDone = [NSArray arrayWithArray:imOut];
            [[[ref child:@"Users"] child:[FIRAuth auth].currentUser.uid] updateChildValues:@{@"EventsGoing":imDone}];
        }];
        self.going = NO;
        [self.goingButton setTitle:@"Going" forState:UIControlStateNormal];
        self.goingButton.backgroundColor = [UIColor greenColor];
        [self.goingButton sizeToFit];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - initting

- (instancetype)initFromTimeline:(Post *)post {
    self = [super init];
    self.post = post;
    return self;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
