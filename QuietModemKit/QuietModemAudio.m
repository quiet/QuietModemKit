#import "QuietModemAudio.h"

void convert_stereo2mono(const audio_sample_t *stereo_buf, float *mono_f,
                         size_t num_frames, unsigned int num_channels) {
  for (size_t i = 0; i < num_frames; i++) {
    // just skip every other sample e.g. ignore samples from right channel
    mono_f[i] = stereo_buf[i * num_channels];
  }
}

void convert_mono2stereo(const float *mono_f, audio_sample_t *stereo_buf,
                         size_t num_frames) {
  for (size_t i = 0; i < num_frames; i++) {
    float temp = mono_f[i];
    temp = (temp > 1.0f) ? 1.0f : temp;
    temp = (temp < -1.0f) ? -1.0f : temp;
    // just skip every other sample e.g. leave the right channel empty
    stereo_buf[i * num_playback_channels] = temp;
  }
}

void sum_mono2stereo(const float *mono_f, audio_sample_t *stereo_buf,
                     size_t num_frames) {
  for (size_t i = 0; i < num_frames; i++) {
    float temp = mono_f[i];
    temp = (temp > 1.0f) ? 1.0f : temp;
    temp = (temp < -1.0f) ? -1.0f : temp;
    // just skip every other sample e.g. leave the right channel empty
    stereo_buf[i * num_playback_channels] += temp;
  }
}
