#!/bin/bash

LOGS_FOLDER="/var/log/expense/"
SCRIPT_NAME=$( echo "$0" |cut -d "." -f1 )
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

dnf install mysql-server -y &>>$LOG_FILE
#VALIDATE $? "Installing mysql Server"

systemctl enable mysqld &>>$LOG_FILE
#VALIDATE $? "Enabled mysql Server"

systemctl start mysqld &>>$LOG_FILE
#VALIDATE $? "Started mysql Server"

mysql -h mysql.sriharikalearningdevops.online -u root -pExpenseApp@1 -e 'show databases;' &>>LOG_FILE
if [ $? -ne 0 ]
then 
    echo "MYSQL root password is not setup, setting now" &>>LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting root password"
else
    echo "MYSQL root password is already setup" | tee =a &>>LOG_FILE
fi
