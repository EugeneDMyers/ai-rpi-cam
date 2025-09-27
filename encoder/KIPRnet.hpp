

#pragma once

#include "core/rpicam_app.hpp"
#include "core/rpicam_encoder.hpp"

#include "core/stream_info.hpp"
#include "core/video_options.hpp"

extern "C"
{
#include "libavcodec/avcodec.h"
#include "libavcodec/codec_desc.h"
#include "libavdevice/avdevice.h"
#include "libavformat/avformat.h"
#include "libavutil/audio_fifo.h"
#include "libavutil/hwcontext.h"
#include "libavutil/hwcontext_drm.h"
#include "libavutil/imgutils.h"
#include "libavutil/timestamp.h"
#include "libavutil/version.h"
#include "libswresample/swresample.h"
}


class KIPRnet : public RPiCamEncoder
{
public:
	 KIPRnet();
	 ~KIPRnet();

	int set_video_output(int setting) {video_output = setting; return video_output;};
	bool KIPRencode(CompletedRequestPtr &completed_request, Stream *stream);
	int header_count;

	struct header_buf
	{
		int header_seq;
		char * buffer;
		int length;
	};

        void EncodeBuffer(int fd, size_t size, void *mem, StreamInfo const &info, int64_t timestamp_us, struct header_buf *);


private:

	void videoThread();
	void deinitOutput();

	std::thread video_thread_;
	std::mutex  video_mutex_;
	std::queue<AVFrame *> frame_queue_;
	std::queue<header_buf *> header_queue_;
	std::condition_variable video_cv_;
	bool abort_video_;
	uint64_t video_start_ts_;
        enum Context { Video = 0, AudioOut = 1, AudioIn = 2 };

	AVCodecContext *codec_ctx_[3];
        static void releaseBuffer(void *opaque, uint8_t *data);

	int video_output = 1;
	VideoOptions options_;

};

#define MAX_NAME_LEN 16

struct object_detection
{
	int category;
	int name_len;
	char name[MAX_NAME_LEN];
	float confidence;
	struct box
	{
		float x;
		float width;
		float y;
		float height;
	} box;
};


