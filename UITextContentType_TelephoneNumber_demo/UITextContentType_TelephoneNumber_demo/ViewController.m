//
//  ViewController.m
//  UITextContentType_TelephoneNumber_demo
//
//  Created by zyk on 2018/12/13.
//  Copyright © 2018年 zyktom. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITextFieldDelegate>
@property(nonatomic,strong) UITextField * txtPhoneNumber;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldEditChanged:) name:UITextFieldTextDidChangeNotification object:self.txtPhoneNumber];

    if (@available(iOS 10.0, *)) {
        self.txtPhoneNumber.textContentType = UITextContentTypeTelephoneNumber;
        self.txtPhoneNumber.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }else
    {
        self.txtPhoneNumber.keyboardType = UIKeyboardTypeNumberPad;
    } 
}

-(UITextField *)txtPhoneNumber{
    if (!_txtPhoneNumber) {
        _txtPhoneNumber = [UITextField new];
        _txtPhoneNumber.delegate = self;
        [_txtPhoneNumber setBackgroundColor:[UIColor grayColor]];
        _txtPhoneNumber.placeholder = @"请输入手机号";
        [_txtPhoneNumber setFrame:CGRectMake(100, 100, 140, 44)];
        [self.view addSubview:_txtPhoneNumber];
    }
    return _txtPhoneNumber;
}


#pragma mark - UITextFieldTextDidChangeNotification
-(void)textFieldEditChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    //兼容键盘QuickType Bar以+86开头的号码
    toBeString = [toBeString stringByReplacingOccurrencesOfString:@"+" withString:@""];
    //兼容英文键盘前后空格
    toBeString = [toBeString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (toBeString.length>0) {
        if (![self isNumber:toBeString]) {
            //兼容输入非数字时的处理 ，切去最后一位
            toBeString = [toBeString substringToIndex:toBeString.length-1];
        }
    }
    textField.text = toBeString;
    
    //此处为处理键盘提示号码逻辑（如：8618000000000）及（如：+861800000000）
    if (@available(iOS 10.0, *)) {
        //兼容号码数字键盘
        if (toBeString.length==13) {
            NSString * startString = [toBeString substringToIndex:3];
            if ([startString isEqualToString:@"861"]) {
                //当字符串长度为13位，并以861开头时，截取86，余下则为11位手机号
                textField.text = [toBeString substringFromIndex:2];
            }
        }
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    if (textField == self.txtPhoneNumber) {
        if ([self isContainsEmoji:string]) {
            //禁输表情符号
            return NO;
        }
    }
    return YES;
}

#pragma mark - Utility

-(BOOL)isNumber:(NSString *)phoneNumber
{
    if ([phoneNumber length]==0||phoneNumber==nil) {
        return NO;
    }
    NSString *Regex = @"^[0-9]*$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];
    return [emailTest evaluateWithObject:phoneNumber];
}


-(BOOL)isContainsEmoji:(NSString *)string {
    if (string.length<=0) {
        return NO;
    }
    //如果是emoji输入法，直接禁用，输入类型为nil是。也是禁用的
    if ([[[UIApplication sharedApplication]textInputMode].primaryLanguage isEqualToString:@"emoji"]||
        [[UIApplication sharedApplication]textInputMode].primaryLanguage==nil) {
        return YES;
    }
    //九宫格特殊处理
    if ([string isEqualToString:@"➋"]||
        [string isEqualToString:@"➌"]||
        [string isEqualToString:@"➍"]||
        [string isEqualToString:@"➎"]||
        [string isEqualToString:@"➏"]||
        [string isEqualToString:@"➐"]||
        [string isEqualToString:@"➑"]||
        [string isEqualToString:@"➒"])
    {
        return NO;
    }
    __block BOOL isEomji = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     isEomji = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 isEomji = YES;
             }
         } else {
             if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                 isEomji = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 isEomji = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 isEomji = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 isEomji = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                 isEomji = YES;
             }
         }
     }];
    return isEomji;
}

@end
