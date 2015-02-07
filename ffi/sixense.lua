local ffi = require "ffi"
ffi.cdef([[
enum {
	SIXENSE_BUTTON_BUMPER   = 0x01 << 7,
	SIXENSE_BUTTON_JOYSTICK = 0x01 << 8,
	SIXENSE_BUTTON_1        = 0x01 << 5,
	SIXENSE_BUTTON_2        = 0x01 << 6,
	SIXENSE_BUTTON_3        = 0x01 << 3,
	SIXENSE_BUTTON_4        = 0x01 << 4,
	SIXENSE_BUTTON_START    = 0x01 << 0,
	SIXENSE_SUCCESS = 0,
	SIXENSE_FAILURE = -1,
	SIXENSE_MAX_CONTROLLERS = 4,
};

typedef struct _sixenseControllerData {
	float pos[3];
	float rot_mat[3][3];
	float joystick_x;
	float joystick_y;
	float trigger;
	unsigned int buttons;
	unsigned char sequence_number;
	float rot_quat[4];
	unsigned short firmware_revision;
	unsigned short hardware_revision;
	unsigned short packet_type;
	unsigned short magnetic_frequency;
	int enabled;
	int controller_index;
	unsigned char is_docked;
	unsigned char which_hand;
	unsigned char hemi_tracking_enabled;
} sixenseControllerData;

typedef struct _sixenseAllControllerData {
	sixenseControllerData controllers[4];
} sixenseAllControllerData;

__declspec(dllexport) int sixenseInit( void );
__declspec(dllexport) int sixenseExit( void );
__declspec(dllexport) int sixenseGetMaxBases();
__declspec(dllexport) int sixenseSetActiveBase( int i );
__declspec(dllexport) int sixenseIsBaseConnected( int i );
__declspec(dllexport) int sixenseGetMaxControllers( void );
__declspec(dllexport) int sixenseIsControllerEnabled( int which );
__declspec(dllexport) int sixenseGetNumActiveControllers();
__declspec(dllexport) int sixenseGetHistorySize();
__declspec(dllexport) int sixenseGetData( int which, int index_back, sixenseControllerData * );
__declspec(dllexport) int sixenseGetAllData( int index_back, sixenseAllControllerData * );
__declspec(dllexport) int sixenseGetNewestData( int which, sixenseControllerData * );
__declspec(dllexport) int sixenseGetAllNewestData( sixenseAllControllerData * );
__declspec(dllexport) int sixenseSetHemisphereTrackingMode( int which_controller, int state );
__declspec(dllexport) int sixenseGetHemisphereTrackingMode( int which_controller, int *state );
__declspec(dllexport) int sixenseAutoEnableHemisphereTracking( int which_controller );
__declspec(dllexport) int sixenseSetHighPriorityBindingEnabled( int on_or_off );
__declspec(dllexport) int sixenseGetHighPriorityBindingEnabled( int *on_or_off );
__declspec(dllexport) int sixenseTriggerVibration( int controller_id, int duration_100ms, int pattern_id );
__declspec(dllexport) int sixenseSetFilterEnabled( int on_or_off );
__declspec(dllexport) int sixenseGetFilterEnabled( int *on_or_off );
__declspec(dllexport) int sixenseSetFilterParams( float near_range, float near_val, float far_range, float far_val );
__declspec(dllexport) int sixenseGetFilterParams( float *near_range, float *near_val, float *far_range, float *far_val );

// These aren't useful for the Hydra.
__declspec(dllexport) int sixenseSetBaseColor( unsigned char red, unsigned char green, unsigned char blue );
__declspec(dllexport) int sixenseGetBaseColor( unsigned char *red, unsigned char *green, unsigned char *blue );
]])

local sixense = ffi.load("bin/sixense")

return sixense
