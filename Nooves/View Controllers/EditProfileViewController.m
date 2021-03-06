#import <ChameleonFramework/Chameleon.h>
#import "EditProfileViewController.h"
#import "ProfileViewController.h"
#import <FIRStorage.h>
#import <Masonry.h>
#import "User.h"
#import "UIImageView+Cache.h"

@interface EditProfileViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDropItem>

@property(strong, nonatomic) UIImageView *profilePic;
@property(strong, nonatomic) UITextField *userName;
@property(strong, nonatomic) UITextView *bioInfo;
@property(strong, nonatomic) UITextField *age;
@property(strong, nonatomic) UITextField *userPhoneNumber;
@property(strong, nonatomic) UIBarButtonItem *saveProfile;
@property(strong, nonatomic) User *user;
@property(nonatomic) BOOL picEdited;

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    FIRDatabaseReference *reference = [[FIRDatabase database]reference];
    FIRDatabaseHandle *databaseHandle = [[[reference child:@"Users"]child:[FIRAuth auth].currentUser.uid]observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *usersDictionary= snapshot.value;
        if (![snapshot.value isEqual:[NSNull null]]) {
            self.user = [[User alloc] initFromDatabase:usersDictionary];
            self.age.text = [self.user.age stringValue];
            self.bioInfo.text = self.user.biography;
            self.userName.text = self.user.name;
            self.userPhoneNumber.text = [self.user.phoneNumber stringValue];
            if (![self.user.profilePicURL isEqualToString:@"nil"]){
                [self.profilePic loadURLandCache:self.user.profilePicURL];
            }
        }
        else {
            FIRDatabaseReference *userRef = [[reference child:@"Users"]child:[FIRAuth auth].currentUser.uid];
            [userRef setValue:@{@"Age":@(0), @"Bio":@"nil", @"Name":[FIRAuth auth].currentUser.displayName,@"PhoneNumber":@(0), @"ProfilePicURL":@"nil",@"EventsGoing":@[@"a"]}];
        }
    }];
    // Do any additional setup after loading the view.
    self.picEdited = NO;
    self.view.backgroundColor = [UIColor flatWhiteColor];
    [self configureView];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Edit Profile";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)selectProfilePic {
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"cancelled");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    if(info[@"UIImagePickerControllerEditedImage"]){
        UIImage *profilePic = info[@"UIImagePickerControllerEditedImage"];
        self.profilePic.image = profilePic;
        self.picEdited = YES;
        NSData *picRef = UIImagePNGRepresentation(profilePic);
        FIRStorageReference *ref = [[[FIRStorage storage] reference] child:[FIRAuth auth].currentUser.uid];
        [ref putData:picRef metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
            if(error){
                NSLog(@"%@", error);
            }
            else{
                NSLog(@"%@", metadata);
                [ref downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
                    if (error){
                        NSLog(@"%@", error);
                    }
                    else {
                        if(!self.user){
                            self.user = [[User alloc] init];
                        }
                        self.user.profilePicURL = [URL absoluteString];
                    }
                }];
            }
        }];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)configureView {
    
    UIView *profileView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 150)];
    [profileView setBackgroundColor:UIColor.whiteColor];
   // profileView.layer.cornerRadius = 5;
    profileView.layer.borderWidth = 0.5;
    profileView.layer.borderColor = UIColor.flatBlackColor.CGColor;
    [self.view addSubview:profileView];
    
    //set up the profile pic field
    self.profilePic = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.bounds.size.width/2)-62.5, 10, 125, 125)];
   self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width/2;
    self.profilePic.clipsToBounds = YES;
    self.profilePic.contentMode = UIViewContentModeScaleAspectFill;
    self.profilePic.layer.borderWidth = 2;
    self.profilePic.layer.borderColor = UIColor.flatPinkColor.CGColor;
    [self.profilePic setImage:[UIImage imageNamed:@"profile-blank"]];
    UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] init];
    [tapped addTarget:self action:@selector(selectProfilePic)];
    [self.profilePic addGestureRecognizer:tapped];
    self.profilePic.userInteractionEnabled = YES;
    [profileView addSubview:self.profilePic];
    
    UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 180, self.view.bounds.size.width, 200)];
    [infoView setBackgroundColor:UIColor.whiteColor];
   // infoView.layer.cornerRadius = 5;
    infoView.layer.borderWidth = 0.5;
    infoView.layer.borderColor = UIColor.flatBlackColor.CGColor;
    [self.view addSubview:infoView];
    
    // set up the name field
    self.userName = [[UITextField alloc]initWithFrame:CGRectMake(10, 10, infoView.bounds.size.width, 20)];
    NSString *nameString = @"Name      ";
    self.userName.placeholder = @"Enter full name";
    self.userName.textColor = [UIColor grayColor];
    [infoView addSubview:self.userName];
    
    UIView *firstLine = [[UIView alloc]initWithFrame:CGRectMake(0, 35, infoView.bounds.size.width, 0.3)];
    [firstLine setBackgroundColor:UIColor.flatBlackColorDark];
    [infoView addSubview:firstLine];
    
    //set up the age field
    self.age = [[UITextField alloc]initWithFrame:CGRectMake(10, 40,infoView.bounds.size.width, 20)];
    self.age.placeholder = @"Enter age";
    self.age.textColor = [UIColor grayColor];
    
    UIView *secondLine = [[UIView alloc]initWithFrame:CGRectMake(0, 60, infoView.bounds.size.width, 0.3)];
    [secondLine setBackgroundColor:UIColor.flatBlackColorDark];
    [infoView addSubview:secondLine];
    
    // set up the phone number field
    self.userPhoneNumber = [[UITextField alloc]initWithFrame:CGRectMake(10, 70, infoView.bounds.size.width, 20)];
    self.userPhoneNumber.placeholder = @"Enter phone number";
    self.userPhoneNumber.textColor = [UIColor grayColor];
    
    UIView *thirdLine = [[UIView alloc]initWithFrame:CGRectMake(0, 90, infoView.bounds.size.width, 0.3)];
    [thirdLine setBackgroundColor:UIColor.flatBlackColorDark];
    [infoView addSubview:thirdLine];
    
    // set up the bio field
    self.bioInfo = [[UITextView alloc]initWithFrame:CGRectMake(10, 100, self.view.bounds.size.width, 50)];
    self.bioInfo.delegate = self;
    self.bioInfo.text = @"Enter bio here";
    self.bioInfo.textColor = [UIColor grayColor];
    
    // set up the save profile button
    self.saveProfile = [[UIBarButtonItem alloc]init];
    self.saveProfile.title = @"Done";
    self.navigationItem.rightBarButtonItem = self.saveProfile;    
    self.saveProfile.target = self;
    self.saveProfile.action = @selector(didTapSaveProfile);
    
    // add all the subviews to the view
   // [infoView addSubview:self.userName];
    [infoView addSubview:self.age];
    [infoView addSubview:self.userPhoneNumber];
    [infoView addSubview:self.bioInfo];
}

// change the text color if the user is editing their bio
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.textColor == UIColor.grayColor) {
        textView.text = nil;
        textView.textColor = UIColor.blackColor;
    }
    [textView becomeFirstResponder];
}

// change the color back to gray if the user is done editing
- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text == nil) {
        textView.text = @"Enter bio here";
        textView.textColor = UIColor.grayColor;
    }
    [textView resignFirstResponder];
}

- (void)didTapSaveProfile {
    // convert 'age' and 'phone number' to NSNumber
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *ageNumber = [formatter numberFromString:self.age.text];
    NSNumber *phoneNum = [formatter numberFromString:self.userPhoneNumber.text];
    
    // save all the info to the profile page
    if (!self.user){
        self.user = [[User alloc] init];
    }
    [self.user addToProfileWithInfo:self.userName.text withBio:self.bioInfo.text withAge:ageNumber withNumber:phoneNum];
    [self.navigationController popViewControllerAnimated:YES];
    [User saveUserProfile:self.user];
}


@end
