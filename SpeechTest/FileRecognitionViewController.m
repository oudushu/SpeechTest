//
//  FileRecognitionViewController.m
//  SpeechTest
//
//  Created by Dushu Ou on 27/08/2017.
//  Copyright © 2017 Dushu Ou. All rights reserved.
//

#import "FileRecognitionViewController.h"
#import <Speech/Speech.h>

@interface FileRecognitionViewController ()

@end

@implementation FileRecognitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)startRecognizing:(id)sender {
    SFSpeechRecognizer *recognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"test.m4a" withExtension:nil];
    SFSpeechURLRecognitionRequest *request = [[SFSpeechURLRecognitionRequest alloc] initWithURL:url];
    [recognizer recognitionTaskWithRequest:request resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        if (result.isFinal) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"识别结果" message:[NSString stringWithFormat:@"%@", result.bestTranscription.formattedString] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:confirm];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

@end
