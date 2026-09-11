#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <avif/avif.h>

int main(void) {
    const avifCodecChoice encoders[] = { AVIF_CODEC_CHOICE_AOM, AVIF_CODEC_CHOICE_RAV1E, AVIF_CODEC_CHOICE_SVT };
    const avifCodecChoice decoders[] = { AVIF_CODEC_CHOICE_AOM, AVIF_CODEC_CHOICE_DAV1D };
    int e, d, p, y, x;
    avifImage *input = avifImageCreate(64, 64, 8, AVIF_PIXEL_FORMAT_YUV420);
    if (!input || avifImageAllocatePlanes(input, AVIF_PLANES_YUV) != AVIF_RESULT_OK) return 1;
    for (p = 0; p < 3; ++p) {
        int size = p == 0 ? 64 : 32;
        for (y = 0; y < size; ++y)
            memset(input->yuvPlanes[p] + y * input->yuvRowBytes[p], p == 0 ? 16 : 128, size);
    }
    for (e = 0; e < 3; ++e) {
        avifEncoder *encoder;
        avifRWData bytes = AVIF_DATA_EMPTY;
        if (!avifCodecName(encoders[e], AVIF_CODEC_FLAG_CAN_ENCODE)) return 2;
        encoder = avifEncoderCreate();
        if (!encoder) return 3;
        encoder->codecChoice = encoders[e];
        encoder->maxThreads = 1;
        encoder->speed = AVIF_SPEED_FASTEST;
        encoder->quality = 80;
        if (avifEncoderWrite(encoder, input, &bytes) != AVIF_RESULT_OK || bytes.size == 0) {
            fprintf(stderr, "Encoder failed: %s (%s)\n", avifCodecName(encoders[e], AVIF_CODEC_FLAG_CAN_ENCODE), encoder->diag.error);
            return 4;
        }
        for (d = 0; d < 2; ++d) {
            avifDecoder *decoder;
            avifImage *output = avifImageCreateEmpty();
            if (!avifCodecName(decoders[d], AVIF_CODEC_FLAG_CAN_DECODE)) return 5;
            decoder = avifDecoderCreate();
            if (!decoder || !output) return 6;
            decoder->codecChoice = decoders[d];
            decoder->maxThreads = 1;
            if (avifDecoderReadMemory(decoder, output, bytes.data, bytes.size) != AVIF_RESULT_OK
                || output->width != 64 || output->height != 64 || output->depth != 8
                || output->yuvFormat != AVIF_PIXEL_FORMAT_YUV420) return 7;
            for (p = 0; p < 3; ++p) {
                int size = p == 0 ? 64 : 32;
                int expected = p == 0 ? 16 : 128;
                if (!output->yuvPlanes[p]) return 8;
                for (y = 0; y < size; ++y)
                    for (x = 0; x < size; ++x)
                        if (abs(output->yuvPlanes[p][y*output->yuvRowBytes[p]+x] - expected) > 2) return 9;
            }
            printf("AVIF %s -> %s pixel round trip passed\n", avifCodecName(encoders[e], AVIF_CODEC_FLAG_CAN_ENCODE), avifCodecName(decoders[d], AVIF_CODEC_FLAG_CAN_DECODE));
            avifImageDestroy(output);
            avifDecoderDestroy(decoder);
        }
        avifRWDataFree(&bytes);
        avifEncoderDestroy(encoder);
    }
    avifImageDestroy(input);
    return 0;
}
