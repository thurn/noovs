//
//  Post.m
//  Nooves
//
//  Created by Norette Ingabire on 7/16/18.
//  Copyright © 2018 Nikki Tran. All rights reserved.
//

#import "Post.h"

@implementation Post

+(NSString *)activityTypeToString:(ActivityType) activityType{
    switch (activityType) {
        case Outdoors:
            return @"Outdoors";
        case Shopping:
            return @"Shopping";
        case Partying:
            return @"Partying";
        case Eating:
            return @"Eating";
        case Arts:
            return @"Arts";
        case Sports:
            return @"Sports";
        case Networking:
            return @"Networking";
        case Fitness:
            return @"Fitness";
        case Games:
            return @"Games";
        case Concert:
            return @"Concert";
        case Cinema:
            return @"Cinema";
        case Festival:
            return @"Festival";
        default:
            return @"Other";
    }
};
+(ActivityType)stringToActivityType:(NSString *)activityString{
    if([activityString isEqualToString:@"Outdoors"]){
        return Outdoors;
    }
    else if([activityString isEqualToString:@"Shopping"]){
        return Shopping;
    }
    else if([activityString isEqualToString:@"Partying"]){
        return Partying;
    }
    else if([activityString isEqualToString:@"Eating"]){
        return Eating;
    }
    else if([activityString isEqualToString:@"Arts"]){
        return Arts;
    }
    else if([activityString isEqualToString:@"Sports"]){
        return Sports;
    }
    else if([activityString isEqualToString:@"Networking"]){
        return Networking;
    }
    else if([activityString isEqualToString:@"Fitness"]){
        return Fitness;
    }
    else if([activityString isEqualToString:@"Games"]){
        return Games;
    }
    else if([activityString isEqualToString:@"Concert"]){
        return Concert;
    }
    else if([activityString isEqualToString:@"Cinema"]){
        return Cinema;
    }
    else if([activityString isEqualToString:@"Festival"]){
        return Festival;
    }
    return Other;
}
-(NSNumber *)ActivityTypeToNumber{
    NSNumber *activity = @(self.activityType);
    return activity;
}
-(int)getDateTimeStamp{
    int timestamp = [self.activityDateAndTime timeIntervalSince1970];
    return timestamp;
}
-(instancetype)MakePost:(NSDate *)eventDate withTitle:(NSString *) postTitle withDescription:(NSString *) postDescription withType:(ActivityType ) activityType {
    Post *post = [[Post alloc]init];
    post.activityDateAndTime = eventDate;
    post.activityTitle = postTitle;
    post.activityDescription = postDescription;
    post.activityType = activityType;
    return post;
}
-(instancetype)initFromFireBasePost:(FirebasePost *)firePost{
    Post *post = [[Post alloc]init];
    int date = [firePost.eventDateAndTime intValue];
    NSDate *eventDate = [NSDate dateWithTimeIntervalSince1970:date];
    post.activityDateAndTime = eventDate;
    post.activityTitle = firePost.postTitle;
    post.activityDescription = firePost.postDescription;
    NSInteger eventType = [firePost.activityType integerValue];
    post.activityType = eventType;
    return post;
}
@end

