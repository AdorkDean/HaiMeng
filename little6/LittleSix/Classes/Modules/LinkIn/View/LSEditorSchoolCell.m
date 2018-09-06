//
//  LSEditorSchoolCell.m
//  LittleSix
//
//  Created by GMAR on 2017/3/3.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSEditorSchoolCell.h"

@interface LSEditorSchoolCell()<UITextFieldDelegate>

@end

@implementation LSEditorSchoolCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.suTextF.delegate = self;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    if (self.indexPath.row == 0) {
        
        if (self.stringClick) {
            self.stringClick(textField.text,self.indexPath);
        }
    }
    [textField resignFirstResponder];
    
    return YES;
}




@end
