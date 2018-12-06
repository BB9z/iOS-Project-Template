
#import "MBAudioRecorder.h"
#import "MBErrorCode.h"
#import <MBAppKit/MBGeneralCallback.h>
#import <RFKit/NSFileManager+RFKit.h>
@import AVFoundation;

@interface MBAudioRecorder () <AVAudioRecorderDelegate>
@property AVAudioRecorder *_recorder;
@property NSError *lastError;
@property MBGeneralCallback _stopCallback;
@end

@implementation MBAudioRecorder

+ (NSDictionary<NSString *, id> *)settingsForVoIP {
    return @{
             AVFormatIDKey: @(kAudioFormatMPEG4AAC_ELD),
             AVSampleRateKey: @16000.0,
             AVNumberOfChannelsKey: @1,
             AVEncoderBitRateKey: @8000,
             AVEncoderBitRateStrategyKey: AVAudioBitRateStrategy_Variable,
             AVEncoderBitDepthHintKey: @8,
             AVEncoderAudioQualityForVBRKey: @(AVAudioQualityMin)
             };
}

+ (NSDictionary<NSString *, id> *)settingsForLowMusic {
    return @{
             AVFormatIDKey: @(kAudioFormatMPEG4AAC_ELD),
             AVSampleRateKey: @32000.0,
             AVNumberOfChannelsKey: @1,
             AVEncoderBitRateStrategyKey: AVAudioBitRateStrategy_Variable,
             AVEncoderAudioQualityForVBRKey: @(AVAudioQualityLow)
             };
}

- (BOOL)startRecordError:(NSError *__autoreleasing  _Nullable *)outError {
    if (self._recorder) {
        if (outError) {
            *outError = [NSError errorWithDomain:@"MBAudioRecorder" code:MBErrorOperationUnfinished localizedDescription:@"上个录音仍在进行中"];
        }
        return NO;
    }
    if (self.preferredSessionCategory) {
        [AVAudioSession.sharedInstance setCategory:self.preferredSessionCategory error:nil];
    }
    
    NSURL *fileURL = self.recordFileURL;
    if (!fileURL) {
        // 后缀必须添加，一是影响 AVAudioRecorder 写入时的格式，二是本地播放需要（后缀提示播放器是什么格式，后缀和实际格式不匹配可能无法播放）
        // 如果录音只是本地使用，caf（Core Audio Format 封装格式）是不错的选择，但 Android 无法播放；
        // 正常业务需要用 m4a（内部封装 AAC），以支持 Android 原生播放
        NSString *tempFilePath = [[NSTemporaryDirectory() stringByAppendingString:NSUUID.UUID.UUIDString] stringByAppendingPathExtension:@"m4a"];
        fileURL = [NSURL.alloc initFileURLWithPath:tempFilePath];
    }
    AVAudioRecorder *r = [AVAudioRecorder.alloc initWithURL:fileURL settings:self.settings error:outError];
    r.delegate = self;
    if (r) {
        self.paused = NO;
        self.lastError = nil;
        self._recorder = r;
        return [r record];
    }
    return NO;
}

- (void)stopRecordComplation:(void (^)(BOOL, NSURL *, NSError *))complation {
    MBGeneralCallback cb = MBSafeCallback(complation);
    AVAudioRecorder *r = self._recorder;
    if (!r) {
        cb(NO, nil, [NSError errorWithDomain:@"MBAudioRecorder" code:MBErrorOperationCanceled localizedDescription:@"没有开始录音"]);
        return;
    }
    self._recorder = nil;
    self.paused = NO;
    self._stopCallback = complation;
    [r stop];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (self._stopCallback) {
        self._stopCallback(flag, recorder.url, self.lastError);
        self._stopCallback = nil;
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    self.lastError = error;
}

- (BOOL)isRecording {
    return self._recorder.recording;
}

- (void)setPaused:(BOOL)paused {
    _paused = paused;
    if (paused) {
        [self._recorder pause];
    }
    else {
        [self._recorder record];
    }
}

@end
