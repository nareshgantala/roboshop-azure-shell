# roboshop-azure-shell


[root@test frontend]# dmesg -T | grep -i "killed process"
[Mon Apr 20 01:57:45 2026] Out of memory: Killed process 8516 (npm install) total-vm:1678032kB, anon-rss:473604kB, file-rss:88kB, shmem-rss:0kB, UID:0 pgtables:2820kB oom_score_adj:0


[root@test frontend]# free -m
               total        used        free      shared  buff/cache   available
Mem:             833         445         385           8         127         388
Swap:              0           0           0
