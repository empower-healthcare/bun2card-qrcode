//
//  QRViewController3.m
//  QRPlugin01
//
//  Created by ITS-J on 2014/07/11.
//
//

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "QRViewController3.h"

@interface QRViewController3 () <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureSession *session;

@end

@implementation QRViewController3
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.hidden = YES;
    
    self.viewControllerStart = true;
    self.session = [[AVCaptureSession alloc] init];
    @try {

        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        AVCaptureDevice *device = nil;
        for (AVCaptureDevice *d in devices) {
            device = d;
            if (d.position == self.devicePosition) {
                break;
            }
        }
    
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
        
        if (input == nil) {
            [NSException raise:@"AVCaptureDeviceNotFound" format:@"カメラを起動できません。"];
        }
        
        [self.session addInput:input];
        
        AVCaptureMetadataOutput *output = [AVCaptureMetadataOutput new];
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [self.session addOutput:output];
        
        // 読取対象
        NSMutableArray *types = [NSMutableArray array];
        if (self.typeQRCode) {
            [types addObject:AVMetadataObjectTypeQRCode];
        }
        if (self.typeUPCE) {
            [types addObject:AVMetadataObjectTypeUPCECode];
        }
        if (self.typeCode39) {
            [types addObject:AVMetadataObjectTypeCode39Code];
        }
        if (self.typeCode39Mod43) {
            [types addObject:AVMetadataObjectTypeCode39Mod43Code];
        }
        if (self.typeEAN13) {
            [types addObject:AVMetadataObjectTypeEAN13Code];
        }
        if (self.typeEAN8) {
            [types addObject:AVMetadataObjectTypeEAN8Code];
        }
        if (self.typeCode93) {
            [types addObject:AVMetadataObjectTypeCode93Code];
        }
        if (self.typeCode128) {
            [types addObject:AVMetadataObjectTypeCode128Code];
        }
        output.metadataObjectTypes = types;
        
        // ビデオプレビュー
        AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.view.layer addSublayer:preview];
        [self.view.layer setValue:preview forKey:@"preview"];
    
        // 四角表示
        CALayer *boxLayer = [CALayer layer];
        boxLayer.borderWidth = 1.0f;
        boxLayer.borderColor = [UIColor whiteColor].CGColor;
        [self.view.layer addSublayer:boxLayer];
        [self.view.layer setValue:boxLayer forKey:@"boxLayer"];
        
        // メッセージ
        UILabel *msgLabel = [[UILabel alloc] init];
        msgLabel.tag = 3;
        msgLabel.backgroundColor = [UIColor colorWithRed:134/255.0 green:192/255.0 blue:63/255.0 alpha:1]; //（１）メッセージ背景色
        msgLabel.layer.cornerRadius = 18.0f;
        msgLabel.clipsToBounds = YES;
        msgLabel.font = [UIFont fontWithName:@"AppleGothic" size:12.0]; //（２）メッセージ文字タイプ
        msgLabel.textColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1]; // （３）メッセージ文字色
        msgLabel.textAlignment = NSTextAlignmentCenter;
        msgLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        [self.view addSubview:msgLabel];

        // ボタン
        CALayer *buttonLayer1 = [CALayer layer];
        buttonLayer1.frame = CGRectMake(0, 0, 200, 60);
        buttonLayer1.backgroundColor = [UIColor colorWithRed:255/255.0 green:241/255.0 blue:108/255.0 alpha:1].CGColor; //（４）ボタン背景色１
        buttonLayer1.cornerRadius = 18.0f;
        [self.view.layer addSublayer:buttonLayer1];
        [self.view.layer setValue:buttonLayer1 forKey:@"buttonLayer1"];
        
        CALayer *buttonLayer2 = [CALayer layer];
        buttonLayer2.frame = CGRectMake(0, 0, 196, 30);
        buttonLayer2.backgroundColor = [UIColor colorWithRed:255/255.0 green:241/255.0 blue:108/255.0 alpha:1].CGColor; // （５）ボタン背景色２
        buttonLayer2.cornerRadius = 15.0f;
        [self.view.layer addSublayer:buttonLayer2];
        [self.view.layer setValue:buttonLayer2 forKey:@"buttonLayer2"];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.tag = 1;
        button.frame = CGRectMake(0, 0, 200, 60);
        button.backgroundColor = [UIColor colorWithRed:255/255.0 green:241/255.0 blue:108/255.0 alpha:0];
        button.clipsToBounds = YES;
        [button setTitle:@"キャンセル" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"AppleGothic" size:30.0]; //（６）ボタン文字タイプ
        button.titleLabel.textColor = [UIColor colorWithRed:71/255.0 green:67/255.0 blue:66/255.0 alpha:1.0]; // （７）ボタン文字色
        [button setTitleColor:[UIColor colorWithRed:71/255.0 green:67/255.0 blue:66/255.0 alpha:1.0] forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(cancelView:)
         forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        
        // 画像
        /*
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = 2;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:imageView];
        */
        // 位置調整
        [self controllOrientation : self.interfaceOrientation];
        
        [self.session startRunning];
    }
    @catch (NSException *exception) {
        NSLog(@"例外名：%@", exception.name);
        NSLog(@"例外内容：%@", exception.reason);
        [self.session stopRunning];
        self.viewControllerStart = false;
    }

}

- (void) viewWillAppear:(BOOL)animated
{
    self.view.hidden = NO;
    [self controllOrientation :  self.interfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    for (AVMetadataObject *metadata in metadataObjects) {
        NSString *code = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
        [self closeView:code];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // 画面回転時の呼び出し
    // 位置調整
    [self controllOrientation : toInterfaceOrientation];
}

/* 
 画面回転処理。
 */
- (void)controllOrientation : (UIInterfaceOrientation) toInterfaceOrientation {
    // 位置調整が必要なオブジェクトの取得
    UIButton *button = (UIButton*)[self.view viewWithTag:1];
    //UIImageView *imageView = (UIImageView*)[self.view viewWithTag:2];
    UILabel *msgLabel = (UILabel*)[self.view viewWithTag:3];
    AVCaptureVideoPreviewLayer *preview = [self.view.layer valueForKey:@"preview"];
    CALayer *boxLayer = [self.view.layer valueForKey:@"boxLayer"];
    CALayer *buttonLayer1 = [self.view.layer valueForKey:@"buttonLayer1"];
    CALayer *buttonLayer2 = [self.view.layer valueForKey:@"buttonLayer2"];

    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;

    AVCaptureVideoOrientation orientation;
   
    // 位置調整
    CGFloat marginTop = 20;
    CGFloat marginWidth = 40;
    CGFloat marginHeight = 80;
    
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft :
            width = MAX(self.view.bounds.size.width, self.view.bounds.size.height);
            height = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
            orientation =  AVCaptureVideoOrientationLandscapeLeft;
            
            break;
        case UIInterfaceOrientationLandscapeRight :
            width = MAX(self.view.bounds.size.width, self.view.bounds.size.height);
            height = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIInterfaceOrientationPortrait :
            width = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
            height = MAX(self.view.bounds.size.width, self.view.bounds.size.height);
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown :
            width = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
            height = MAX(self.view.bounds.size.width, self.view.bounds.size.height);
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            // 不明の場合は横と認識してキャンセルボタンが表示されるようにする
            width = MAX(self.view.bounds.size.width, self.view.bounds.size.height);
            height = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
            orientation =  AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    
    CGFloat frameWidth = width;
    CGFloat frameHeight = height;
   
    CGFloat centerX = width / 2;
    
    msgLabel.frame = CGRectMake(marginWidth,
                                marginTop,
                                frameWidth - (marginWidth * 2),
                                50);
    // 四角表示
    boxLayer.frame = CGRectMake(marginWidth,
                                marginHeight,
                                frameWidth - (marginWidth * 2),
                                frameHeight - (marginHeight * 2));
    // ボタン
    button.center = CGPointMake(centerX, frameHeight - (marginHeight/2));
    

    //image = nil;
    // プレビュー
    preview.frame = CGRectMake(0, 0, frameWidth, frameHeight);
    preview.connection.videoOrientation = orientation;
    
    // メッセージ
    msgLabel.text = @"QRコードをカメラに向けてください。";
    // ボタン背景
    buttonLayer1.frame = button.frame;
    buttonLayer2.frame = CGRectMake(button.frame.origin.x + 2,
                                    button.frame.origin.y + 2,
                                    buttonLayer2.frame.size.width,
                                    buttonLayer2.frame.size.height);
}

-(void) cancelView:(id)sender {
    // キャンセル
    [self closeView:nil];
}

-(void) closeView:(NSString*) str {
    if ([delegate respondsToSelector:@selector(closeView:)]) {
        [delegate closeView:str];
    }
    [self.session stopRunning];
}

// 画面自動回転をYESにする
- (BOOL)shouldAutorotate {
    return YES;
}
// サポートする画面向き
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end
