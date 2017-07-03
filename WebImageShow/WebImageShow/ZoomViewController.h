//
//  ZoomViewController.h
//  WebImageShow
//
//  Created by 李志权 on 15/7/23.
//  Copyright (c) 2015年 BW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomViewController : UIViewController<UIScrollViewDelegate>
@property (nonatomic,strong)UIImageView *wbeImage;
@property (nonatomic,strong)UIScrollView *scrollView;
-(id)initWithUIImageView:(NSMutableArray *)wbeImage index:(NSInteger)index;
@end
