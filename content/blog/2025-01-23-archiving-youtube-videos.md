+++
title = "Archiving YouTube Videos"
slug = "archiving-youtube-videos"
date = 2025-01-23

[extra]
author = "Tom Carrio"

[taxonomies]
tags = ["backup", "nix", "youtube"]
+++

It all started with a wedding. You hire a videographer, you wait patiently for several weeks, and finally your video is available. It's hosted on YouTube, quick and easy to start watching right away! However I can never know if this precious video may disappear, if their account may get deleted, or some other event may occur that causes such an important moment in our lives to disappear. This post provides a straightforward solution to archiving YouTube videos, in my case with a focus on retaining as high of quality as possible.

## Downloading content from YouTube

We are not pirating content, and have permission from our videographer to store this video. I may even have an external hard drive sitting around with it. But who wants to risk that breaking or disappearing? There is an existing open source project for downloading videos from YouTube and other sites called [**yt-dlp**](https://github.com/yt-dlp/yt-dlp). This works perfectly for our scenario.

Without diving too deep into the specifics, there are many formats of content available from YouTube even for a single "video". Each video on YouTube can be accessed at various resolutions and audio qualities. We start off by listing what is available with the following command:

`yt-dlp --list-formats 'https://www.youtube.com/watch?v=deadbeef'`

This will output a table with the available audio and video formats for the YouTube video. It is not uncommon for the formats to be completely separate, as in you have audio-only and video-only formats. We will cover the steps necessary for this scenario.

Let's suppose the output from the command looked something like this:

```
ID  EXT   RESOLUTION FPS CH │   FILESIZE    TBR PROTO │ VCODEC           VBR ACODEC      ABR ASR MORE INFO
───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
sb2 mhtml 48x27        0    │                   mhtml │ images                                   storyboard
sb1 mhtml 80x45        0    │                   mhtml │ images                                   storyboard
sb0 mhtml 160x90       0    │                   mhtml │ images                                   storyboard
233 mp4   audio only        │                   m3u8  │ audio only           unknown             [en] Default
234 mp4   audio only        │                   m3u8  │ audio only           unknown             [en] Default
139 m4a   audio only      2 │    2.12MiB    49k https │ audio only           mp4a.40.5   49k 22k [en] low, m4a_dash
249 webm  audio only      2 │    2.16MiB    50k https │ audio only           opus        50k 48k [en] low, webm_dash
250 webm  audio only      2 │    2.87MiB    66k https │ audio only           opus        66k 48k [en] low, webm_dash
140 m4a   audio only      2 │    5.63MiB   129k https │ audio only           mp4a.40.2  129k 44k [en] medium, m4a_dash
251 webm  audio only      2 │    5.64MiB   130k https │ audio only           opus       130k 48k [en] medium, webm_dash
602 mp4   256x144     12    │ ~  4.00MiB    92k m3u8  │ vp09.00.10.08    92k video only
269 mp4   256x144     24    │ ~  7.76MiB   179k m3u8  │ avc1.4D400C     179k video only
160 mp4   256x144     24    │    3.53MiB    81k https │ avc1.4D400C      81k video only          144p, mp4_dash
603 mp4   256x144     24    │ ~  7.32MiB   169k m3u8  │ vp09.00.11.08   169k video only
278 webm  256x144     24    │    3.71MiB    85k https │ vp09.00.11.08    85k video only          144p, webm_dash
229 mp4   426x240     24    │ ~ 13.83MiB   319k m3u8  │ avc1.4D4015     319k video only
133 mp4   426x240     24    │    7.99MiB   184k https │ avc1.4D4015     184k video only          240p, mp4_dash
604 mp4   426x240     24    │ ~ 13.51MiB   311k m3u8  │ vp09.00.20.08   311k video only
242 webm  426x240     24    │    6.30MiB   145k https │ vp09.00.20.08   145k video only          240p, webm_dash
230 mp4   640x360     24    │ ~ 31.52MiB   726k m3u8  │ avc1.4D401E     726k video only
134 mp4   640x360     24    │   15.18MiB   349k https │ avc1.4D401E     349k video only          360p, mp4_dash
605 mp4   640x360     24    │ ~ 26.07MiB   601k m3u8  │ vp09.00.21.08   601k video only
243 webm  640x360     24    │   10.97MiB   253k https │ vp09.00.21.08   253k video only          360p, webm_dash
231 mp4   854x480     24    │ ~ 58.71MiB  1353k m3u8  │ avc1.4D401E    1353k video only
135 mp4   854x480     24    │   31.68MiB   729k https │ avc1.4D401E     729k video only          480p, mp4_dash
606 mp4   854x480     24    │ ~ 41.26MiB   951k m3u8  │ vp09.00.30.08   951k video only
244 webm  854x480     24    │   18.21MiB   419k https │ vp09.00.30.08   419k video only          480p, webm_dash
232 mp4   1280x720    24    │ ~106.77MiB  2460k m3u8  │ avc1.64001F    2460k video only
136 mp4   1280x720    24    │   61.14MiB  1408k https │ avc1.64001F    1408k video only          720p, mp4_dash
609 mp4   1280x720    24    │ ~ 76.00MiB  1752k m3u8  │ vp09.00.31.08  1752k video only
247 webm  1280x720    24    │   32.92MiB   758k https │ vp09.00.31.08   758k video only          720p, webm_dash
270 mp4   1920x1080   24    │ ~215.93MiB  4976k m3u8  │ avc1.640028    4976k video only
137 mp4   1920x1080   24    │  115.89MiB  2668k https │ avc1.640028    2668k video only          1080p, mp4_dash
614 mp4   1920x1080   24    │ ~124.34MiB  2865k m3u8  │ vp09.00.40.08  2865k video only
248 webm  1920x1080   24    │   56.64MiB  1304k https │ vp09.00.40.08  1304k video only          1080p, webm_dash
620 mp4   2560x1440   24    │ ~352.28MiB  8118k m3u8  │ vp09.00.50.08  8118k video only
271 webm  2560x1440   24    │  172.62MiB  3974k https │ vp09.00.50.08  3974k video only          1440p, webm_dash
625 mp4   3840x2160   24    │ ~634.40MiB 14620k m3u8  │ vp09.00.50.08 14620k video only
313 webm  3840x2160   24    │  332.22MiB  7649k https │ vp09.00.50.08  7649k video only          2160p, webm_dash
```

There are video resolutions of 320p, 480p, 720p, etc. all the way to 2160p (4K). Additionally, there are multiple audio options available, with some useful information providing a high-level quality such as "low" and "medium". In my case, I will prefer the highest quality available for both audio and video, and make some preferential decisions on the formats. Let's go with the Opus audio codec in medium-quality and WebM video format in 2160p, or format IDs **251** and **313** respectively.

I will use **yt-dlp** to download each of these formats to separate files before joining them together.

```
# download the audio file
yt-dlp -f 251 -o wedding.audio.webm 'https://www.youtube.com/watch?v=deadbeef'

# download the video file
yt-dlp -f 313 -o cwedding.video.webm 'https://www.youtube.com/watch?v=deadbeef'
```

These are both saved to WebM files, as it is only a container format that supports various video and audio formats within itself. With both files downloaded, our next task will be to join the two files together into a single, 4K AV file.

## Splicing our audio and video together

A renowned tool for working with audio and video files is [**ffmpeg**](https://ffmpeg.org/). We will use this to pull the audio from the audio-only WebM file and the video from the video-only WebM file. The command we will run for this is:

```
ffmpeg \
  -i wedding.video.webm \
  -i wedding.audio.webm \
  -c:v copy \
  -c:a copy \
  -map 0:v:0 \
  -map 1:a:0 \
  carrio-wedding.webm
```

I split out the lines mostly for readability, as the command becomes more self-describing to me with this logical grouping.

We take two input files, first the video and then the audio file.

We copy over any video and audio codecs as in- no transcoding will be performed. This retains the Opus audio codec and the VP9 video codec used in these files.

We provide two mappings which dictate explicitly video and audio. For the first video (0, in a zero-index tool like ffmpeg), which had the video, we will pull the video. For the second video (1), which had the audio, we will pull the audio. The target for both is 0, the output file.

Lastly, we tell **ffmpeg** where to save the video: at `wedding.webm`.

Since there was no transcoding necessary for this, the operation should complete _very_ quickly. In my case: 468ms.

## Verifying your content

Load your content in a compatible video player for your content! If you decided to go with WebM & Opus and targeted a high resolution like 4K, make sure you use a hardware-accelerated tool. You can also upload your content to something like Google Drive and the web player in the preview tool should automatically work for playback as well. In my case, I loaded up [**mpv**](https://mpv.io/) to watch this beautiful moment as it included the necessary hardware acceleration libraries for my system to playback 4K content.

```
nix-shell -p mpv --run 'mpv ./wedding.webm'
```

![mpv playback of retrieving Anduril during wedding ceremony ](https://0xc.carrio.dev/media/posts/21/wedding-screenshot-0.png)