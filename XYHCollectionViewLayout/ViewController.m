//
//  ViewController.m
//  XYHCollectionViewLayout
//
//  Created by Administrator on 16/8/6.
//  Copyright © 2016年 XuYouhong. All rights reserved.
//

#import "ViewController.h"

#import "XYHHomeLayout.h"
#import "XYHBigCollectionViewCell.h"
#import "XYHSmallCollectionViewCell.h"

#define SCR_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCR_HEIGHT [UIScreen mainScreen].bounds.size.height
#define getCellWidth (SCR_WIDTH - 72)/3.0
#define getCellHeight(width) 300.0 * width / 200.0
#define getBigCellHeight(width) (870 / 570.0 * width)


static NSString *const ID = @"smallCell";
static NSString *const ID_BIG = @"bigCell";

@interface ViewController ()
<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic,retain)UICollectionView* mainCollectView;
@property (nonatomic, strong)UILabel *indexLabel;//记录当前的索引
@property (nonatomic, strong)UIButton *selectedButton;//编辑按钮
@property (nonatomic, strong)UICollectionViewFlowLayout* baseLayout;
/**当前的索引*/
@property (nonatomic, strong)NSIndexPath *currentIndexPath;
/**dataArray*/
@property (nonatomic, strong) NSMutableArray <NSDictionary *>*dataArray;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.opaque = YES;
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self createNavBar];
    [self.view addSubview:self.mainCollectView];
    if(SCR_HEIGHT > 480){
        [self.view addSubview:self.indexLabel];
    }
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"data" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    [self.dataArray addObjectsFromArray:dic[@"results"]];
    [self.mainCollectView reloadData];
}

#pragma mark --init
- (void)createNavBar{
    self.title = @"区域馆";
    UIButton *button = [UIButton buttonWithType:0];
    [button setTitle:@"切换" forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 50, 30);
    self.selectedButton = button;
    [button addTarget:self action:@selector(turnMode:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
}

#pragma mark --UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dic = [NSDictionary dictionary];
    if (self.dataArray.count > 0 && indexPath.item < self.dataArray.count) {
        dic = self.dataArray[indexPath.item];
    }
    
    if ([collectionView.collectionViewLayout isKindOfClass:[XYHHomeLayout class]])
    {
        XYHBigCollectionViewCell *bigCell = [collectionView dequeueReusableCellWithReuseIdentifier:ID_BIG forIndexPath:indexPath];
        [bigCell updateBigCell:dic];
        return bigCell;
    }else
    {
        XYHSmallCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
        [cell updateSmallCell:dic];
        return cell;
    }
}

/**
 *进入区域馆
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
}


/**
 *显示索引
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if([self.mainCollectView.collectionViewLayout isKindOfClass:[XYHHomeLayout class]]){
        [self showIndexLabelWithOffset:scrollView.contentOffset.x];
    }
}


#pragma mark --event Response
- (void)turnMode:(UIButton *)sender{
    
    __weak typeof(ViewController *) weakSelf = self;
    __weak typeof(UICollectionView*) weakMain = _mainCollectView;
    
    //完成一次动画后  才能进行下一次切换
    sender.enabled = NO;
    //控制按钮的旋转
    [UIView animateWithDuration:0.2 animations:^{
        if (!sender.selected) {
            sender.transform = CGAffineTransformMakeRotation(M_PI_2);
        }else{
            sender.transform = CGAffineTransformMakeRotation(0);
        }
    }];
    
    sender.selected = !sender.selected;
    self.mainCollectView.bounces = !sender.selected;
    //collection的翻转
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.mainCollectView cache:NO];
    [UIView commitAnimations];
    //保存当前的索引
    [self getCurrentIndexPath];
    
    
    
    if ([self.mainCollectView.collectionViewLayout isKindOfClass:[XYHHomeLayout class]]) {
        
        self.mainCollectView.pagingEnabled = NO;
        [self.mainCollectView setCollectionViewLayout:self.baseLayout animated:NO completion:^(BOOL over){
            if(over){
                [weakMain reloadData];
                weakSelf.indexLabel.hidden = !sender.selected;
            }
        }];
        
    }else{
        weakSelf.indexLabel.hidden = !sender.selected;
        
        [self.mainCollectView setCollectionViewLayout:[XYHHomeLayout new] animated:NO completion:^(BOOL over){
            if(over){
                
                [weakMain reloadData];
            }
        }];
    }
    
    double delayInSeconds = .25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        if ([weakSelf.mainCollectView.collectionViewLayout isKindOfClass:[XYHHomeLayout class]]) {
            [weakSelf.mainCollectView scrollToItemAtIndexPath:self.currentIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        }else{
            [weakSelf.mainCollectView scrollToItemAtIndexPath:self.currentIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
        }
        
        [weakSelf showIndexLabelWithOffset:self.mainCollectView.contentOffset.x];
    });
    double delayInSecond = .5;
    dispatch_time_t refreshTime = dispatch_time(DISPATCH_TIME_NOW, delayInSecond * NSEC_PER_SEC);
    dispatch_after(refreshTime, dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
}


#pragma mark --private Method
-(NSIndexPath *)getCurrentIndexPath;
{
    int currentRow = 0;
    float offset = 0.f;
    if (![self.mainCollectView.collectionViewLayout isKindOfClass:[XYHHomeLayout class]]) {
        offset = self.mainCollectView.contentOffset.y;
        //第一行
        float scanle = (offset)/(getCellHeight(getCellWidth)+18);
        if (scanle > 1.0) {
            scanle = ceilf(scanle);
            currentRow = scanle * 3 - 3;
        }else{
            scanle = 0;
            currentRow = 0;
        }
    }else{
        offset = self.mainCollectView.contentOffset.x;
        float itemWidth = SCR_WIDTH - 134 + 38;
        currentRow = offset / itemWidth;
    }
    self.currentIndexPath = [NSIndexPath indexPathForItem:currentRow inSection:0];
    return self.currentIndexPath;
}


- (void)showIndexLabelWithOffset:(float)offset{
    //获取每一个cell所占的宽度 = 本身宽度 + 间隔
    
    float itemWidth = SCR_WIDTH - 134 + 38;
    NSInteger currentNum = offset / itemWidth;
    self.indexLabel.text = [NSString stringWithFormat:@"%ld/%lu", (long)++ currentNum,(unsigned long)self.dataArray.count];
}

#pragma mark --getter/setter
- (UICollectionView *)mainCollectView{
    if (!_mainCollectView) {
        
        _mainCollectView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:self.baseLayout];
        _mainCollectView.delegate = self;
        _mainCollectView.dataSource = self;
        _mainCollectView.backgroundColor = [UIColor lightGrayColor];
        _mainCollectView.showsHorizontalScrollIndicator = NO;
        [_mainCollectView registerClass:[XYHSmallCollectionViewCell class] forCellWithReuseIdentifier:ID];
        [_mainCollectView registerClass:[XYHBigCollectionViewCell class] forCellWithReuseIdentifier:ID_BIG];
    }
    return _mainCollectView;
}

- (UILabel *)indexLabel{
    if (!_indexLabel) {
        _indexLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, SCR_HEIGHT - 51 - 49, self.view.bounds.size.width, 51)];
        _indexLabel.font = [UIFont systemFontOfSize:11];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.hidden = YES;
    }
    return _indexLabel;
}

-(UICollectionViewFlowLayout*)baseLayout
{
    if(!_baseLayout)
    {
        _baseLayout = [[UICollectionViewFlowLayout alloc]init];
        _baseLayout.itemSize = CGSizeMake(getCellWidth, getCellHeight(getCellWidth));
        _baseLayout.minimumInteritemSpacing = 18;
        _baseLayout.minimumLineSpacing = 18;
        _baseLayout.sectionInset = UIEdgeInsetsMake(18, 18, 18, 18);
    }
    return _baseLayout;
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _dataArray;
}

- (NSIndexPath *)currentIndexPath{
    if (!_currentIndexPath) {
        _currentIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    return _currentIndexPath;
}




@end
