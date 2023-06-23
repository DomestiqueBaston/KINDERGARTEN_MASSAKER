/*
	Glitch Effect Shader by Yui Kinomoto @arlez80
*/

shader_type canvas_item;

// 振動の強さ
uniform float shake_power : hint_range(0.0, 0.25) = 0.0;
// 振動率
uniform float shake_rate : hint_range( 0.0, 1.0 ) = 0.0;
// 振動速度
uniform float shake_speed : hint_range(0.0, 10.0) = 0.0;
// 振動ブロックサイズ
uniform float shake_block_size : hint_range(1.0,200.0) = 4.0;
// 色の分離率
uniform float shake_color_rate : hint_range( 0.0, .1 ) = 0.0;

float random( float seed )
{
	return fract( 543.2543 * sin( dot( vec2( seed, seed ), vec2( 3525.46, -54.3415 ) ) ) );
}

	// --------------------------
	// -------------------------- Glitches :
	// --------------------------

void fragment( )
{
	float enable_shift = float(
		random( trunc( TIME * shake_speed))
	<	shake_rate
	);

	vec2 fixed_uv = SCREEN_UV;
	fixed_uv.x += (
		random(
			( trunc( SCREEN_UV.y * shake_block_size ) / shake_block_size )
		+	TIME
		) - 0.5
	) * shake_power * enable_shift;
	
	// -------------------------- Ajout perso (de l'auteur)
	
	fixed_uv.y += (
		random(
			( trunc( SCREEN_UV.x)) // ( trunc( SCREEN_UV.x * shake_block_size ) / shake_block_size)
		+	TIME
		) - 0.5
	) * shake_power * enable_shift;
	
	// --------------------------
	// -------------------------- Décalage du RGB :
	// --------------------------

	vec4 pixel_color = texture( SCREEN_TEXTURE, fixed_uv );
	pixel_color.r = mix(
		pixel_color.r
	,	texture( SCREEN_TEXTURE, fixed_uv + vec2( shake_color_rate, 0.0 ) ).r
	,	enable_shift
	);
	
	// -------------------------- Ajout perso (de l'auteur)
	
	pixel_color.g = mix(
		pixel_color.g
	,	texture( SCREEN_TEXTURE, fixed_uv + vec2( 0.0, -shake_color_rate + 0.01) ).g
	,	enable_shift
	);
	
	// --------------------------
	
	pixel_color.b = mix(
		pixel_color.b
	,	texture( SCREEN_TEXTURE, fixed_uv + vec2( -shake_color_rate, 0.0 ) ).b
	,	enable_shift
	);
	COLOR = pixel_color;
}
