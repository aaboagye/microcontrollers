#ifndef WAV_H_
#define WAV_H_

#include "types.h"

typedef struct{
    uint8_t artist[32];
    uint8_t title[32];
    uint32_t chunkID;
    uint32_t chunkSize;
    uint32_t format;
    uint32_t subchunk1ID;
    uint32_t subchunk1Size;
    uint16_t audioFormat;
    uint16_t numChannels;
    uint32_t sampleRate;
    uint32_t byteRate;
    uint16_t blockAlign;
    uint16_t bitsPerSample;
    uint32_t subchunk2ID;
    uint32_t subchunk2Size;
} wav_header;
#endif
