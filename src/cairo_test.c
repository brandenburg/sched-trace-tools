#include <stdio.h>
#include <stdlib.h>

#include <cairo.h>

static double in2pts(double in)
{
	/* 72 pts per inch */
	return in * 72;
}

static double cm2in(double cm)
{
	/* 1in = 2.54 cm */
	return cm / 2.54;
}

static double cm2pts(double cm)
{
	return in2pts(cm2in(cm));
}

void cairo_test(void)
{
	cairo_surface_t *surface;
	cairo_t *cr;
	
	surface = cairo_pdf_surface_create("test.pdf", cm2pts(10), cm2pts(10));
	cr = cairo_create(surface);
	cairo_set_source_rgb(cr, 1.0, 0.3, 0.7);
	cairo_rectangle(cr, cm2pts(0.25), cm2pts(0.25), cm2pts(0.5), cm2pts(0.5));
	cairo_fill(cr);
	cairo_destroy(cr);
	cairo_surface_destroy(surface);
}

int main (int argc, char** argv)
{
	cairo_test();
	return 0;
}
