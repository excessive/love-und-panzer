#ifdef VERTEX
	//attribute vec4 v_position;
	#define v_position vertex_position

	attribute vec3 v_normal;

	attribute vec4 v_bone;
	attribute vec4 v_weight;

	uniform mat4	u_projection;
	uniform mat4	u_view;
	uniform mat4	u_model;

	// this is why I want UBOs...
	uniform mat4	u_bone_matrices[200];
	uniform int		u_skinning = 0;

	uniform float	u_thickness = 5.0;

	mat4 getDeformMatrix() {
		if (u_skinning != 0) {
			return u_bone_matrices[int(v_bone.x)] * v_weight.x +
				   u_bone_matrices[int(v_bone.y)] * v_weight.y +
				   u_bone_matrices[int(v_bone.z)] * v_weight.z +
				   u_bone_matrices[int(v_bone.w)] * v_weight.w;
		} else {
			return mat4(1.0);
		}
	}

	vec4 position(mat4 transform_projection, vec4 vertex_position) {
		vec4 position = vec4(v_position.xyz + v_normal * u_thickness, v_position.w);
		return u_projection * u_view * u_model * getDeformMatrix() * position;
	}
#endif

#ifdef PIXEL
	uniform vec3 u_outline_color = vec3(1.0, 0.0, 0.0);

	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
		vec4 out_color = vec4(u_outline_color, 1.0);
		out_color.a = dot(out_color.rgb, vec3(0.299, 0.587, 0.114)); // for FXAA
		return out_color;
	}
#endif
