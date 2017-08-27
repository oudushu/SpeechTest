//
//  ViewController.m
//  SpeechTest
//
//  Created by Dushu Ou on 26/08/2017.
//  Copyright © 2017 Dushu Ou. All rights reserved.
//

#import "ViewController.h"
#import <Speech/Speech.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;

@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 请求权限
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        NSLog(@"status %@", status == SFSpeechRecognizerAuthorizationStatusAuthorized ? @"授权成功" : @"授权失败");
    }];
    
    [self.recordButton addTarget:self action:@selector(startRecording:) forControlEvents:UIControlEventTouchDown];
    [self.recordButton addTarget:self action:@selector(stopRecording:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
}

- (void)initEngine {
    if (!self.speechRecognizer) {
        // 设置语言
        NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"];
        self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:locale];
    }
    if (!self.audioEngine) {
        self.audioEngine = [[AVAudioEngine alloc] init];
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord mode:AVAudioSessionModeMeasurement options:AVAudioSessionCategoryOptionDuckOthers error:nil];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    
    if (self.recognitionRequest) {
        [self.recognitionRequest endAudio];
        self.recognitionRequest = nil;
    }
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    self.recognitionRequest.shouldReportPartialResults = YES; // 实时翻译
    
    [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        NSLog(@"is final: %d  result: %@", result.isFinal, result.bestTranscription.formattedString);
        if (result.isFinal) {
            self.textView.text = [NSString stringWithFormat:@"%@%@", self.textView.text, result.bestTranscription.formattedString];
        }
    }];
}

- (void)releaseEngine {
    [[self.audioEngine inputNode] removeTapOnBus:0];
    [self.audioEngine stop];
    
    [self.recognitionRequest endAudio];
    self.recognitionRequest = nil;
}

- (void)startRecording:(UIButton *)recordButton {
    [self initEngine];
    
    AVAudioFormat *recordingFormat = [[self.audioEngine inputNode] outputFormatForBus:0];
    [[self.audioEngine inputNode] installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self.recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    [self.audioEngine prepare];
    [self.audioEngine startAndReturnError:nil];
    
    [recordButton setTitle:@"录音ing" forState:UIControlStateNormal];
}

- (void)stopRecording:(UIButton *)recordButton {
    [self releaseEngine];
    
    [recordButton setTitle:@"录音" forState:UIControlStateNormal];
}

@end
