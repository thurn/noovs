//
//  postCell.h
//  Nooves
//
//  Created by Norette Ingabire on 7/16/18.
//  Copyright © 2018 Nikki Tran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

static NSString *const postcellIdentifier = @"cellwithPost";

@interface postCell : UITableViewCell

@property (strong, nonatomic) Post *post;

@property (strong, nonatomic) UILabel *postField;
@property (strong, nonatomic) UILabel *dateField;
@property (strong, nonatomic) UIButton *goingButton;
@property (strong, nonatomic) UIButton *interestedButton;
@property (strong, nonatomic) UIButton *profileButton;
@property (strong, nonatomic) UILabel *testLabel;

- (void) setPost: (Post *) post;

- (UIButton *) goToProfile;

@end
