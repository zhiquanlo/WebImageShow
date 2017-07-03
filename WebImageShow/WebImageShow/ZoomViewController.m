//
//  ZoomViewController.m
//  WebImageShow
//
//  Created by 李志权 on 15/7/23.
//  Copyright (c) 2015年 BW. All rights reserved.
//

#import "ZoomViewController.h"

@interface ZoomViewController ()
{
    int _index;//当前图片索引
    int flag;//图片不在当前页面还原
    CGFloat Width;
    CGFloat Height;
    NSMutableArray *_imaArray;//图片数组
}
@end

@implementation ZoomViewController
- (id)initWithUIImageView:(NSMutableArray *)wbeImage index:(NSInteger)index
{
    self = [super init];
    self.navigationItem.title = [NSString stringWithFormat:@"%@%d/%d",@"病历图片",(int)index+1,(int)wbeImage.count];
    UIButton *leftBUT = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBUT setBackgroundImage:[UIImage imageNamed:@"button_back_bg"] forState:UIControlStateNormal];
    [leftBUT setBackgroundImage:[UIImage imageNamed:@"button_back_bg_highlight"] forState:UIControlStateNormal];
    [leftBUT addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    leftBUT.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc]initWithCustomView:leftBUT];
    [self.navigationItem setLeftBarButtonItem:leftBar animated:YES];
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc]initWithTitle:@"保存图片" style:UIBarButtonItemStylePlain target:self action:@selector(saveThepPicture)];
    rightBar.tintColor = [UIColor whiteColor];
    [self.navigationItem setRightBarButtonItem:rightBar animated:YES];
    //    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //保存数据
    _index = (int)index;
    _imaArray = wbeImage;
     Height = self.view.frame.size.height;
    Width = self.view.frame.size.width;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,0, Width+20, Height)];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    
    for (int a = 0; a<_imaArray.count; a++)
    {
        UIScrollView *scroll = [self ImageName:_imaArray[a] viewTag:700+a];
        scroll.frame = CGRectMake((Width+20)*a, 0, Width, Height-64);
        [self.scrollView addSubview:scroll];
    }
    
    self.scrollView.contentSize = CGSizeMake(_imaArray.count*(Width+20), Height-64);
    self.scrollView.contentOffset = CGPointMake((Width+20)*_index, 0);
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 参数图片名字
 viewTag值
 */
- (UIScrollView *)ImageName:(NSString *)iamg viewTag:(NSInteger)tag
{
    UIScrollView *scroll = [[UIScrollView alloc]init];
    scroll.maximumZoomScale  = 2.0;
    scroll.minimumZoomScale  = 0.5;
    scroll.delegate = self;
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Width, Height-64)];
    [scroll addSubview:img];
    img.contentMode = UIViewContentModeScaleAspectFit;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *url = @"http://59.188.86.204:8000/upload/d6566c58-d64f-4060-b990-afbb9a11c78d.jpg";
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        UIImage *image = [UIImage imageWithData:data];
        
        //主线程执行
        dispatch_async(dispatch_get_main_queue(), ^{
            img.image = image;
        });
    });
    //双击放大
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(finger_double:)];
    tap2.numberOfTapsRequired = 2;
    [scroll addGestureRecognizer:tap2];
    
    //加上手势点击退出控制器
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self.navigationController action:@selector(popViewControllerAnimated:)];
    [scroll addGestureRecognizer:tap];
    
    [tap requireGestureRecognizerToFail:tap2];
    return scroll;
    
    
}
//双击放到最大
- (void)finger_double:(UITapGestureRecognizer *)tap
{
    UIScrollView *scroll = (UIScrollView *)tap.view;
    UIImageView *tempImage = [[scroll subviews] objectAtIndex:0];
    if (scroll.zoomScale == 1.0) {
        scroll.zoomScale = 2.0;
        tempImage.contentMode = UIViewContentModeScaleToFill;
    }
    else
    {
        scroll.zoomScale = 1.0;
        tempImage.contentMode = UIViewContentModeScaleAspectFit;
    }
}
//保存图片
- (void)saveThepPicture
{
    UIScrollView *smallScrollView = [self.scrollView.subviews objectAtIndex:_index];
    UIImageView *tempImage = [[smallScrollView subviews] objectAtIndex:0];
    //将该图像保存到媒体库中
    UIImageWriteToSavedPhotosAlbum(tempImage.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error)
    {
        UIAlertView *aler = [[UIAlertView alloc]initWithTitle:@"提示" message:@"图片保存成功" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [aler show];
    }
    else
    {
        UIAlertView *aler = [[UIAlertView alloc]initWithTitle:@"提示" message:@"图片失败" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [aler show];
    }
    
    
}
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        NSInteger currentPage = self.scrollView.contentOffset.x / self.view.frame.size.width;
        self.navigationItem.title = [NSString stringWithFormat:@"%d/%d",currentPage+1,_imaArray.count];
        _index = currentPage;
        if (currentPage != flag) {
            UIScrollView *smallScrollView = [self.scrollView.subviews objectAtIndex:flag];
            smallScrollView.zoomScale = 1.0;
            flag = currentPage;
            UIImageView *tempImage = [[smallScrollView subviews] objectAtIndex:0];
            tempImage.contentMode = UIViewContentModeScaleAspectFit;
            
        }
        
    }
    
}
//滚动视图放大缩小相关的回调
//返回放大缩小的视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (scrollView != self.scrollView)
    {
        UIView *subView = [[scrollView subviews] objectAtIndex:0];
        return subView;
    }
    
    return nil;
}

//视图正在缩放中
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (scrollView != self.scrollView)
    {
        //获取当前的缩放图片
        UIImageView *tempImage = [[scrollView subviews] objectAtIndex:0];
        
        //重置位置
        CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
        (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
        CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
        (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
        tempImage.center = CGPointMake((int)(scrollView.contentSize.width * 0.5 + offsetX),
                                       (int)(scrollView.contentSize.height * 0.5 + offsetY));
    }
}

//视图开始缩放
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    self.scrollView.scrollEnabled = NO;//缩放时禁止外层大scrollview的滚动
    UIImageView *tempImage = [[scrollView subviews] objectAtIndex:0];
    tempImage.contentMode = UIViewContentModeScaleToFill;
}

//视图结束缩放
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    self.scrollView.scrollEnabled = YES;//缩放结束时打开外层大scrollview的滚动;
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
