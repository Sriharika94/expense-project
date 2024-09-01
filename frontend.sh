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
    echo "please run the script with root privilages" | tee -a $LOG_FILE
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

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "Enable nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Start nginx"

rm -rf /usr/share/nginx/html/*  &>>$LOG_FILE
VALIDATE $? "Removing default website"


curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Extract frontend code"

 cp /home/ec2-user/expense-project/expense.conf /etc/nginx/default.d/expense.conf

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restart nginx"