//delete files based on date
rm $(ls -lrt .|grep " Aug 30 10:37"|awk '{print $9}')

// Executing command line inside awk to do calculations
awk 'BEGIN{ "ls -la /home/helcim/images/public/8/472/ | wc -l " | getline publicCount; publicCount = publicCount - 3 ; "ls -la /home/helcim/images/public/8/472/*svg | wc -l" | getline svgPublicCount; totalPublic = ((publicCount - svgPublicCount)/3) + svgPublicCount; "ls -la /home/helcim/images/private/8/472/ | wc -l" | getline privateCount; privateCount = privateCount - 3; "ls -la /home/helcim/images/private/8/472/*svg | wc -l" | getline svgPrivateCount; totalPrivate = ((privateCount - svgPrivateCount)/3) + svgPrivateCount; print totalPublic + totalPrivate}'

// DEBUG  
tail -f -n 30 /var/log/httpd/error_log

// DEFEAT TERMINAL TMOUT
while sleep 120; do printf '\33[0n'; done

// FILTER PROCESSES ON TASK MANAGER
top -d 0.1 -c -p $(pgrep -d',' -f PROCESS_NAME_TO_FILTER)

convert little endian to big endian
dd conv=swab < infile > outfile
