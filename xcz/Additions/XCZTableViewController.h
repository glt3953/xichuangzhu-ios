//
//  XCZTableViewController.h
//  xcz
//
//  Created by hustlzp on 15/10/21.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XCZTableViewController : UIViewController

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

@end
