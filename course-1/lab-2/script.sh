#!/bin/bash
echo -e "\033[36m++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\033[m"
echo -e "\033[36m+\033[m""\033[3m Artifact management basics\033[m""\033[36m                                                                                   +\033[m"
echo -e "\033[36m+\033[m""\033[3m course-1/lab-1\033[m""\033[36m                                                                                               +\033[m"
echo -e "\033[36m++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\033[m"

# This loop keeps searching for a file named "lib.sh" by going up one directory level at a time using "cd .."
# If the file is found, the loop breaks and the script sources "lib.sh" using "source". Finally, it changes back to the original directory using "cd -"
while [ ! -f "./lib.sh" ]; do cd ..; done; source lib.sh; export ROOT_DIR=$PWD;cd - > /dev/null

# Set arguments
server_name=$2
username=$3
password=$4

common(){
    jf c add --url=https://${server_name}.jfrog.io/ --user=${username}  --password=${password} ${server_name}
}

setup() {
    common
    #Create a 2 users and name respectively ```sunday``` and ```monday```
    jf rt user-create monday Admin123! monday@jfrog.com
    jf rt user-create sunday Admin123! sunday@jfrog.com --admin
    #Create a JFrog Project
    
    
}

execute(){
    common
    jf c use ${server_name}
    #Create a sample text file on your local machine, such as `test.txt`.
    echo "This Text file has been generated by PS scripts" > test.txt
    jf rt upload "test.txt" user1-local-test-generic/cli-tests/
    jf rt sp  --include-dirs "green-generic-test-local/cli-tests/test.txt" "runtime.deploy.datetime=20240219_08000,runtime.deploy.account=robot_sa"
}

# Vérifiez si le premier argument est "setup" et appelez la fonction setup avec les arguments suivants
if [ "$1" == "setup" ]; then
    echo -e "\033[30m Execute Setup \033[m"
    setup "$2" "$3" "$4"
elif [ "$1" = "execute" ]; then
    execute "$2" "$3" "$4"
else
    echo -e "\033[31mUsage: $0 {setup|execute} server_name username password\033[m"
    exit 1
fi

# Check the first argument and call appropriate functions
if [ "$1" == "setup" ] || [ "$1" == "execute" ]; then
  # Check if the .config file exists
  if [ -f ${ROOT_DIR}/.config ]; then
    # Source the .config file to get configuration values
    source ${ROOT_DIR}/.config

    # Call the appropriate function based on the first argument
    if [ "$1" == "setup" ]; then
      echo -e "\033[30m Execute Setup \033[m"
      setup "$server_name" "$username" "$password"
    elif [ "$1" == "execute" ]; then
      execute "$server_name" "$username" "$password"
    fi
  else
    # If .config file doesn't exist, use command-line arguments
    if [ "$1" == "setup" ]; then
      echo -e "\033[30m Execute Setup \033[m"
      setup "$2" "$3" "$4"
    elif [ "$1" == "execute" ]; then
      execute "$2" "$3" "$4"
    fi
  fi
else
  # Display usage information and exit with an error
  echo -e "\033[31mUsage: $0 {setup|execute} server_name username password\033[m"
  exit 1
fi