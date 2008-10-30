import graph;

pen[] task_fill = {
      rgb(1.0,0,0),
      rgb(1.0, 0, 1.0),
      rgb(0,1.0,0),
      rgb(0, 1.0, 1.0),
      rgb(0,0,1.0),
      rgb(1.0, 1.0, 0)
};

pen idx2color(int idx) {
    return task_fill[idx % task_fill.length];
}

void setup(picture pic=currentpicture, int step=1) {
     xaxis(pic, 0, RightTicks(Step=step));
     yaxis(pic);
}

pair task_offset(int idx=0, pair base=(0,0))
{
	return base + (0, 1 + idx * 1.2);
}

void task(picture pic=currentpicture, int idx=0, int pid, real exe=0.0, real per=0.0)
{
	string txt = format("$T_{%d}", pid);
	if (exe != 0.0 && per != 0.0) { 
	   txt = txt + format(" = (%f,", exe) + format(" %f)", per);
	} 
	txt += "$";
	label(pic, txt , 
	      task_offset(idx) + (0, -0.15), W, idx2color(idx));
}

real center = 0.2 - (0.7 / 2.0);

void scheduled(picture pic=currentpicture, int idx=0, pair time) {
     path g = (time.x, 0.2)--(time.y, 0.2)--(time.y, -0.5)--(time.x, -0.5)--cycle;
     filldraw(pic, shift(task_offset(idx)) *  g, idx2color(idx));
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
