                           //
//  ZFRecognitionViewController.m
//  ZFProspect2
//
//  Created by 朱敏 on 15/10/9.
//  Copyright (c) 2015年 com.ZF. All rights reserved.
//

#import "ZFRecognitionViewController.h"
#import "BaiduOCR.h"
#import "MBProgressHUD+ZM.h"
#import "UIImage+scale.h"

//屏幕宽、高
#define kScreen_bounds      ([[UIScreen mainScreen] bounds])
#define kScreen_width       ([[UIScreen mainScreen] bounds].size.width)
#define kScreen_height      ([[UIScreen mainScreen] bounds].size.height)

typedef enum {
    ZFRecognitionEnumAdd,
    ZFRecognitionEnumEdit
} ZFRecognitionEnum;

@interface ZFRecognitionViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;      // 身份证照片
@property (nonatomic, strong) NSMutableArray *reslut;             // 人员信息
@property (weak, nonatomic) IBOutlet UIView *infoBackgroundView;  // 人员信息背景View
@property (weak, nonatomic) IBOutlet UITextField *realNameField;  // 姓名
@property (weak, nonatomic) IBOutlet UITextField *genderField;    // 姓别
@property (weak, nonatomic) IBOutlet UITextField *nationField;    // 国籍
@property (weak, nonatomic) IBOutlet UITextField *birthdayField;  // 生日
@property (weak, nonatomic) IBOutlet UITextView *addressTextView; // 地址
@property (weak, nonatomic) IBOutlet UITextField *idcardnoField;  // 身份证号码
@property (nonatomic, assign) ZFRecognitionEnum viewType;         // 控制器类型
@property (weak, nonatomic) IBOutlet UIButton *yellowButton;
@property (nonatomic, strong) ZFLabourManageModel *model;

/**
 *  一定需要设置
 */
@property (nonatomic, strong) NSMutableArray *personsArray;       // 人员集合
@property (nonatomic, strong) NSMutableArray *addPersonsArray;        // 新增人员
@end

@implementation ZFRecognitionViewController
//- (IBAction)choosePhoto:(id)sender {
//    UIActionSheet *action = [[UIActionSheet alloc]  initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
//    [action showInView:self.view];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"图像识别";
}

- (IBAction)reCarmera {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
    [actionSheet showInView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)uploadRecognitionWithImage:(UIImage *)uploadImage {
    [MBProgressHUD showMessage:@"正在识别图像" toView:self.view];
    
    [BaiduOCR uploadRecognitionWithImage:uploadImage andCompletion:^(NSError *error, NSData *data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view];
        });
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showError:[NSString stringWithFormat:@"识别失败"]];
            });
            return ;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showSuccess:@"识别成功"];
        });
        
        NSMutableArray *arrayM = [NSMutableArray array];
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        NSArray *array = responseDict[@"retData"];
        for (NSDictionary *dict in array) {
            NSString *str = dict[@"word"];
            [arrayM addObject:str];
        }
        self.reslut = arrayM;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (arrayM.count < 1) return ;
            NSRange range1 = [arrayM[0] rangeOfString:@"姓名"];
            if (range1.length) [self.realNameField setText:[arrayM[0] substringFromIndex:range1.location + range1.length]];
            
            if (arrayM.count < 2) return ;
            NSRange range2 = [arrayM[1] rangeOfString:@"性别"];
            NSRange range3 = [arrayM[1] rangeOfString:@"民族"];
            if (range2.length) {
                NSString *subStr = [arrayM[1] substringFromIndex:range2.location + range2.length];
                NSString *gender = [subStr substringToIndex:1];
                [self.genderField setText:gender];
                if (range3.length) {
                    [self.nationField setText:[arrayM[1] substringFromIndex:range3.location + range3.length]];
                }
            }
            
            if (arrayM.count < 3) return ;
            NSRange range4 = [arrayM[2] rangeOfString:@"出生"];
            if (range4.length) [self.birthdayField setText:[arrayM[2] substringFromIndex:range4.location + range4.length]];
            
            if (arrayM.count < 4) return ;
            NSRange range5 = [arrayM[3] rangeOfString:@"住址"];
            NSString *address = @"";
            if (range5.length) address = [arrayM[3] substringFromIndex:range5.location + range5.length];
            
            if (arrayM.count < 5) return ;
            NSRange range6 = [arrayM[4] rangeOfString:@"公民身份号码"];
            
            if (range6.length) {
                [self.idcardnoField setText:[arrayM[4] substringFromIndex:range6.location + range6.length]];
            } else {
                NSString *address2 = [NSString stringWithString:arrayM[4]];
                [self.addressTextView setText:[address stringByAppendingString:address2]];
                
                if (arrayM.count < 6) return ;
                NSRange range7 = [arrayM[5] rangeOfString:@"公民身份号码"];
                if (range7.length) {
                    [self.idcardnoField setText:[arrayM[5] substringFromIndex:range7.location + range7.length]];
                } else {
                    NSString *address3 = [NSString stringWithString:arrayM[5]];
                    [self.addressTextView setText:[[address stringByAppendingString:address2] stringByAppendingString:address3]];
                    
                    if (arrayM.count < 7) return ;
                    NSRange range8 = [arrayM[6] rangeOfString:@"公民身份号码"];
                    if (range8.length) {
                        [self.idcardnoField setText:[arrayM[6] substringFromIndex:range8.location + range8.length]];
                    }
                }
                
            }
        });
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self showCamera];
    }
    else if (buttonIndex == 1) {
        [self showPhotoLibrary];
    }
}

- (void)showCamera {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    UIImagePickerController  *pickerController = [[UIImagePickerController alloc]init];
    pickerController.delegate = self;
    pickerController.sourceType = sourceType;
    UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_width, (kScreen_height - (250 * kScreen_width / 320)) / 2.0)];
    upView.backgroundColor = [[UIColor alloc] initWithWhite:0 alpha:0.3];
    upView.userInteractionEnabled = NO;
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, upView.bounds.size.height + (250 * kScreen_width / 320), kScreen_width, upView.bounds.size.height)];
    downView.userInteractionEnabled = NO;
    downView.backgroundColor = [[UIColor alloc] initWithWhite:0 alpha:0.3];
    [pickerController.view addSubview:upView];
    [pickerController.view addSubview:downView];
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)showPhotoLibrary {
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* theImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    // 必须进行图片处理，图片不能大于300KB
    UIImage *newImage = [UIImage OriginImage:theImage scaleToSize:CGSizeMake(425, 567)];
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        theImage = [info objectForKey:UIImagePickerControllerEditedImage];
        newImage = [UIImage OriginImage:theImage scaleToSize:CGSizeMake(425, 425)];
    }
    UIImage *theImage2 = nil;
    if (!picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) theImage2 = [UIImage OriginImage:newImage interceptionToFrame:CGRectMake(0, 143, 425, 300)];
    
    
    [self.imageView setImage:theImage2 ? theImage2 : newImage];
    [self uploadRecognitionWithImage:theImage2 ? theImage2 : newImage];
    //
    [picker dismissViewControllerAnimated:YES completion:NULL];

}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
}

-(UIImage *)makeThumbnailFromImage:(UIImage *)srcImage scale:(double)imageScale {
    UIImage *thumbnail = nil;
    CGSize imageSize = CGSizeMake(srcImage.size.width * imageScale, srcImage.size.height * imageScale);
    
    UIGraphicsBeginImageContext(imageSize);
    CGRect imageRect = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
    [srcImage drawInRect:imageRect];
    thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return thumbnail;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.personsArray removeObject:self.model];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
