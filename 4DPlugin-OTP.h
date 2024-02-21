/* --------------------------------------------------------------------------------
 #
 #	4DPlugin-OTP.h
 #	source generated by 4D Plugin Wizard
 #	Project : OTP
 #	author : miyako
 #	2024/02/21
 #  
 # --------------------------------------------------------------------------------*/

#ifndef PLUGIN_OTP_H
#define PLUGIN_OTP_H

#include "4DPluginAPI.h"
#include "4DPlugin-JSON.h"

#include "base32.h"
#include "uri_encode.h"

#include "qrencode.h"
#include "png.h"

#include "C_BLOB.h"

#include <openssl/evp.h>
#include <openssl/hmac.h>
#include <openssl/rand.h>

#if defined(_WIN32)
#    include <sysinfoapi.h>
#else
#    include <sys/time.h>
#endif

#pragma mark -

void OTP_Generate(PA_PluginParameters params);
void OTP_Random(PA_PluginParameters params);

static const int    powers10[] = { 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000, 1000000000 };

#pragma mark QRCODE

#define INCHES_PER_METER (100.0/2.54)

enum output_type_t {
    QR_OUTPUT_PNG,
    QR_OUTPUT_SVG
};

#ifdef _WIN32
extern "C" { FILE __iob_func[3] = { *stdin,*stdout,*stderr }; }
#endif

static void toSVG(QRcode *qr, int margin, int size, int dpi, PA_ObjectRef o);
static void toPNG(QRcode *qr, int margin, int size, int dpi, PA_ObjectRef o);

void write_data_fn(png_structp png_ptr, png_bytep buf, png_size_t size);
void output_flush_fn(png_structp png_ptr);

#endif /* PLUGIN_OTP_H */
