/*
#ifdef VERTEX
#if __VERSION__ <= 120
	#define in attribute
	#define out varying
#endif
#else
	#define in varying
	#define out
#endif
//*/
#ifdef VERTEX
	//attribute vec4 VertexPosition;
	#define v_position VertexPosition

	uniform mat4	u_projection;
	uniform mat4	u_view;
	uniform mat4	u_model;

	vec4 position(mat4 transform_projection, vec4 vertex_position) {
		return u_projection * u_view * u_model * v_position;
	}
#endif

#ifdef PIXEL
	uniform vec4 u_color = vec4(1.0, 0.0, 1.0, 1.0);

	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
		return u_color;
	}
#endif
