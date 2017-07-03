//
//  ShowViewController.m
//  WebImageShow
//


#import "ShowViewController.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "ZoomViewController.h"
#import "TFHpple.h"
@interface ShowViewController ()<UIGestureRecognizerDelegate>
{
    NSInteger _index;
}
@property (nonatomic,retain) UIWebView *showWebView;

@end

@implementation ShowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"点击查看网页中图片";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _showWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://wap.hao123.com"]];
    [_showWebView loadRequest:urlRequest];
    [self.view addSubview:_showWebView];
    
    [self addTapOnWebView];
 }

-(void)addTapOnWebView
{
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.showWebView addGestureRecognizer:singleTap];
    singleTap.delegate = self;
    singleTap.cancelsTouchesInView = NO;
}

#pragma mark- TapGestureRecognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    //获取UIWebView上源代码
    NSString *innerHtml = @"document.documentElement.innerHTML";
    NSString *html = [self.showWebView stringByEvaluatingJavaScriptFromString:innerHtml];
    //获取源代码上面的图片Url
    NSData *htmlData = [html dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//img"];
    NSMutableArray *imaUrl = [NSMutableArray array];
    for (TFHppleElement *element in elements) {
        NSRange range  = [[element.attributes objectForKey:@"src"] rangeOfString:@"logo"];//过滤掉头像图片
        if ([element.attributes objectForKey:@"src"] && range.location == NSNotFound)
        {
            NSString *url = [NSString stringWithFormat:@"%@%@",@"https://m.wukonglicai.com",[element.attributes objectForKey:@"src"]];
            [imaUrl addObject:url];
        }
        
    }
    //获取当前点击的多图
    CGPoint pt = [sender locationInView:self.showWebView];
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", pt.x, pt.y];
    NSString *urlToSave = [self.showWebView stringByEvaluatingJavaScriptFromString:imgURL];
    
    _index = [imaUrl indexOfObject:urlToSave];
    
    if (urlToSave.length > 0 && _index != NSNotFound) {
        [self showImageTable:imaUrl];
    }
}

//呈现图片
- (void)showImageTable:(NSMutableArray *)ima
{
    [self.navigationController pushViewController:[[ZoomViewController alloc]initWithUIImageView:ima index:_index] animated:YES];
}


//移除图片查看视图
//-(void)handleSingleViewTap:(UITapGestureRecognizer *)sender
//{    
//    for (id obj in self.view.subviews) {
//        if ([obj isKindOfClass:[UIImageView class]]) {
//            [obj removeFromSuperview];
//        }
//    }
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
