#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

# Navigate to /etc directory
if cd /etc; then
  echo "Changed directory to /etc."
else
  echo "Failed to change directory to /etc. Exiting."
  exit 1
fi

# Create the 'ilab' directory if it doesn't already exist
if [ ! -d "ilab" ]; then
  if mkdir ilab; then
    echo "Directory 'ilab' created."
  else
    echo "Failed to create directory 'ilab'. Exiting."
    exit 1
  fi
else
  echo "Directory 'ilab' already exists."
fi

# Navigate to 'ilab' directory
if cd ilab; then
  echo "Changed directory to 'ilab'."
else
  echo "Failed to change directory to 'ilab'. Exiting."
  exit 1
fi

# Create or truncate the 'insights-opt-out' file
if echo > insights-opt-out; then
  echo "File 'insights-opt-out' created or truncated."
else
  echo "Failed to create or truncate 'insights-opt-out'. Exiting."
  exit 1
fi

# Verify the contents of /etc/ilab directory
if ls -l /etc/ilab; then
  echo "Contents of /etc/ilab listed successfully."
else
  echo "Failed to list contents of /etc/ilab. Exiting."
  exit 1
fi

# Check if 'ilab' command exists and runs
if command -v ilab &> /dev/null; then
  echo "'ilab' command exists. Running 'ilab'."
  if ilab; then
    echo "'ilab' command ran successfully."
  else
    echo "'ilab' command failed to run."
    exit 1
  fi
else
  echo "'ilab' command not found. Please ensure it is installed and in your PATH."
  exit 1
fi


# Run 'ilab config init' and select the default option (0)
echo "0" | ilab config init

if [ $? -eq 0 ]; then
  echo "'ilab config init' completed successfully with default CPU-only profile."
else
  echo "Failed to initialize 'ilab' configuration. Exiting."
  exit 1
fi



exit 0
