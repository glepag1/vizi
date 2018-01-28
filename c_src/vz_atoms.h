#ifndef VZ_ATOMS_H_INCLUDED
#define VZ_ATOMS_H_INCLUDED

#include <erl_nif.h>


void vz_make_atoms(ErlNifEnv* env);

ERL_NIF_TERM ATOM_OK;
ERL_NIF_TERM ATOM_TRUE;
ERL_NIF_TERM ATOM_FALSE;
ERL_NIF_TERM ATOM_NIL;
ERL_NIF_TERM ATOM_BADARG;
ERL_NIF_TERM ATOM_PARENT;
ERL_NIF_TERM ATOM_WIDTH;
ERL_NIF_TERM ATOM_HEIGHT;
ERL_NIF_TERM ATOM_MIN_WIDTH;
ERL_NIF_TERM ATOM_MIN_HEIGHT;
ERL_NIF_TERM ATOM_RESIZABLE;
ERL_NIF_TERM ATOM_REDRAW_MODE;
ERL_NIF_TERM ATOM_RM_INTERVAL;
ERL_NIF_TERM ATOM_RM_MANUAL;
ERL_NIF_TERM ATOM_FRAME_RATE;
ERL_NIF_TERM ATOM_TITLE;
ERL_NIF_TERM ATOM_COLOR_STRUCT;
ERL_NIF_TERM ATOM_BACKGROUND_COLOR;
ERL_NIF_TERM ATOM_PIXEL_RATIO;
ERL_NIF_TERM ATOM_SHUTDOWN;
ERL_NIF_TERM ATOM_REPLY;
ERL_NIF_TERM ATOM_UPDATE;
ERL_NIF_TERM ATOM_EVENT;
ERL_NIF_TERM ATOM_INITIALIZED;

ERL_NIF_TERM ATOM__STRUCT__;
ERL_NIF_TERM ATOM_CONTEXT;
ERL_NIF_TERM ATOM_R;
ERL_NIF_TERM ATOM_G;
ERL_NIF_TERM ATOM_B;
ERL_NIF_TERM ATOM_A;
ERL_NIF_TERM ATOM_TYPE;
ERL_NIF_TERM ATOM_TIME;
ERL_NIF_TERM ATOM_X;
ERL_NIF_TERM ATOM_Y;
ERL_NIF_TERM ATOM_ABS_X;
ERL_NIF_TERM ATOM_ABS_Y;
ERL_NIF_TERM ATOM_X_ROOT;
ERL_NIF_TERM ATOM_Y_ROOT;
ERL_NIF_TERM ATOM_STATE;
ERL_NIF_TERM ATOM_BUTTON;
ERL_NIF_TERM ATOM_COUNT;
ERL_NIF_TERM ATOM_KEYCODE;
ERL_NIF_TERM ATOM_CHARACTER;
ERL_NIF_TERM ATOM_SPECIAL;
ERL_NIF_TERM ATOM_UTF8;
ERL_NIF_TERM ATOM_FILTER;
ERL_NIF_TERM ATOM_MODE;
ERL_NIF_TERM ATOM_IS_HINT;
ERL_NIF_TERM ATOM_FOCUS;
ERL_NIF_TERM ATOM_DX;
ERL_NIF_TERM ATOM_DY;
ERL_NIF_TERM ATOM_NORMAL;
ERL_NIF_TERM ATOM_GRAB;
ERL_NIF_TERM ATOM_UNGRAB;
ERL_NIF_TERM ATOM_SCALE_X;
ERL_NIF_TERM ATOM_SCALE_Y;
ERL_NIF_TERM ATOM_SKEW_X;
ERL_NIF_TERM ATOM_SKEW_Y;
ERL_NIF_TERM ATOM_ROTATE;
ERL_NIF_TERM ATOM_ALPHA;
ERL_NIF_TERM ATOM_XFORM;
ERL_NIF_TERM ATOM_KEEP_ASPECT_RATIO;
ERL_NIF_TERM ATOM_FILL;


ERL_NIF_TERM ATOM_F1;
ERL_NIF_TERM ATOM_F2;
ERL_NIF_TERM ATOM_F3;
ERL_NIF_TERM ATOM_F4;
ERL_NIF_TERM ATOM_F5;
ERL_NIF_TERM ATOM_F6;
ERL_NIF_TERM ATOM_F7;
ERL_NIF_TERM ATOM_F8;
ERL_NIF_TERM ATOM_F9;
ERL_NIF_TERM ATOM_F10;
ERL_NIF_TERM ATOM_F11;
ERL_NIF_TERM ATOM_F12;
ERL_NIF_TERM ATOM_LEFT;
ERL_NIF_TERM ATOM_UP;
ERL_NIF_TERM ATOM_RIGHT;
ERL_NIF_TERM ATOM_DOWN;
ERL_NIF_TERM ATOM_PAGE_UP;
ERL_NIF_TERM ATOM_PAGE_DOWN;
ERL_NIF_TERM ATOM_HOME;
ERL_NIF_TERM ATOM_END;
ERL_NIF_TERM ATOM_INSERT;
ERL_NIF_TERM ATOM_SHIFT;
ERL_NIF_TERM ATOM_CTRL;
ERL_NIF_TERM ATOM_ALT;
ERL_NIF_TERM ATOM_SUPER;

ERL_NIF_TERM ATOM_BUTTON_EVENT;
ERL_NIF_TERM ATOM_CONFIGURE_EVENT;
ERL_NIF_TERM ATOM_EXPOSE_EVENT;
ERL_NIF_TERM ATOM_CLOSE_EVENT;
ERL_NIF_TERM ATOM_KEY_EVENT;
ERL_NIF_TERM ATOM_CROSSING_EVENT;
ERL_NIF_TERM ATOM_MOTION_EVENT;
ERL_NIF_TERM ATOM_SCROLL_EVENT;
ERL_NIF_TERM ATOM_FOCUS_EVENT;
ERL_NIF_TERM ATOM_UPDATE_EVENT;

ERL_NIF_TERM ATOM_BUTTON_PRESS_EVENT_TYPE;
ERL_NIF_TERM ATOM_BUTTON_RELEASE_EVENT_TYPE;
ERL_NIF_TERM ATOM_CONFIGURE_EVENT_TYPE;
ERL_NIF_TERM ATOM_EXPOSE_EVENT_TYPE;
ERL_NIF_TERM ATOM_CLOSE_EVENT_TYPE;
ERL_NIF_TERM ATOM_KEY_PRESS_EVENT_TYPE;
ERL_NIF_TERM ATOM_KEY_RELEASE_EVENT_TYPE;
ERL_NIF_TERM ATOM_ENTER_MOTION_EVENT_TYPE;
ERL_NIF_TERM ATOM_LEAVE_MOTION_EVENT_TYPE;
ERL_NIF_TERM ATOM_MOTION_EVENT_TYPE;
ERL_NIF_TERM ATOM_SCROLL_EVENT_TYPE;
ERL_NIF_TERM ATOM_FOCUS_IN_EVENT_TYPE;
ERL_NIF_TERM ATOM_FOCUS_OUT_EVENT_TYPE;
ERL_NIF_TERM ATOM_UPDATE_EVENT_TYPE;

ERL_NIF_TERM ATOM_CCW;
ERL_NIF_TERM ATOM_CW;

ERL_NIF_TERM ATOM_SOLID;
ERL_NIF_TERM ATOM_HOLE;

ERL_NIF_TERM ATOM_BUTT;
ERL_NIF_TERM ATOM_ROUND;
ERL_NIF_TERM ATOM_SQUARE;
ERL_NIF_TERM ATOM_BEVEL;
ERL_NIF_TERM ATOM_MITER;

ERL_NIF_TERM ATOM_LEFT;
ERL_NIF_TERM ATOM_CENTER;
ERL_NIF_TERM ATOM_RIGHT;
ERL_NIF_TERM ATOM_TOP;
ERL_NIF_TERM ATOM_MIDDLE;
ERL_NIF_TERM ATOM_BOTTOM;
ERL_NIF_TERM ATOM_BASELINE;

ERL_NIF_TERM ATOM_ZERO;
ERL_NIF_TERM ATOM_ONE;
ERL_NIF_TERM ATOM_SRC_COLOR;
ERL_NIF_TERM ATOM_ONE_MINUS_SRC_COLOR;
ERL_NIF_TERM ATOM_DST_COLOR;
ERL_NIF_TERM ATOM_ONE_MINUS_DST_COLOR;
ERL_NIF_TERM ATOM_SRC_ALPHA;
ERL_NIF_TERM ATOM_ONE_MINUS_SRC_ALPHA;
ERL_NIF_TERM ATOM_DST_ALPHA;
ERL_NIF_TERM ATOM_ONE_MINUS_DST_ALPHA;
ERL_NIF_TERM ATOM_SRC_ALPHA_SATURATE;

ERL_NIF_TERM ATOM_SOURCE_OVER;
ERL_NIF_TERM ATOM_SOURCE_IN;
ERL_NIF_TERM ATOM_SOURCE_OUT;
ERL_NIF_TERM ATOM_ATOP;
ERL_NIF_TERM ATOM_DESTINATION_OVER;
ERL_NIF_TERM ATOM_DESTINATION_IN;
ERL_NIF_TERM ATOM_DESTINATION_OUT;
ERL_NIF_TERM ATOM_DESTINATION_ATOP;
ERL_NIF_TERM ATOM_LIGHTER;
ERL_NIF_TERM ATOM_COPY;
ERL_NIF_TERM ATOM_XOR;

ERL_NIF_TERM ATOM_GENERATE_MIPMAPS;
ERL_NIF_TERM ATOM_REPEAT_X;
ERL_NIF_TERM ATOM_REPEAT_Y;
ERL_NIF_TERM ATOM_FLIP_Y;
ERL_NIF_TERM ATOM_PREMULTIPLIED;
ERL_NIF_TERM ATOM_NEAREST;



#endif