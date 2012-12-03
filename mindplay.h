#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>
#include <string.h>
#include <unistd.h>
#include <math.h>

#include <curl/curl.h>
#include <jansson.h>  /* Can be installed with homebrew on OSX. */

#define MP_URLLEN 256
#define MP_IDLEN 128
#define MP_NREQ 4
#define MP_BUFSIZE 1024


/* Define structure to hold partial and complete server response. */
typedef struct {
  char buffer[MP_BUFSIZE];
  size_t size;
  bool ready;
  CURL *parent; /* Used to link response and handle after transfer. */
} mp_response_t;


/* Structure to hold server state. */
typedef struct {
  char api_url[MP_URLLEN], user_id[MP_IDLEN], stream_id[MP_IDLEN];
  CURLM *multi_handle;
  mp_response_t *responses[MP_NREQ];
} mp_api_t;


void mp_init(mp_api_t *mp, const char *api_url, const char *user_id,
             const char *stream_id);
mp_response_t *mp_request_detection(mp_api_t *mp);
void mp_update(mp_api_t *mp);
int mp_detection(const mp_response_t *response, const char *detector_name, float *probability);
int mp_response_destroy(mp_api_t *mp, mp_response_t *response);
void mp_destroy(mp_api_t *mp);
