wcet(1, 3.0).
wcet(2, 4.0).
wcet(3, 5.0).
wcet(4, 6.0).
wcet(5, 17.0).

period(1, 15).
period(3, 10).

released(job(1, 1), 0.0).
released(job(2, 1), 1.0).
released(job(3, 1), 0.0).
released(job(3, 2), 12.0).
released(job(1, 2), 15.0).
released(job(4, 1), 14.0).
released(job(5, 1), 0.0).

scheduled(job(1, 1), 0.0, 1.0).
scheduled(job(1, 1), 3.0, 7.0).
scheduled(job(2, 1), 1.0, 3.0).
scheduled(job(3, 1), 7.0, 12.0).
scheduled(job(1, 1), 2.0, 3.0).
scheduled(job(3, 2), 12.0, 15.0).
scheduled(job(4, 1), 14.0, 16.0).
scheduled(job(1, 2), 15.0, 16.5).
scheduled(job(3, 2), 16.5, 23.0).

deadline(job(1, 1), 10.0).
deadline(job(2, 1), 5.0).
deadline(job(3, 1), 11.0).
deadline(job(3, 2), 22.0).
deadline(job(1, 2), 20.0).
deadline(job(4, 1), 21.0).
deadline(job(5, 1), 15.0).

completed(job(1, 1), 7.0).
completed(job(2, 1), 3.0).
completed(job(3, 1), 12.0).
completed(job(3, 2), 23.0).
completed(job(4, 1), 16.0).
completed(job(1, 2), 16.5).
