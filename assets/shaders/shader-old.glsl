#ifdef VERTEX
	//attribute vec4 v_position;
	#define v_position vertex_position

	attribute vec3 v_normal;
	attribute vec2 v_coord;

	attribute vec4 v_bone;
	attribute vec4 v_weight;
#endif

varying vec3 f_position;
varying vec3 f_normal;
varying vec2 f_uv;

#ifdef VERTEX
	uniform mat4	u_projection;
	uniform mat4	u_view;
	uniform mat4	u_model;

	uniform mat4	u_bone_matrices[200];
	uniform int		u_skinning = 0;

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

	mat3 getNormalMatrix(in mat4 deform_matrix) {
		return mat3(deform_matrix * u_model);
	}

	vec4 position(mat4 transform_projection, vec4 vertex_position)
	{
		mat4 deform_matrix = getDeformMatrix();
		vec4 f_position4 = u_view * u_model * deform_matrix * v_position;
		f_normal = getNormalMatrix(deform_matrix) * normalize(v_normal);
		f_position = vec3(f_position4) / f_position4.w;
		f_uv = v_coord;

		return u_projection * f_position4;
	}
#endif

#ifdef PIXEL
	uniform int		u_shading = 2; // MTL shading mode
	uniform int		u_texturing = 0;

	uniform vec3	u_Ka = vec3(0.225, 0.25, 0.3);
	uniform vec3	u_Kd = vec3(1.1, 1.0, 0.9);
	uniform vec3	u_Ks = vec3(0.25, 0.25, 0.25);
	uniform float	u_Ns = 20.0;

	uniform sampler2D u_map_Kd;

	const vec3 lightPos1 = vec3(100.0, -30.0, 20.0);
	const vec3 lightColor1 = vec3(0.8, 0.9, 1.0) * 1.0;

	const vec3 lightPos2 = vec3(-80.0, 60.0, -60.0);
	const vec3 lightColor2 = vec3(1.0, 0.5, 0.6) * 0.25;

	vec3 correct_gamma(in vec3 color) {
		const float gamma = 2.2;
		return pow(color, vec3(1.0 / gamma));
	}

	vec3 light_color(in vec3 normal, in vec3 lightPos, in vec3 lightColor) {
		vec3 lightDir = normalize(lightPos - f_position);
		float lambertian = max(dot(lightDir,normal), 0.0);
		vec3 out_color = vec3(0.0);

		if(lambertian > 0.0 && length(u_Ks) > 0.0) {
			vec3 viewDir = normalize(-f_position);
			vec3 reflectDir = reflect(-lightDir, normal);
			float specAngle = max(dot(reflectDir, viewDir), 0.0);
			out_color += pow(specAngle, u_Ns) * u_Ks;
		}

		out_color += lambertian * lightColor;

		return out_color;
	}

	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
		vec3 Kd = texture2D(u_map_Kd, f_uv).rgb;

		// Handle shadeless modes.
		if (u_shading < 2) {
			if (u_shading == 0) return vec4(Kd, 1.0);
			if (u_shading == 1) return vec4(Kd + u_Ka, 1.0);
		}

		// Illum 2 (phong)
		vec3 normal = normalize(f_normal);

		vec3 out_color = u_Ka;
		out_color += light_color(normal, lightPos1, lightColor1);
		out_color += light_color(normal, lightPos2, lightColor2);
		out_color *= u_Kd;
		out_color *= Kd;

		return vec4(correct_gamma(out_color), 1.0);
	}
#endif
