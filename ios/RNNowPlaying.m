#import "RNNowPlaying.h"
#import "RCTEventDispatcher.h"

@implementation RNNowPlaying {
    bool hasListeners;
    NSDictionary *initialEventBody;
}


RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"NowPlayingEvent"];
}

- (RNNowPlaying *)init {
    self.musicPlayer = [MPMusicPlayerController systemMusicPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nowPlayingEventReceived:) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:self.musicPlayer];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nowPlayingEventReceived:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:self.musicPlayer];
        
    [self.musicPlayer beginGeneratingPlaybackNotifications];

    return self;
}

RCT_EXPORT_METHOD(isListening: (RCTResponseSenderBlock)callback)
{
    hasListeners = true;
    if (initialEventBody != Nil) {
            [self sendEventWithName:@"NowPlayingEvent" body:initialEventBody];
    }
    return callback(@[[NSNull null]]);
}

- (void)nowPlayingEventReceived:(NSNotification *)notification
{
    //e.playbackTime, e.playbackDuration, e.title, e.albumTitle, e.artist
    MPMusicPlayerController *player = (MPMusicPlayerController *)notification.object;
    MPMediaItem *item = [player nowPlayingItem];
    
    
    NSString *playbackTime = [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:player.currentPlaybackTime]];
    NSString *playbackDuration = [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:item.playbackDuration]];
    NSString *artist = [NSString stringWithFormat:@"%@", item.artist];
    NSString *albumTitle = [NSString stringWithFormat:@"%@", item.albumTitle];
    NSString *title = [NSString stringWithFormat:@"%@", item.title];
    
    if (player.playbackState == MPMusicPlaybackStatePlaying){
        NSDictionary *body = @{@"playbackTime": playbackTime,
                           @"playbackDuration": playbackDuration,
                           @"title": title,
                           @"albumTitle": albumTitle,
                           @"artist": artist
                           };
        if (hasListeners) {
            [self sendEventWithName:@"NowPlayingEvent" body:body];
        } else {
            initialEventBody = body;
        }

    }
        

}

@end
