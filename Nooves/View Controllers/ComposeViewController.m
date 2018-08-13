#import "ComposeViewController.h"
#import "AppDelegate.h"
#import "TimelineViewController.h"
#import "ProfileViewController.h"
#import "TabBarController.h"

#import "CategoryPickerModalViewController.h"
#import "DatePickerModalViewController.h"
#import "LocationPickerModalViewController.h"
#import "EventsViewController.h"

#import <ChameleonFramework/Chameleon.h>
#import <FirebaseAuth.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "PureLayout/PureLayout.h"

@interface ComposeViewController () <UITextViewDelegate, UITextFieldDelegate,LocationPickerDelegate,
CategoryPickerDelegate, DatePickerDelegate, EventsSearchDelegate>

@property (nonatomic) Post *post;
@property (nonatomic) NSDate *date;
@property (nonatomic) ActivityType activityType;
@property (nonatomic) NSNumber *lat;
@property (nonatomic) NSNumber *lng;
@property (nonatomic) NSString *location;
@property (nonatomic) UIPickerView *pickerView;
@property (nonatomic) UITextField *eventTitle;
@property (nonatomic) UITextField *timeTextField;
@property (nonatomic) UITextField *locationTextField;
@property (nonatomic) UITextField *categoryTextField;
@property (nonatomic) UITextView *eventDescription;
@property (nonatomic) BOOL uploading;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.uploading = NO;
    
    self.lat = [[NSNumber alloc] init];
    self.lng = [[NSNumber alloc] init];
    self.location = [[NSString alloc] init];
    
    [self configureView];

    [self becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    self.locationTextField.text = self.location;
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"MMM dd hh:mm a";
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *dateDetails = [formatter stringFromDate:self.date];
    self.timeTextField.text = dateDetails;
    
    self.eventDescription.textColor = UIColor.grayColor;
}

- (void)configureView {
    self.view.backgroundColor = [UIColor flatWhiteColor];
    self.navigationItem.title = @"New Event";
    
    self.eventTitle = [[UITextField alloc] initWithFrame:CGRectMake(36, 5, 335, 30)];
    self.eventTitle.text = nil;
    self.eventTitle.placeholder = @"Event name";
    self.eventTitle.borderStyle = UITextBorderStyleNone;
    self.eventTitle.textColor = UIColor.blackColor;
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 37, self.view.bounds.size.width, 1)];
    line1.backgroundColor = [UIColor flatBlackColor];
    [self.view addSubview:line1];
    
    // time text view
    self.timeTextField = [[UITextField alloc] initWithFrame:CGRectMake(36, 40, 335, 30)];
    self.timeTextField.text = nil;
    self.timeTextField.placeholder = @"Time";
    self.timeTextField.borderStyle = UITextBorderStyleNone;
    self.timeTextField.textColor = UIColor.blackColor;
    self.timeTextField.enabled = NO;
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, 70, self.view.bounds.size.width, 1)];
    line2.backgroundColor = [UIColor flatBlackColor];
    [self.view addSubview:line2];
    
    // location text view
    self.locationTextField = [[UITextField alloc] initWithFrame:CGRectMake(36, 75, 335, 30)];
    self.locationTextField.text = nil;
    self.locationTextField.placeholder = @"Location";
    self.locationTextField.borderStyle = UITextBorderStyleNone;
    self.locationTextField.textColor = UIColor.blackColor;
    
    UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(0, 105, self.view.bounds.size.width, 1)];
    line3.backgroundColor = [UIColor flatBlackColor];
    [self.view addSubview:line3];
    
    // category text view
    self.categoryTextField = [[UITextField alloc] initWithFrame:CGRectMake(36, 107, 335, 30)];
    self.categoryTextField.text = nil;
    self.categoryTextField.placeholder = @"Category";
    self.categoryTextField.borderStyle = UITextBorderStyleNone;
    self.categoryTextField.textColor = UIColor.blackColor;
    self.categoryTextField.enabled = NO;
    
    UIView *line4 = [[UIView alloc] initWithFrame:CGRectMake(0, 138, self.view.bounds.size.width, 1)];
    line4.backgroundColor = [UIColor flatBlackColor];
    [self.view addSubview:line4];
    
    // event text view
    self.eventDescription = [[UITextView alloc] initWithFrame:CGRectMake(0, 142, self.view.bounds.size.width, 150)];
    [self.eventDescription setFont:[UIFont fontWithName:@"ProximaNovaT-Thin" size:16]];
    self.eventDescription.delegate = self;
    self.eventDescription.text = @"Add a description";
    self.eventDescription.textColor = UIColor.grayColor;
    self.eventDescription.backgroundColor = UIColor.flatWhiteColor;
    
    [self.view addSubview:self.eventTitle];
    [self.view addSubview:self.timeTextField];
    [self.view addSubview:self.locationTextField];
    [self.view addSubview:self.categoryTextField];
    [self.view addSubview:self.eventDescription];
    [self.view addSubview:[self createDateButton]];
    [self.view addSubview:[self createCategoryButton]];
    [self.view addSubview:[self createLocationButton]];
    [self.view addSubview:[self createEventsButton]];
    
    [self createPostButton];
    [self createBackButton];
}

#pragma mark - buttons and respective actions
// set up button to select local events
-(UIButton *)createEventsButton {
    UIButton *eventsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    eventsButton.frame = CGRectMake(5, 8, 100, 100);
    [eventsButton setTintColor:[UIColor flatSkyBlueColor]];
    [eventsButton setImage:[UIImage imageNamed:@"calendar"] forState:UIControlStateNormal];
    [eventsButton addTarget:self
                     action:@selector(didTapEvents)
           forControlEvents:UIControlEventTouchUpInside];
    [eventsButton sizeToFit];
    return eventsButton;
}

- (void)didTapEvents {
    EventsViewController *chooseEvent = [[EventsViewController alloc]init];
    chooseEvent.eventsDelegate= self;
    UINavigationController *navCont = [[UINavigationController alloc]
                                       initWithRootViewController:chooseEvent];
    [self.navigationController presentViewController:navCont animated:YES completion:nil];
}

// sets up select date button properties
- (UIButton *)createDateButton {
    UIButton *selectDate = [UIButton buttonWithType:UIButtonTypeSystem];
    selectDate.frame = CGRectMake(5, 42, 100, 100);
    [selectDate setTintColor:[UIColor flatSkyBlueColor]];
    [selectDate setImage:[UIImage imageNamed:@"clock"] forState:UIControlStateNormal];
    [selectDate addTarget:self
                   action:@selector(didSelectDate)
         forControlEvents:UIControlEventTouchUpInside];
    [selectDate sizeToFit];
    return selectDate;
}

// conforms to date picker delegate and jumps to date picker view
- (void)didSelectDate {
    DatePickerModalViewController *datePicker = [DatePickerModalViewController new];
    datePicker.dateDelegate = self;
    UINavigationController *navCont = [[UINavigationController alloc]
                                       initWithRootViewController:datePicker];
    [self presentViewController:navCont animated:YES completion:nil];
}

// sets up select location properties
- (UIButton *)createLocationButton {
    UIButton *selectLocation = [UIButton buttonWithType:UIButtonTypeSystem];
    selectLocation.frame = CGRectMake(5, 76, 100, 100);
    [selectLocation setTintColor:[UIColor flatSkyBlueColor]];
    [selectLocation setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    [selectLocation addTarget:self
                       action:@selector(didSelectLocation)
             forControlEvents:UIControlEventTouchUpInside];
    [selectLocation sizeToFit];
    return selectLocation;
}

// conforms to location picker delegate and jumps to location picker view
- (void)didSelectLocation {
    LocationPickerModalViewController *locationPicker = [LocationPickerModalViewController new];
    locationPicker.locationDelegate = self;
    UINavigationController *navCont = [[UINavigationController alloc]
                                       initWithRootViewController:locationPicker];
    [self presentViewController:navCont animated:YES completion:nil];
}

// sets up selection category button properties
- (UIButton *)createCategoryButton {
    UIButton *selectCategory = [UIButton buttonWithType:UIButtonTypeSystem];
    selectCategory.frame = CGRectMake(7, 110, 100, 100);
    [selectCategory setTintColor:[UIColor flatSkyBlueColor]];
    [selectCategory setImage:[UIImage imageNamed:@"tag"] forState:UIControlStateNormal];
    [selectCategory addTarget:self
                       action:@selector(didSelectCategory)
             forControlEvents:UIControlEventTouchUpInside];
    [selectCategory sizeToFit];
    return selectCategory;
}

// conforms to category picker delegate and jumps to category picker view
- (void)didSelectCategory {
    CategoryPickerModalViewController *categoryPicker = [CategoryPickerModalViewController new];
    categoryPicker.categoryDelegate = self;
    UINavigationController *navCont = [[UINavigationController alloc]
                                       initWithRootViewController:categoryPicker];
    [self presentViewController:navCont animated:YES completion:nil];
}

// sets up back button properties
- (UIBarButtonItem *)createBackButton {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithImage:[UIImage imageNamed:@"back-icon"]
                                           style:UIBarButtonItemStylePlain
                                          target:self
                                          action:@selector(didTapBackButton)];
    [backButton setTintColor:[UIColor flatWhiteColor]];
    self.navigationItem.leftBarButtonItem = backButton;

  return backButton;
}

// jumps back to root view controller
- (void)didTapBackButton {
    [self dismissViewControllerAnimated:true completion:nil];
}

// sets up post button properties
- (UIBarButtonItem *)createPostButton {
    UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithTitle:@"Share"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(didTapPost)];
    [postButton setTintColor:[UIColor flatWhiteColor]];
    self.navigationItem.rightBarButtonItem = postButton;
    return postButton;
}

// passes post data to post array and jumps back to timeline view
- (void)didTapPost {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.post == nil && !self.uploading) {
        self.post = [[Post alloc] initPostWithDetails:self.date
                                            withTitle:self.eventTitle.text
                                      withDescription:self.eventDescription.text
                                             withType:self.activityType
                                              withLat:self.lat
                                              withLng:self.lng
                                               withID:nil
                                         withLocation:self.location];
        self.uploading = YES;
        [Post postToFireBase:self.post];
        FIRDatabaseReference *reference = [[FIRDatabase database] reference];
        FIRDatabaseHandle *databaseHandle = [[[reference child:@"Users"]child:self.post.userID] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (![snapshot.value isEqual:[NSNull null]]) {
            }
            else {
                FIRDatabaseReference *userRef = [[reference child:@"Users"]child:self.post.userID];
                [userRef setValue:@{@"Age":@(0), @"Bio":@"nil", @"Name":[FIRAuth auth].currentUser.displayName,@"PhoneNumber":@(0), @"ProfilePicURL":@"nil",@"EventsGoing":@[@"a"]}];
            }
        }];
        self.uploading = NO;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self dismissViewControllerAnimated:true completion:nil];
        NSLog(@"User posted successfully");
    } else {
        NSLog(@"Nothing to post");
    }
}

// dismisses keyboard through gesture tap
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.eventTitle endEditing:YES];
    [self.locationTextField endEditing:YES];
    [self.eventDescription endEditing:YES];
}

#pragma mark - Location Picker Delegate method
- (void)locationsPickerModalViewController:(LocationPickerModalViewController *)controller
               didPickLocationWithLatitude:(NSNumber *)latitude
                                 longitude:(NSNumber *)longitude
                                  location:(NSString *)location {
    self.location = location;
    self.lat = latitude;
    self.lng = longitude;
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - Category Picker Delegate method
- (void)categoryPickerModalViewController:(CategoryPickerModalViewController *)controller
                      didPickActivityType:(ActivityType *)activity {
    self.activityType = activity;
    NSString *activityHa = [Post activityTypeToString:self.activityType];
    self.categoryTextField.text = activityHa;
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - Date Picker Delegate Method
- (void)datePickerModalViewController:(DatePickerModalViewController *)dateController
                          didPickDate:(NSDate *)date {
    self.date = date;
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - EventsViewDelegate
- (void)eventsViewController:(EventsViewController *)controller didSelectEventWithTitle:(NSString *)title
             withDescription:(NSString *)description
                   withVenue:(NSString *)venue
                    withTime:(NSString *)time {
    self.eventTitle.text = title;
    if([description isKindOfClass:[NSString class]]) {
        self.eventDescription.text = description;
    }
    
    else {
        self.eventDescription.text = @"";
    }
    self.location = venue;
    
    // format date string to date format
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd hh:mm a"];
    NSDate *dateString = [formatter dateFromString:time];
    self.date = dateString;
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - Text View delegate methods
// changes text color when user edits text view
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.textColor == UIColor.grayColor) {
        textView.text = nil;
        textView.textColor = UIColor.blackColor;
    }
}

// changes text color when user stops editing text view
- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text == nil) {
        textView.text = @"Add a description";
        textView.textColor = UIColor.grayColor;
    }
}

#pragma mark - Text Field delegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.textColor == UIColor.grayColor) {
        textField.text = nil;
        textField.textColor = UIColor.blackColor;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text == nil) {
        textField.textColor = UIColor.grayColor;
    }
}

@end
