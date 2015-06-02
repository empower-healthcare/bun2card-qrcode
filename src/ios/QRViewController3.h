//
//  QRViewController3.h
//  QRPlugin01
//
//  Created by Tome on 2014/07/11.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol CloseDelegate <NSObject>
-(void) closeView:(NSString*)str;
@end

@interface QRViewController3 : UIViewController{
    __weak id <CloseDelegate> delegate;
}
@property (nonatomic, weak) id <CloseDelegate> delegate;
@property (nonatomic, unsafe_unretained) AVCaptureDevicePosition devicePosition;
@property (nonatomic, unsafe_unretained) BOOL typeUPCE;
@property (nonatomic, unsafe_unretained) BOOL typeCode39;
@property (nonatomic, unsafe_unretained) BOOL typeCode39Mod43;
@property (nonatomic, unsafe_unretained) BOOL typeEAN13;
@property (nonatomic, unsafe_unretained) BOOL typeEAN8;
@property (nonatomic, unsafe_unretained) BOOL typeCode93;
@property (nonatomic, unsafe_unretained) BOOL typeCode128;
@property (nonatomic, unsafe_unretained) BOOL typeQRCode;

@property (nonatomic, unsafe_unretained) Boolean viewControllerStart;
@property (nonatomic, unsafe_unretained) UIDeviceOrientation deviceOrientation;

@end
