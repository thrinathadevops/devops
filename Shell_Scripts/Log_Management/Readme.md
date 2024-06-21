🚀 Project Update: Automating Log Management with Shell Scripting! 🚀

I am excited to share my recent work on a comprehensive shell script that automates the process of log management. This script efficiently handles the copying, archiving, transferring, and deleting of log files. Here’s a detailed breakdown of the tasks involved:

Task Overview:

1. Copy Logs:
The script identifies and copies specific log files (SystemOut_*.log and SystemErr_*.log) from the source directory. It ensures only the logs from the last 24 hours are processed to maintain relevance.

2. Archive Logs:
The copied logs are compressed into a gzip archive. This not only saves space but also prepares the files for easy transfer and backup.

3. Transfer Logs:
The archived logs are securely transferred to a remote server. The script performs network connectivity checks using ping and telnet to ensure the target server is reachable before initiating the transfer.

4. Delete Old Logs:
To manage disk space and keep the log directory tidy, the script deletes log files older than 7 days. This automated cleanup is crucial for maintaining system performance and preventing storage issues.

Technical Details:

Language: Bash Shell Scripting
Network Checks: Utilizes ping and telnet for connectivity verification.
Compression: Archives logs using tar and gzip.
File Operations: Copies, moves, and deletes files based on timestamps.
Error Handling: Comprehensive error handling and log restoration mechanisms to ensure data integrity and reliability.

Benefits:
Efficiency: Automates repetitive tasks, saving time and reducing manual effort.
Reliability: Ensures critical logs are always backed up and transferred without interruption.
Maintenance: Regularly cleans up old logs, optimizing storage usage and maintaining system health.


Here's the expected output of the script with an intentionally incorrect port number to demonstrate error handling:
<img width="578" alt="image" src="https://github.com/thrinathadevops/devops/assets/167942687/b61bee01-fc89-4357-b6c9-d2f085a89534">

The log archival, transfer, and deletion process completed successfully, with all specified logs archived and transferred to the target server without any network issues.


<img width="317" alt="image" src="https://github.com/thrinathadevops/devops/assets/167942687/610da92c-1cf2-41ee-951b-4aae86faa10e">

No log files were found within the specified criteria for archival and transfer. The process completed successfully with no logs to archive.


<img width="319" alt="image" src="https://github.com/thrinathadevops/devops/assets/167942687/ddc9f55d-767d-476d-8070-3a56a7de6911">
