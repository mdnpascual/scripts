// Executing command line inside awk to do calculations
awk 'BEGIN{ "ls -la /home/helcim/images/public/8/472/ | wc -l " | getline publicCount; publicCount = publicCount - 3 ; "ls -la /home/helcim/images/public/8/472/*svg | wc -l" | getline svgPublicCount; totalPublic = ((publicCount - svgPublicCount)/3) + svgPublicCount; "ls -la /home/helcim/images/private/8/472/ | wc -l" | getline privateCount; privateCount = privateCount - 3; "ls -la /home/helcim/images/private/8/472/*svg | wc -l" | getline svgPrivateCount; totalPrivate = ((privateCount - svgPrivateCount)/3) + svgPrivateCount; print totalPublic + totalPrivate}'
