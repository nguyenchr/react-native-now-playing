#import "RNNowPlaying.h"
#import "RCTEventDispatcher.h"

@implementation RNNowPlaying


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

RCT_EXPORT_METHOD(getTrack: (RCTResponseSenderBlock)callback)
{
    MPMediaItem *item = [[MPMusicPlayerController iPodMusicPlayer] nowPlayingItem];
    NSString *artist = [NSString stringWithFormat:@"%@", item.title];
    callback(@[[NSNull null], @{@"artist": artist
                                }]);
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
        [self sendEventWithName:@"NowPlayingEvent"
                           body:@{@"playbackTime": playbackTime,
                                  @"playbackDuration": playbackDuration,
                                  @"title": title,
                                  @"albumTitle": albumTitle,
                                  @"artist": artist
                                  
                                  }];
    }
        

}

@end
