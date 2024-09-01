#!/bin/bash

LOGS_FOLDER="/var/log/expense/"
SCRIPT_NAME=$( echo "$0" | cut -d "." -f1 )
TIME_STAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIME_STAMP.log"
mkdir -p $LOGS_FOLDER


USERID=$(id -u)


R="\e[31m"
G="\e[32m"
N="\e[0m"

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
    echo "please run the script with root privilages" | tee -a &>>$LOG_FILE
    exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is $R Failed $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is $G success" | tee -a $LOG_FILE
    fi
}

echo "script started executing at $(date)" | tee -a $LOG_FILE

CHECK_ROOT

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disable default nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enable nodejs:20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Install nodejs"

useradd expense &>>$LOG_FILE
VALIDATE $? "Creating expense user"
