#import "LoopbackAudio.h"

#include <pthread.h>
#include <sys/time.h>

#include "quiet.h"

@implementation LoopbackAudio {
  pthread_mutex_t lock;
  pthread_t thread;

  id<QuietAudioProducer> __strong *producers;
  id<QuietAudioConsumer> __strong *consumers;

  size_t num_producers;
  size_t num_consumers;

  size_t producers_cap;
  size_t consumers_cap;

  bool is_closed;
}

const int loopback_sample_rate = 44100;
const int loopback_sleep = 23220; // in microseconds
const int loopback_buffer_length = 1024;

dispatch_once_t singletonOnce;
LoopbackAudio *singleton = NULL;

- (id)init {
  self = [super init];
  if (!self) {
    return nil;
  }

  pthread_mutex_init(&lock, NULL);

  producers_cap = 8;
  consumers_cap = 8;
  num_producers = 0;
  num_consumers = 0;

  producers = (id<QuietAudioProducer> __strong *)calloc(
      producers_cap, sizeof(id<QuietAudioProducer> __strong));
  consumers = (id<QuietAudioConsumer> __strong *)calloc(
      consumers_cap, sizeof(id<QuietAudioConsumer> __strong));

  is_closed = false;

  return self;
}

+ (void)setupSingleton {
  dispatch_once(&singletonOnce, ^{
    singleton = [[LoopbackAudio alloc] init];
    [singleton startThread];
  });
}

+ (void)addProducer:(id<QuietAudioProducer>)p {
  [LoopbackAudio setupSingleton];
  [singleton addProducer:p];
}

+ (void)addConsumer:(id<QuietAudioConsumer>)c {
  [LoopbackAudio setupSingleton];
  [singleton addConsumer:c];
}

+ (void)removeProducer:(id<QuietAudioProducer>)p {
  [LoopbackAudio setupSingleton];
  [singleton removeProducer:p];
}

+ (void)removeConsumer:(id<QuietAudioConsumer>)c {
  [LoopbackAudio setupSingleton];
  [singleton removeConsumer:c];
}

- (void)close {
  pthread_mutex_lock(&lock);
  is_closed = true;
  pthread_mutex_unlock(&lock);
}

- (void)dealloc {
  [self close];
  pthread_mutex_destroy(&lock);
  free(producers);
  free(consumers);
}

- (void)addProducerLocked:(id<QuietAudioProducer>)p {
  if (num_producers == producers_cap) {
    producers_cap *= 2;
    producers = (id<QuietAudioProducer> __strong *)realloc(
        producers, producers_cap * sizeof(id<QuietAudioProducer> __strong));
  }
  producers[num_producers] = p;
  num_producers++;
}

- (void)removeProducerLocked:(id<QuietAudioProducer>)p {
  for (size_t i = 0; i < num_producers; i++) {
    if (producers[i] == p) {
      producers[i] = NULL;
      for (size_t j = i + 1; j < num_producers; j++) {
        producers[j - 1] = producers[j];
      }
      num_producers--;
      break;
    }
  }
}

- (void)addConsumerLocked:(id<QuietAudioConsumer>)c {
  if (num_consumers == consumers_cap) {
    consumers_cap *= 2;
    consumers = (id<QuietAudioConsumer> __strong *)realloc(
        consumers, consumers_cap * sizeof(id<QuietAudioConsumer> __strong));
  }
  consumers[num_consumers] = c;
  num_consumers++;
}

- (void)removeConsumerLocked:(id<QuietAudioConsumer>)c {
  for (size_t i = 0; i < num_consumers; i++) {
    if (consumers[i] == c) {
      consumers[i] = NULL;
      for (size_t j = i + 1; j < num_consumers; j++) {
        consumers[j - 1] = consumers[j];
      }
      num_consumers--;
      break;
    }
  }
}

- (void)addProducer:(id<QuietAudioProducer>)p {
  pthread_mutex_lock(&lock);
  [self addProducerLocked:p];
  pthread_mutex_unlock(&lock);
}

- (void)removeProducer:(id<QuietAudioProducer>)p {
  pthread_mutex_lock(&lock);
  [self removeProducerLocked:p];
  pthread_mutex_unlock(&lock);
}

- (void)addConsumer:(id<QuietAudioConsumer>)c {
  pthread_mutex_lock(&lock);
  [self addConsumerLocked:c];
  pthread_mutex_unlock(&lock);
}

- (void)removeConsumer:(id<QuietAudioConsumer>)c {
  pthread_mutex_lock(&lock);
  [self removeConsumerLocked:c];
  pthread_mutex_unlock(&lock);
}

- (void)sumProducer:(id<QuietAudioProducer>)p
           withDest:(audio_sample_t *)dest
           withMono:(quiet_sample_t *)mono {
  ssize_t written =
      [p produceAudioToSamples:mono withLength:loopback_buffer_length];

  if (written == 0) {
    // EOF - this signals that the producer is done and should be removed
    // we use the locked version of this call since this sum is run
    // with the lock held
    [self removeProducerLocked:p];
  }

  if (written <= 0) {
    // 0: eof (handled above)
    // <0: no frames ready, but more could be later
    // in either case there's nothing left to do
    return;
  }

  sum_mono2stereo(mono, dest, written);
}

- (void)writeConsumer:(id<QuietAudioConsumer>)c
              withSrc:(audio_sample_t *)src
             withMono:(quiet_sample_t *)mono {
  convert_stereo2mono(src, mono, loopback_buffer_length, num_playback_channels);
  ssize_t read =
      [c consumeAudioFromSamples:mono withLength:loopback_buffer_length];

  if (read == 0) {
    [self removeConsumerLocked:c];
  }
}

- (void)run {
  struct timeval now, last_now;
  gettimeofday(&last_now, NULL);
  audio_sample_t *sample_stereo_buffer = malloc(
      loopback_buffer_length * num_playback_channels * sizeof(audio_sample_t));
  audio_sample_t *mono_buffer =
      malloc(loopback_buffer_length * sizeof(quiet_sample_t));
  while (true) {
    memset(sample_stereo_buffer, 0,
           loopback_buffer_length * num_playback_channels *
               sizeof(audio_sample_t));
    pthread_mutex_lock(&lock);

    if (is_closed) {
      pthread_mutex_unlock(&lock);
      break;
    }

    for (size_t i = 0; i < num_producers; i++) {
      [self sumProducer:producers[i]
               withDest:sample_stereo_buffer
               withMono:mono_buffer];
    }

    for (size_t i = 0; i < num_consumers; i++) {
      [self writeConsumer:consumers[i]
                  withSrc:sample_stereo_buffer
                 withMono:mono_buffer];
    }

    pthread_mutex_unlock(&lock);

    gettimeofday(&now, NULL);
    time_t elapsed = (now.tv_sec - last_now.tv_sec) * 1000000L;
    elapsed += (now.tv_usec - last_now.tv_usec);
    int sleep_length = (int)(loopback_sleep - elapsed);
    if (sleep_length > 0) {
      usleep(sleep_length);
    }
    // TODO consider else case here - maybe sleep less next time?
    // assuming we are staying caught up at all
    last_now = now;
  }
  free(sample_stereo_buffer);
  free(mono_buffer);
}

static void *runThread(void *inst) {
  LoopbackAudio *loopback = (__bridge id)inst;
  [loopback run];
  return NULL;
}

- (void)startThread {
  pthread_attr_t thread_attr;

  pthread_attr_init(&thread_attr);
  pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_JOINABLE);

  pthread_create(&thread, &thread_attr, runThread,
                 (__bridge void *_Nullable)self);

  pthread_attr_destroy(&thread_attr);
}

- (void)stopThread {
  [self close];
  pthread_join(thread, NULL);
}

@end
