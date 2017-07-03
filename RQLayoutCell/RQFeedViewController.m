//
//  RQFeedViewController.m
//  RQLayoutCell
//
//  Created by 蜂巢网络科技 on 2017/7/3.
//  Copyright © 2017年 fengchao. All rights reserved.
//

#import "RQFeedViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "RQFeedEntity.h"
#import "RQFeedCell.h"


static NSString *const cellWithIdentifier = @"RQFeedCell";

typedef NS_ENUM(NSInteger, FDSimulatedCacheMode) {
    FDSimulatedCacheModeNone = 0,
    FDSimulatedCacheModeCacheByIndexPath,
    FDSimulatedCacheModeCacheByKey
};


@interface RQFeedViewController ()<UIActionSheetDelegate>
@property (nonatomic, copy) NSArray *prototypeEntitiesFromJSON;
@property (nonatomic, strong) NSMutableArray *feedEntitySections; // 2d array
@property (nonatomic, weak) IBOutlet UISegmentedControl *cacheModeSegmentControl;

@end

@implementation RQFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.fd_debugLogEnabled = YES;

    // Cache by index path initial
    self.cacheModeSegmentControl.selectedSegmentIndex = 1;
    
   [self buildTestDataThen:^{
       self.feedEntitySections = @[].mutableCopy;
       [self.feedEntitySections addObject:self.prototypeEntitiesFromJSON.mutableCopy];
       [self.tableView reloadData];
   }];
}


- (void)buildTestDataThen:(void (^)(void))then
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *dataFilePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
        NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSArray *feedDicts = rootDict[@"feed"];
        
        NSMutableArray *entities = @[].mutableCopy;
        [feedDicts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            [entities addObject:[[RQFeedEntity alloc]initWithDictionary:obj]];
            
        }];
        self.prototypeEntitiesFromJSON = entities;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            !then ?:then();
        });
        
        
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.feedEntitySections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.feedEntitySections[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RQFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:cellWithIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(RQFeedCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
    if (indexPath.row % 2 == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.entity = self.feedEntitySections[indexPath.section][indexPath.row];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FDSimulatedCacheMode mode = self.cacheModeSegmentControl.selectedSegmentIndex;
    
    NSLog(@"selectedSegmentIndex  %zd",self.cacheModeSegmentControl.selectedSegmentIndex);
    switch (mode) {
        case FDSimulatedCacheModeNone:
            return [tableView fd_heightForCellWithIdentifier:cellWithIdentifier configuration:^(RQFeedCell *cell) {
                [self configureCell:cell atIndexPath:indexPath];
            }];
        case FDSimulatedCacheModeCacheByIndexPath:
            return [tableView fd_heightForCellWithIdentifier:cellWithIdentifier cacheByIndexPath:indexPath configuration:^(RQFeedCell *cell) {
                [self configureCell:cell atIndexPath:indexPath];
            }];
        case FDSimulatedCacheModeCacheByKey: {
            RQFeedEntity *entity = self.feedEntitySections[indexPath.section][indexPath.row];
            
            return [tableView fd_heightForCellWithIdentifier:cellWithIdentifier cacheByKey:entity.identifier configuration:^(RQFeedCell *cell) {
                [self configureCell:cell atIndexPath:indexPath];
            }];
        };
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *mutableEntities = self.feedEntitySections[indexPath.section];
        [mutableEntities removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


- (IBAction)refreshControlAction:(UIRefreshControl *)sender {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.feedEntitySections removeAllObjects];
        [self.feedEntitySections addObject:self.prototypeEntitiesFromJSON.mutableCopy];
        [self.tableView reloadData];
        [sender endRefreshing];
    });
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (IBAction)rightItemAction:(id)sender {
    
    [[[UIActionSheet alloc]
      initWithTitle:@"Actions"
      delegate:self
      cancelButtonTitle:@"Cancel"
      destructiveButtonTitle:nil
      otherButtonTitles:
      @"Insert a row",
      @"Insert a section",
      @"Delete a section", nil]
     showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    SEL selectors[] = {
        @selector(insertRow),
        @selector(insertSection),
        @selector(deleteSection)
    };
    
    if (buttonIndex < sizeof(selectors) / sizeof(SEL)) {
        void(*imp)(id, SEL) = (typeof(imp))[self methodForSelector:selectors[buttonIndex]];
        imp(self, selectors[buttonIndex]);
    }
}

#pragma clang diagnostic pop

- (RQFeedEntity *)randomEntity {
    NSUInteger randomNumber = arc4random_uniform((int32_t)self.prototypeEntitiesFromJSON.count);
    RQFeedEntity *randomEntity = self.prototypeEntitiesFromJSON[randomNumber];
    return randomEntity;
}

- (void)insertRow {
    if (self.feedEntitySections.count == 0) {
        [self insertSection];
    } else {
        [self.feedEntitySections[0] insertObject:self.randomEntity atIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)insertSection {
    [self.feedEntitySections insertObject:@[self.randomEntity].mutableCopy atIndex:0];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)deleteSection {
    if (self.feedEntitySections.count > 0) {
        [self.feedEntitySections removeObjectAtIndex:0];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
