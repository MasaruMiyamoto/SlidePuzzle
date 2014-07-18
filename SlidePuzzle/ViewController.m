//
//  ViewController.m
//  SlidePuzzle
//
//  Created by PhysLab on 2014/07/17.
//  Copyright (c) 2014年 miyamoto. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIButton *chooseImageButton;
@property (weak, nonatomic) IBOutlet UIButton *startButoon;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.mainView.bounds];
    [self.mainView addSubview:imageView];
    self.imageView = imageView;
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
    
    //UIImagePickerControllerを閉じる
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
