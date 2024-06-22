🚀 Automate Your Tomcat Server Management with This Shell Script 🚀

🔧 Problem: Ensuring that your Tomcat server is always running and can be restarted smoothly during deployments.

🚀 Solution: Implement a bash script to manage the Tomcat server efficiently. This script checks if Tomcat is running, starts it if it’s stopped, or restarts it if it’s running.

🔍 Key Features:

Server Detection: Identifies if the Tomcat server is running by checking the process ID (PID).
Start Server: Initiates the Tomcat server if it’s not running.
Stop and Restart Server: Stops the server if it’s running and restarts it after a 60-second interval to ensure a smooth transition.
Wait Interval: During a restart, the script waits for 60 seconds after stopping the server to ensure it has fully shut down before starting it again.
Error Handling: Improved error handling and logging to provide better feedback and ensure reliability.

🔄 Usage: This script is highly customizable and can be adapted to manage other servers like WebSphere or IBM HTTP Server by modifying the PID detection logic.

✨ Benefit: Automates server management tasks, reducing downtime and ensuring a reliable deployment process.

Example Output:
Given wrong path: If the script is configured with an incorrect path to the Tomcat binaries, it will fail to execute the start or stop commands, resulting in an error message. The output logs indicate the script's attempt to start Tomcat and the subsequent failure due to the wrong path.

<img width="291" alt="image" src="https://github.com/thrinathadevops/devops/assets/167942687/e91bdc38-a2fd-47bf-b150-9828a7806203">



Server starting: When the script successfully starts the Tomcat server, it logs the start attempt, and upon successful initiation, it logs the PID of the running Tomcat instance.

<img width="301" alt="image" src="https://github.com/thrinathadevops/devops/assets/167942687/f6734325-bd8f-4705-afd8-242716ea44f3">


Server restarting: If the script detects that Tomcat is already running, it stops the server and waits for 60 seconds before restarting it. The logs capture the stop process, the wait period, and the successful restart along with the new PID.


<img width="785" alt="image" src="https://github.com/thrinathadevops/devops/assets/167942687/68dd5ffc-cbd4-4f0b-83ce-ed9b372112cd">
