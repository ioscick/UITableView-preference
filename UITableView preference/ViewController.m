//
//  ViewController.m
//  UITableView preference
//
//  Created by shenliping on 16/4/11.
//  Copyright © 2016年 shenliping. All rights reserved.
//

#import "ViewController.h"
#import "EaseChineseToPinyin.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *dataArray;//初始数据源
@property (strong, nonatomic) NSMutableArray *sectionHeaderArray;//sectionHeader数组
@property (strong, nonatomic) NSMutableArray *sortArray;//整理好的数据源

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated{
    self.title = @"通讯录";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self
                                                                          action:@selector(deleteItem)];
    self.navigationItem.leftBarButtonItem = item;
    [self.view addSubview:self.tableView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self sort_searchList];
    });
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)deleteItem{
    [self.tableView setEditing:YES animated:YES];
}

- (void)sort_searchList{
    // 获取A~Z的排序
    UILocalizedIndexedCollation *indexedCollation = [UILocalizedIndexedCollation currentCollation];
    [self.sectionHeaderArray addObjectsFromArray:[indexedCollation sectionTitles]];
    
    NSMutableArray *sortarray = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.sectionHeaderArray.count; i++) {
        NSMutableArray *sectionArray = [[NSMutableArray alloc] init];
        [sortarray addObject:sectionArray];
    }
    
    for (NSString *str in self.dataArray) {
        NSString *fitst = [EaseChineseToPinyin pinyinFromChineseString:str];
        NSInteger index = [indexedCollation sectionForObject:[fitst substringFromIndex:0] collationStringSelector:@selector(uppercaseString)];
        [sortarray[index] addObject:str];
    }
    
    //每个section内的数组排序
    for (int i = 0; i < [sortarray count]; i++) {
        NSArray *array = [[sortarray objectAtIndex:i] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            NSString *firstLetter1 = [EaseChineseToPinyin pinyinFromChineseString:obj1];
            firstLetter1 = [[firstLetter1 substringToIndex:1] uppercaseString];
            
            NSString *firstLetter2 = [EaseChineseToPinyin pinyinFromChineseString:obj2];
            firstLetter2 = [[firstLetter2 substringToIndex:1] uppercaseString];
            
            return [firstLetter1 caseInsensitiveCompare:firstLetter2];
        }];
        
        
        [sortarray replaceObjectAtIndex:i withObject:[NSMutableArray arrayWithArray:array]];
    }
    
    //去掉空的section
    for (NSInteger i = [sortarray count] - 1; i >= 0; i--) {
        NSArray *array = [sortarray objectAtIndex:i];
        if ([array count] == 0) {
            [sortarray removeObjectAtIndex:i];
            [self.sectionHeaderArray removeObjectAtIndex:i];
        }
    }
    
    [self.sortArray addObjectsFromArray:sortarray];

    [self.tableView reloadData];
}


- (NSMutableArray *)sectionHeaderArray{
    if (_sectionHeaderArray == nil) {
        _sectionHeaderArray = [[NSMutableArray alloc] init];
    }
    return _sectionHeaderArray;
}

- (NSMutableArray *)sortArray{
    if (_sortArray == nil) {
        _sortArray = [[NSMutableArray alloc] init];
    }
    return _sortArray;
}

- (NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] initWithObjects:@"张三", @"李四", @"王五", @"沈银", @"飞翔", @"周杰伦", @"李连杰", @"王力宏", @"许嵩", @"林俊杰", @"亚索", @"伊泽", nil];
    }
    return _dataArray;
}

- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return self.sectionHeaderArray;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 22;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *contentView = [[UIView alloc] init];
    [contentView setBackgroundColor:[UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 22)];
    label.backgroundColor = [UIColor clearColor];
    [label setText:[self.sectionHeaderArray objectAtIndex:(section)]];
    [contentView addSubview:label];
    return contentView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = [self.sortArray[indexPath.section] objectAtIndex:indexPath.row];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sortArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.sortArray[section] count];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.sortArray[indexPath.section] removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
   
//    [self.tableView reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
