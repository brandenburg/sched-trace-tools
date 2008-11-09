import graph;
import palette;

real __from = 0.0;
real __to   = 0.0;
int  __no_tasks = 0;
real __scale = 1.0;
real __time_scale = 1.0;

void start_time(real when)
{
  __from = when;
}

void end_time(real when)
{
  __to = when;
}

void number_of_tasks(int n)
{
	__no_tasks = n;
}

void prepare_schedule(picture pic=currentpicture,
		      real t0, real t1, int no_tasks)
{
	real delta = t1 - t0;
	start_time(t0);
	end_time(t1);
	number_of_tasks(no_tasks);
	if (delta > 2000) {
		__time_scale = 2000 / delta;
	}
	if (delta > 450) {
		__scale = 450.0 / delta;
		delta = 450;
	}
	size(pic, delta * cm, no_tasks * 1.5cm, false);
}

pen[] task_fill = {
      rgb(1.0,0,0),
      rgb(0,0,1.0),
      rgb(0,1.0,0),
      rgb(1.0, 0, 1.0),
      rgb(0, 1.0, 1.0),
      rgb(1.0, 1.0, 0)
};

pen[] cpu_fill = task_fill;

pen grid_pen = solid + gray(0.75);

pen idx2color(int idx) {
    return cpu_fill[idx % cpu_fill.length];
}

void setup(picture pic=currentpicture, int step=1) {
     xaxis(pic, 0, RightTicks(Step=step));
     yaxis(pic);
}

pair task_y(int idx=0, pair base=(0,0))
{
	return base + (0, 1 + idx * 1.2);
}

pair task_offset(int idx=0, pair base=(0,0))
{
	pair y = task_y(idx, base);
//	return y + (-__from, 0.0);
	return y;
}


void task(picture pic=currentpicture, int idx=0, int pid, real exe=0.0, real per=0.0)
{
	string txt = format("$T_{%d}", pid);
	if (exe != 0.0 && per != 0.0) {
	   txt = txt + format(" = (%f,", exe) + format(" %f)", per);
	}
	txt += "$";
	label(pic, txt ,
	      task_y(idx) + (__from, -0.15), W);
}

real center = 0.2 - (0.7 / 2.0);

void scheduled(picture pic=currentpicture, int idx=0, int cpu=0,  pair time) {
     path g = (time.x, 0.2)--(time.y, 0.2)--(time.y, -0.5)--(time.x, -0.5)--cycle;
     filldraw(pic, shift(task_offset(idx)) *  g, idx2color(cpu));
}

void release(picture pic=currentpicture, int idx=0, real when) {
     path g = (when, -0.5)--(when, 0.5)--(when + 0.1, 0.35)--(when - 0.1, 0.35)--(when, 0.5);
     draw(pic,  shift(task_offset(idx)) *g, solid + 0.5);
}

void deadline(picture pic=currentpicture, int idx=0, real when) {
     path g = (when, 0.5)--(when, -0.5)--(when - 0.1, -0.35)--(when + 0.1, -0.35)--(when, -0.5);
     draw(pic,  shift(task_offset(idx)) * g, solid + 0.5);
}

void blocked(picture pic=currentpicture, int idx=0, real when) {
     path g = (when, center + 0.1)--(when - 0.1, center)--(when, center -0.1)--cycle;
     filldraw(pic, shift(task_offset(idx)) * g);
}

void resumed(picture pic=currentpicture, int idx=0, real when) {
     path g = (when, center + 0.1)--(when + 0.1, center)--(when, center -0.1)--cycle;
     filldraw(pic, shift(task_offset(idx)) * g, white);
}

void completed(picture pic=currentpicture, int idx=0, real when) {
//     path  g = (when, -0.5)--(when, 0.5);
//     path  c = scale(0.1) * (shift(0, 0) * unitcircle);
//     draw(pic, shift(task_offset(idx, (when, 0.4))) * c);
//     draw(pic, shift(task_offset(idx)) * g);
     path g1 = (when, -0.5)--(when, 0.5);
     path g2 = (when - 0.1, 0.5)--(when + 0.1, 0.5);
     draw(pic,  shift(task_offset(idx)) * g1, solid + 0.5);
     draw(pic,  shift(task_offset(idx)) * g2, solid + 0.5);
}

void draw_grid(picture pic=currentpicture, real xstep=1.0, real f=__from,
	       real t=__to, int tasks=__no_tasks, real xlabelstep=10.0)
{
	real pos = f;
	int idx = 0;

	while (idx < tasks) {
		path g = (f - 4,-0.5)--(t,-0.5);
		draw(pic, shift(task_offset(idx)) * g, grid_pen);
		idx = idx + 1;
	}

	while (pos <= t) {
		path g = task_y(0, (pos, -1))--task_y(tasks - 1, (pos, 1.0));
		draw(pic, g, grid_pen);
		pos = pos + xstep;
	}

	pos = f;
	while (pos <= t) {
		Label l = scale(__time_scale) * Label(format("%f", pos));
		label(pic, l, task_y(0, (pos, -1.2)), grid_pen);
		path g = task_y(0, (pos, -0.8))--task_y(0, (pos - 0.5, -1.0))--task_y(0, (pos + 0.5, -1.0))--cycle;
		fill(pic, g, grid_pen);
		pos = pos + xlabelstep;
	}

}
