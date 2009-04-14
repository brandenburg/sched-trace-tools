
import sched;

size(32cm, 6cm);
//setup(step=1);

task(0, 100);
task(2, 200);
task(3, 4096);

scheduled((3,10));
scheduled(2, cpu=9, (1, 1.1));
scheduled(2, (3, 3.56));
scheduled(2, (7, 7.777));
scheduled(3, (2, 4.5));
//scheduled(4, (-1, 3));

int i;
for (i = 0; i < 32; i += 1) {
  scheduled(1, cpu=i, (i + 1, i + 2));
}

release(3.0);
deadline(10.0);

blocked(2, 7.777);
resumed(0, 3.0);
completed(2, 6.0);
completed(1, 5.0);
blocked(1, 5.0);
deadline(1, 5.0);
release(1, 5.0);
