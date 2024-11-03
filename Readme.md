# FUTU Quant Monitor Setup Guide

## Overview
This project automates the process of monitoring your FUTU screen, capturing screenshots, and uploading them for OCR analysis. The setup consists of a PowerShell script for capturing and uploading images, a scheduled task to automate the script execution, and a batch file to maintain the GUI session even when disconnected from RDP.

## Components

### 1. quant-monitor.ps1
- **Function**: Captures the top-left 25% of the screen, saves the screenshot to the drive, and uploads it to the Azure API.
- **Usage**: This script is scheduled to run every 1 hours to continuously monitor the screen.

### 2. Azure Logic App
- **Function**: Processes the uploaded images using the OCR service to check for the presence of the text "已停止". Sends alerts if the specified text is detected.

### 3. quant-monitor.xml
- **Function**: This XML file is a configuration file for Windows Task Scheduler.
- **Usage**: Import this file into Task Scheduler to automate the execution of `quant-monitor.ps1`.

### 4. keep.bat
- **Function**: Keeps the GUI session open even when the RDP session is disconnected.
- **Usage**: Run this batch file to prevent the screen from turning black when the RDP session is disconnected.

## Installation

### Step 1: Setup Azure Logic App
1. **Create a Logic App**: Set up a new Logic App in the Azure portal.
2. **Create Azure AI**: Create a computer vision service in F0 (Free)
3. **Import the logic-app.json"**: import the json


### Step 2: Prepare the Scripts
1. **Download the Scripts**: Ensure you have `quant-monitor.ps1`, `quant-monitor.xml`, and `keep.bat`.
2. **Modify Paths**: Update the paths in `quant-monitor.ps1` as necessary to point to your desired save location and API endpoint.
3. **Put it somewhere**: Put on Desktop if you are lazy.

### Step 3: Schedule the Script
1. **Import Task Scheduler Configuration**:
   - Open Task Scheduler.
   - Import the `quant-monitor.xml` file.
2. **Configure Schedule**:
   - Set the task to run every 1 hour.
   - Ensure it is set to run when the user is logged on and with the highest privileges.

### Step 4: Run the Batch File
1. **Execute keep.bat**:
   - Run the `keep.bat` file to maintain the GUI session when disconnecting from RDP.

## Troubleshooting
- **Task Not Running**:
  - Check if the Task Scheduler service is running.
  - Ensure the user account has the necessary permissions.
  - Verify the task conditions and settings.
- **OCR Detection Issues**:
  - Confirm the Azure Logic App is correctly configured to process and analyze the images.
  - Check the API endpoints and connections.

## Additional Information
- **Event Logs**: Review the Task Scheduler and Event Viewer logs for any errors or warnings related to the task execution.
- **Permissions**: Ensure the scripts have the necessary permissions to access the file system and network resources.

