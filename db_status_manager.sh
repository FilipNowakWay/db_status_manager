#!/bin/bash

# Function to check if a service is running
check_service() {
    service_name="$1"
    if sudo systemctl is-active --quiet "$service_name"; then
        echo -e "\e[32m$service_name is running\e[0m"
    else
        echo -e "\e[31m$service_name is not running\e[0m"
    fi
}


# Function to start a service
start_service() {
    service_name="$1"
    if sudo systemctl start "$service_name"; then
        echo -e "\e[32m$service_name started successfully\e[0m"
    else
        echo -e "\e[31mFailed to start $service_name\e[0m"
    fi
}

# Function to stop a service
stop_service() {
    service_name="$1"
    if sudo systemctl stop "$service_name"; then
        echo -e "\e[32m$service_name stopped successfully\e[0m"
    else
        echo -e "\e[31mFailed to stop $service_name\e[0m"
    fi
}

# Function to clear the terminal screen
clear_screen() {
    clear
}

# Initial status check
check_service mysqld
check_service postgresql-15

while true; do
    
    echo "Choose an option:"
    echo "1. Start MySQL"
    echo "2. Stop MySQL"
    echo "3. Start PostgreSQL"
    echo "4. Stop PostgreSQL"
    echo "5. Refresh Status"
    echo "6. Exit"

    read -p "Enter your choice: " choice
    clear_screen
    case $choice in
        1)
            start_service mysqld
            ;;
        2)
            stop_service mysqld
            ;;
        3)
            start_service postgresql-15
            ;;
        4)
            stop_service postgresql-15
            ;;
        5)
            # Refresh status
            check_service mysqld
            check_service postgresql-15
            ;;
        6)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please select a valid option."
            ;;
    esac
    read -p "Press Enter to continue..."
done

