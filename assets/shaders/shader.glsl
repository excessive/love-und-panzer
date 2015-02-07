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
varying vec2 f_uv_reflect;

#ifdef VERTEX
	uniform mat4	u_projection;
	uniform mat4	u_model;
	uniform mat4	u_view;

	// this is why I want UBOs...
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

	vec4 position(mat4 transform_projection, vec4 vertex_position) {
		mat4 deform_matrix = getDeformMatrix();
		vec4 f_position4 = u_view * u_model * deform_matrix * v_position;
		f_normal = getNormalMatrix(deform_matrix) * normalize(v_normal);

		f_position = vec3(f_position4) / f_position4.w;

		f_uv = v_coord;

		// This is confirmed fucked up on AMD 7970 - not sure what's up.
		vec3 e = normalize(f_position);
		vec3 n = normalize(getNormalMatrix(deform_matrix * u_view) * v_normal);
		vec3 r = reflect(e, n);
		float m = 2.0 * sqrt( 
			pow(r.x, 2.0) +
			pow(r.y, 2.0) +
			pow(r.z + 1.0, 2.0)
		);
		f_uv_reflect = - r.xy / m + 0.5;
		f_uv_reflect.x *= -1.0;

		return u_projection * f_position4;
	}
#endif

#ifdef PIXEL
	uniform vec3	u_Ka = vec3(0.0);
	uniform vec3	u_Kd = vec3(0.10);
	uniform vec3	u_Ks = vec3(0.30);
	uniform float	u_Ns = 50.0;
	uniform int		u_shading = 2;

	uniform sampler2D u_map_Kd;

	// Non-standard shit
	uniform vec3	u_Kr = vec3(0.0);
	uniform float	u_Ne = 1.25; // fresnel exponent
	uniform float	u_Nf = 0.0; // fresnel strength

	uniform sampler2D u_map_Kr;

	uniform float u_gamma = 2.2;

	uniform float u_light_power = 1.0;

	const vec3 lightPos1 = vec3(100.0, -30.0, 20.0);
	const vec3 lightColor1 = vec3(0.8, 0.9, 1.0) * 4.25;

	const vec3 lightPos2 = vec3(-80.0, 60.0, -60.0);
	const vec3 lightColor2 = vec3(1.0, 0.5, 0.6) * 1.0;

	const vec3 sky_light = vec3(0.0, 0.0, -1.0);
	const vec3 sky_light_color = vec3(0.25, 0.5, 0.75) * 0.5;

	const float near = 5.00;
	const float far = 2500.0;

	const vec3 sky_color = vec3(0.3, 0.6, 1.0);


	vec3 light_color(in vec3 normal, in vec3 lightPos, in vec3 lightColor) {
		// float dist = length(lightPos - f_position);
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

	vec4 shade(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
		vec3 normal = normalize(f_normal);

		// Make sure that the total reflection of the material is <= 1.0
		// Ambient doesn't count because it's fake as hell anyway.
		// float conserve = 1.0 / -min(1.0 - (length(u_Kd) + length(u_Ks) + length(u_Kr)), 0.0001);
		float conserve = 1.0;
		float fresnel = clamp(pow(1.0 - dot(vec3(1.0, 0.0, 0.0), f_normal), u_Ne), 0.0, 1.0) * u_Nf;

		vec3 Kd = texture2D(u_map_Kd, f_uv).rgb;

		if (u_shading != 2) {
			// Diffuse map + reflection
			if (u_shading == 0) return vec4(Kd + texture2D(u_map_Kr, f_uv_reflect).rgb * (u_Kr + fresnel), 1.0);

			// Diffuse map + ambient
			if (u_shading == 1) return vec4(Kd + u_Ka, 1.0);

			// Matcap passthrough. Don't bother correcting gamma on these things, it just looks weird.
			if (u_shading == 3) return vec4(texture2D(u_map_Kr, f_uv_reflect).rgb, 1.0);
		}

		Kd *= u_Kd;

		float depth = 1.0 / gl_FragCoord.w;
		float scaled = (depth - near) / (far - near);

		vec3 out_color = vec3(0.0);
		// out_color += sky_light_color * dot(normal, sky_light);
		out_color += light_color(normal, lightPos1, lightColor1 * u_light_power) * Kd;
		out_color += light_color(normal, lightPos2, lightColor2 * u_light_power) * Kd;
		out_color += texture2D(u_map_Kr, f_uv_reflect).rgb * (u_Kr + fresnel);
		out_color *= conserve;
		out_color += u_Ka;

		out_color = mix(out_color, sky_color, scaled);

		return vec4(out_color, 1.0);
	}

	vec4 correct_gamma(in vec4 color) {
		return vec4(pow(color.rgb, vec3(1.0 / u_gamma)), color.a);
	}

	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
		vec4 out_color = shade(color, texture, texture_coords, screen_coords);
		out_color.a = dot(out_color.rgb, vec3(0.299, 0.587, 0.114)); // for FXAA

		if (u_shading == 2) return correct_gamma(out_color);

		return out_color;
	}
#endif
