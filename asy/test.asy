
import sched;

size(20cm, 6cm);
//setup(step=1);

task(0, 100);
task(2, 200);
task(3, 4096);

scheduled((3,10));
scheduled(2, (1, 1.1));
scheduled(2, (3, 3.56));
scheduled(2, (7, 7.777));
scheduled(3, (2, 4.5));
//scheduled(4, (-1, 3));

scheduled(1, (1.5, 5));

release(3.0);
deadline(10.0);

blocked(2, 7.777);
resumed(0, 3.0);
completed(2, 6.0);
completed(1, 5.0);
blocked(1, 5.0);
deadline(1, 5.0);
release(1, 5.0);