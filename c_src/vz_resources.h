#ifndef VZ_RESOURCES_H_INCLUDED
#define VZ_RESOURCES_H_INCLUDED

#include "vz_events.h"
#include "vz_helpers.h"

#include "pugl/pugl.h"
#include "nanovg.h"

#include <erl_nif.h>
#include <time.h>

#define VZ_MAX_STRING_LENGTH 255
#define VZ_VSYNC -1

enum VZredraw_mode {
  VZ_INTERVAL,
  VZ_MANUAL
};

enum VZdraw_image_mode {
  VZ_KEEP_ASPECT_RATIO,
  VZ_FILL
};

typedef struct VZview VZview;

typedef ERL_NIF_TERM VZev;
typedef void* VZres;

typedef struct VZop {
  void (*handler)(VZview*, void*);
  void *args;
} VZop;

VZ_ARRAY_DECLARE(VZop)
VZ_ARRAY_DECLARE(VZev)
VZ_ARRAY_DECLARE(VZres)
VZ_ARRAY_DECLARE(double)

/*
  View resource
*/
struct VZview {
  VZop_array *op_array;
  VZev_array *ev_array;
  VZres_array *res_array[2];
  unsigned res_ndx;
  ErlNifTid view_tid;
  ErlNifPid view_pid;
  PuglNativeWindow parent;
  PuglView *view;
  NVGcontext* ctx;
  ErlNifEnv *msg_env;
  ErlNifEnv *ev_env;
  ErlNifCond *execute_cv;
  ErlNifCond *suspended_cv;
  ErlNifMutex *lock;
  const char *id;
  bool busy;
  bool shutdown;
  bool suspend;
  bool resizable;
  bool force_send_events;
  int width;
  int height;
  int init_width;
  int init_height;
  int min_width;
  int min_height;
  double width_factor;
  double height_factor;
  enum VZredraw_mode redraw_mode;
  int frame_rate;
  bool vsync;
  double pixel_ratio;
  NVGcolor bg;
  float xform[6];
  char title[VZ_MAX_STRING_LENGTH];
};

extern ErlNifResourceType *vz_view_res;
VZview* vz_alloc_view(ErlNifEnv* env);
void vz_view_dtor(ErlNifEnv *env, void *resource);


/*
  Priv data
*/

typedef struct VZpriv {
  unsigned view_id_counter;
} VZpriv;

VZpriv* vz_alloc_priv();
void vz_free_priv(VZpriv *priv);
char* vz_priv_new_view_id(VZpriv *priv);


/*
  Canvas resource
*/
typedef struct VZcanvas {
  VZview *view;
  double x, y;
  double width, height;
  float xform[6];
} VZcanvas;

extern ErlNifResourceType *vz_canvas_res;
VZcanvas* vz_alloc_canvas(VZview *view);


/*
  Image resource
*/
typedef struct VZimage {
  int handle;
  VZview *view;
} VZimage;

extern ErlNifResourceType *vz_image_res;
VZimage* vz_alloc_image(VZview *view, int handle);
void vz_image_dtor(ErlNifEnv *env, void *resource);


/*
  Font resource
*/
typedef struct VZfont {
  int handle;
  char file_path[VZ_MAX_STRING_LENGTH];
  VZview *view;
} VZfont;

extern ErlNifResourceType *vz_font_res;
VZfont* vz_alloc_font(VZview *view, int handle, const char *file_path);


/*
  Paint resource
*/
extern ErlNifResourceType *vz_paint_res;
NVGpaint* vz_alloc_paint(NVGpaint src);

/*
  Matrix resource
*/
extern ErlNifResourceType *vz_matrix_res;
float* vz_alloc_matrix();
float* vz_alloc_matrix_copy(const float *src);

/*
  Bitmap resource
*/
typedef struct VZbitmap {
  unsigned char *buffer;
  int width;
  int height;
  int pixel_size;
  int byte_size;
} VZbitmap;

extern ErlNifResourceType *vz_bitmap_res;
VZbitmap* vz_alloc_bm(int width, int height);
VZbitmap* vz_alloc_bm_copy(const unsigned char *data, int width, int height);
void vz_bm_dtor(ErlNifEnv *env, void *resource);
bool vz_bm_get_slice(VZbitmap *bm, unsigned offset, unsigned length, unsigned char *data);
bool vz_bm_put_slice(VZbitmap *bm, unsigned offset, unsigned length, const unsigned char *data);

ERL_NIF_TERM vz_make_resource(ErlNifEnv* env, void* obj);
ERL_NIF_TERM vz_make_managed_resource(ErlNifEnv* env, void* obj, VZview *vz_view);
void vz_release_managed_resources(VZview *vz_view);

#endif