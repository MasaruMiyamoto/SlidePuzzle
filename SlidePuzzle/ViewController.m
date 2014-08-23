//
//  ViewController.m
//  SlidePuzzle
//
//  Created by PhysLab on 2014/07/17.
//  Copyright (c) 2014年 miyamoto. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+Cropping.h"

static NSInteger const kNumberOfRows = 4;
static NSInteger const kNumberOfColumns = 4;
static NSInteger const kNumberOfPieces = kNumberOfColumns * kNumberOfRows -  1;

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIButton *chooseImageButton;
@property (weak, nonatomic) IBOutlet UIButton *startButoon;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) NSArray *pieceViews;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *startDate;
@property (assign, nonatomic) CGPoint pointOfBlank;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //分割した画像を表示するためのビューを格納する配列
    NSMutableArray *pieceViews = [NSMutableArray array];
    
    for(NSInteger i = 0; i< kNumberOfPieces; i++){
        //UIImageView　のインスタンスを作成
        UIImageView *pieceView = [[UIImageView alloc] init];
        
        //mainView　のサブビューとして追加
        [self.mainView addSubview:pieceView];
        
        //配列に追加
        [pieceViews addObject:pieceView];
    }
    
    //配列をプロパティに設定
    self.pieceViews = pieceViews;
    
    //分割前の画像を表示するためのビューを作成
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.mainView.bounds];
    [self.mainView addSubview:imageView];
    self.imageView = imageView;
	// Do any additional setup after loading the view, typically from a nib.
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.mainView.bounds];
//    [self.mainView addSubview:imageView];
//    self.imageView = imageView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)performChooseImageButtonAction:(id)sender {
    //UIImagePickerControllerのインスタンスを作成
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    
    //画像の取得元をフォトライブラリに設定
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    //画像を選択後に正方形に加工するように設定
    controller.allowsEditing = YES;
    
    //デリゲードをselfに設定
    controller.delegate = self;
    
    //UIImagePickerController を表示
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)performStartButtonAction:(id)sender {
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //正方形に加工済みの画像を取得
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    //取得した画像をimageViewに設定
    self.imageView.image = image;
    
    
    //分割したピースの幅と高さを計算
    CGFloat width = image.size.width / kNumberOfColumns;
    CGFloat height = image.size.height / kNumberOfRows;
    
    for(NSInteger i = 0; i < kNumberOfPieces; i++){
        //画像を切り出すための矩形情報を計算
        CGFloat x = (i % kNumberOfColumns) * width;
        CGFloat y = (i / kNumberOfColumns) * height;
        CGRect rect = CGRectMake(x, y, width, height);
        
        //画像を切り出す
        UIImage *croppedImage = [image croppedImageInRect:rect];
        
        //分割後の画像を設定するためのビューを取得
        UIImageView *pieceView = self.pieceViews[i];
        
        //ビューの座標を設定
        pieceView.frame = [self pieceFrameAtIndex:i];
        
        //ビューに分割後の画像を設定
        pieceView.image = croppedImage;
        
        //ビューの現在位置を表すインデックスをタグとして保持
        pieceView.tag = i;
    }
    //現在の空き座標を表すプロパティを一番右下の座標に設定
    self.pointOfBlank = CGPointMake(kNumberOfColumns - 1, kNumberOfRows);
    
    //スタートボタンを表示
    self.startButoon.hidden = NO;
    
    
    
    //UIImagePickerControllerを閉じる
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(CGPoint)pointFromIndex:(NSInteger)index{
    return CGPointMake(index % kNumberOfColumns, index / kNumberOfColumns);
}

-(NSInteger)indexFromPoint:(CGPoint)point{
    return point.y * kNumberOfColumns + point.x;
}

-(CGRect)pieceFrameAtIndex:(NSInteger)index{
    CGPoint point = [self pointFromIndex:index];
    CGFloat width = self.mainView.frame.size.width / kNumberOfColumns;
    CGFloat height = self.mainView.frame.size.height / kNumberOfRows;
    return CGRectMake(point.x * width, point.y * height, width, height);
}

-(BOOL)canMovePieceFromPoint:(CGPoint)point{
    if(CGPointEqualToPoint(self.pointOfBlank, point))
        return NO;
    
    return self.pointOfBlank.x == point.x || self.pointOfBlank.y == point.y;
}

-(void)movePieceFromPoint:(CGPoint)point withAnimation:(BOOL)animation{
    if(![self canMovePieceFromPoint:point])
        return;
    
    //移動方向を決定する
    NSInteger step;
    if(self.pointOfBlank.x == point.x)
        step = self.pointOfBlank.y > point.y ? kNumberOfColumns : -kNumberOfColumns;
    else
        step = self.pointOfBlank.x > point.x ? 1 : -1;
    
    //移動対象のピースを格納する配列
    NSMutableArray *targetPieceViews = [NSMutableArray array];
    
    NSInteger indexOfBlank = [self indexFromPoint:self.pointOfBlank];
    NSInteger index = [self indexFromPoint:point];
    
    //移動対象のピースを抽出する
    while(index != indexOfBlank){
        for(UIImageView *pieceView in self.pieceViews){
            if(pieceView.tag == index){
                [targetPieceViews addObject:pieceView];
                break;
            }
        }
        index += step;
    }
    
    //移動対象のピースを実際に動かす
    //アニメーションが必要な場合は0.2秒かけてアニメーションをさせる
    //アニメーションが不要な場合はアニメーション時間を0秒にすることで即座に反映させられる
    [UIView animateWithDuration:animation ? 0.2f : 0 animations:^{
        //このブロック内でアニメーション対象のプロパティを変更すると、
        //指定した時間でアニメーションする
        for(UIImageView *pieceView in targetPieceViews){
            pieceView.tag += step;
            pieceView.frame = [self pieceFrameAtIndex:pieceView.tag];
        }
    }];
    
    self.pointOfBlank = point;
}

@end
