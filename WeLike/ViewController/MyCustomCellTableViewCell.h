//
//  MyCustomCellTableViewCell.h
//  Fitovate
//
//  Created by Benjamin Harvey on 1/15/16.
//
//

#import <UIKit/UIKit.h>

@interface MyCustomCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *trainerName;

@end
