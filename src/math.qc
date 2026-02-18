/*
	math.qc

	Math utils

	Copyright (C) 1998-2000 Matt 'asdf' McChesney
	Copyright (C) 2000-2007 ParboiL
	DrLex 2024-2025
*/


float(float v) anglemod360 =
{
	while (v >= 360)
		v = v - 360;
	while (v < 0)
		v = v + 360;
	return v;
};

float(float a) anglemod =
{
	while (a >= 180)
		a = a - 360; // a < 180
	while (a < -180)
		a = a + 360; // a >= -180
	return a;
};

// For player v_angle and angles. These go from -180 to 180 and are
// represented in 8-bit, hence the rounding with factor 360/256.
float(float a) anglemod2 =
{
	while (a >= 180)
		a = a - 360; // a < 180
	while (a < -180)
		a = a + 360; // a >= -180
	a = rint(a / 1.40625) * 1.40625;
	return a;
};

// To calculate atan(x), invoke as atan2(x, 1)
float(float y, float x) atan2 =
{
	local vector ang;
	ang = '0 0 0';
	ang_x = x;
	ang_y = y;
	return vectoyaw(ang);
};

/* Approximation using a crude look-up refined with Newton's method,
   much faster than invoking pow(x, 0.5).
   Error is less than 1% for x < 37M, less than 0.1% for x < 18M.
   Not accurate for very small x (error becomes > 1% for x < 0.007). */
float sqrt(float x) {
	local float y;
	if (x <= 0) return 0;
	if (x == 1) return 1;
	if (x < 20)
		y = 0.5 * (x + 1);
	else if (x < 200)
		y = 0.1 * x;
	else if (x < 2000)
		y = 0.05 * x;
	else if (x < 20000)
		y = 0.01 * x;
	else if (x < 200000)
		y = 0.005 * x;
	else
		y = 0.001 * x;
	y = 0.5 * (y + x / y);
	y = 0.5 * (y + x / y);
	y = 0.5 * (y + x / y);
	return 0.5 * (y + x / y);
};

/* The following has been moved from arena.qc */

// check if n is an integer
float(float a) is_int =
{
	if (a == rint(a))
		return 1;
	return 0;
};

// check if n is an odd integer
float(float a) is_oint =
{
	if (is_int(a))
	if (!is_int(a / 2))
		return 1;
	return 0;
};

// check if a^b is an imaginary number
float(float a, float b) imaginary =
{
	if (a < 0)
	if (!is_int(b))
	if (!is_oint(1 / b))
		return 1;
	return 0;
};

// return digit in b place of number a (b = power of 10)
float(float a, float b) dig =
{
	local float c, d, e;
	a = fabs(a);
	c = floor(a / b);
	d = floor(c / 10) * 10;
	e = c - d;
	return e;
};

// returns a^b (w00t!)
// However, computationally very expensive and will trip runaway loop protection
// in some engines. At best can be used once or twice in pre-game calculations,
// definitely not in-game.
float(float a, float b) pow =
{
	local float c, d, e, f, g, h, i, j, k;

	if (!a)
		return 0;
	if (!b)
		return 1;
	if (imaginary(a, b))
		return 0;
	if (b > 14000)
		return 0;
	b = rint(b * 100) / 100;
	c = fabs(b);
	c = floor(c);
	d = 1;
	while (c > 0)
	{
		c = c - 1;
		d = d * a;
	}
	if (!is_int(b))
	{
		e = 0.1;
		while (e >= 0.01)
		{
			f = dig(b, e);
			f = pow(a, f);
			if (f)
			{
				g = 50;
				if (a > 1)
					h = a;
				else
					h = 1;
				i = 0;
				while (g > 0)
				{
					g = g - 1;
					j = (h + i) / 2;

					k = pow(j, 1 / e);
					if (k == f)
						g = 0;
					else
					if (k > f)
						h = j;
					else
					if (k < f)
						i = j;
				}
				d = d * j;
			}
			e = e / 10;
		}
		if (a < 0)
			d = -1 * d;
	}
	if (b < 0)
		d = 1 / d;
	return d;
};
