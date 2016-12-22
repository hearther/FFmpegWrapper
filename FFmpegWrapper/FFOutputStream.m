//
//  FFOutputStream.m
//  LiveStreamer
//
//  Created by Christopher Ballinger on 10/1/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

#import "FFOutputStream.h"
#import "FFOutputFile.h"
#import "FFUtilities.h"

@implementation FFOutputStream
@synthesize lastMuxDTS, frameNumber;

- (id) initWithOutputFile:(FFOutputFile*)outputFile outputCodec:(NSString*)outputCodec {
    if (self = [super initWithFile:outputFile]) {
        self.lastMuxDTS = AV_NOPTS_VALUE;
        self.frameNumber = 0;
        
        AVCodec *codec = avcodec_find_encoder_by_name([outputCodec UTF8String]);
        if (!codec) {
            NSLog(@"codec not found: %@", outputCodec);
        }
        self.stream = avformat_new_stream(outputFile.formatContext, codec);
        [outputFile addOutputStream:self];
    }
    return self;
}

- (void) setupVideoContextWithWidth:(int)width height:(int)height {
    AVCodecContext *c = self.stream->codec;
    int codecID = AV_CODEC_ID_H264;
    AVCodec *codec = avcodec_find_encoder(codecID);
    if (!codec) {
        NSLog(@"video codec not found: %d", codecID);
    }
    /* find the video encoder */
    avcodec_get_context_defaults3(c, codec);

    c->codec_id = codecID;//CODEC_ID_MPEG2VIDEO;
    c->codec_type = AVMEDIA_TYPE_VIDEO;
    c->width    = width;
	c->height   = height;
//    c->bit_rate = 0;
    //http://stackoverflow.com/questions/34675983/ffmpeg-convert-avi-into-playable-ios-movie-mp4
    c->profile = FF_PROFILE_H264_BASELINE;
    c->level = 31;
    
    c->time_base.den = 30;
	c->time_base.num = 1;
    c->pix_fmt       = AV_PIX_FMT_YUV420P;

    self.stream->time_base  = c->time_base;
	if (self.parentFile.formatContext->oformat->flags & AVFMT_GLOBALHEADER)
		c->flags |= CODEC_FLAG_GLOBAL_HEADER;
    
    int ret = avcodec_open2(self.stream->codec, codec, NULL);
    if (ret < 0) {
        NSLog(@"Could not open codec! error %@", [FFUtilities errorForAVError:ret]);
    }

}

- (void) setupAudioContextWithSampleRate:(int)sampleRate {
    AVCodecContext *codecContext = self.stream->codec;
    int codecID = AV_CODEC_ID_AAC;
    AVCodec *codec = avcodec_find_encoder(codecID);
    if (!codec) {
        NSLog(@"audio codec not found: %d", codecID);
    }
    /* find the audio encoder */
    avcodec_get_context_defaults3(codecContext, codec);
	codecContext->codec_id = codecID;
	codecContext->codec_type = AVMEDIA_TYPE_AUDIO;
    
	//st->id = 1;
    //https://mtbcode.wordpress.com/2013/03/05/ffmpeg-enable-experimental-codecs-in-your-own-code/
	codecContext->strict_std_compliance = FF_COMPLIANCE_EXPERIMENTAL; // for native aac support
	/* put sample parameters */
    // this might cause warning but change this cause file can't play on mac with qucik time
	codecContext->sample_fmt  = AV_SAMPLE_FMT_FLT;
    codecContext->profile = FF_PROFILE_AAC_LOW;
	codecContext->time_base.den = 44100;
	codecContext->time_base.num = 1;
    codecContext->channel_layout = AV_CH_LAYOUT_STEREO;
    codecContext->bit_rate = 64 * 1000;
	//c->bit_rate    = bit_rate;
	codecContext->sample_rate = sampleRate;
	codecContext->channels    = 2;
    self.stream->time_base  = codecContext->time_base;
	//NSLog(@"addAudioStream sample_rate %d index %d", codecContext->sample_rate, self.stream->index);
	//LOGI("add_audio_stream parameters: sample_fmt: %d bit_rate: %d sample_rate: %d", codec_audio_sample_fmt, bit_rate, audio_sample_rate);
	// some formats want stream headers to be separate
	if (self.parentFile.formatContext->oformat->flags & AVFMT_GLOBALHEADER)
		codecContext->flags |= CODEC_FLAG_GLOBAL_HEADER;
    
    int ret = avcodec_open2(self.stream->codec, codec, NULL);
    if (ret < 0)
        NSLog(@"Could not open audio codec! error %@", [FFUtilities errorForAVError:ret]);
}

@end