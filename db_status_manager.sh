#!/bin/bash

# Define text color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# File to store the list of services
service_file="services.txt"

# Function to read services from the service file
read_services() {
    if [ -f "$service_file" ]; then
        mapfile -t services < "$service_file"
    else
        services=()
    fi
}

# Function to save services to the service file
save_services() {
    printf "%s\n" "${services[@]}" > "$service_file"
}

# Function to add a service to the list
add_service() {
    local new_service="$1"
    services+=("$new_service")
    save_services
}

# Function to start a service
start_service() {
    local service_name="$1"
    systemctl start "$service_name"
}

# Function to stop a service
stop_service() {
    local service_name="$1"
    systemctl stop "$service_name"
}

# Function to restart a service
restart_service() {
    local service_name="$1"
    systemctl restart "$service_name"
}

# Function to refresh the status of services
refresh_services() {
    running_services=()
    not_installed_services=()

    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            running_services+=("$service")
        else
            if systemctl is-active --quiet "$service" 2>&1 | grep -q "not-found"; then
                not_installed_services+=("$service (Not Installed)")
            fi
        fi
    done
}

# Read the initial list of services from the file
read_services

# Initialize lists to store running and not installed services
running_services=()
not_installed_services=()

# Function to print a list of services with a colored header
print_service_list() {
    local header_color="$1"
    local header="$2"
    shift 2
    local services=("$@")

    if [ ${#services[@]} -eq 0 ]; then
        return
    fi

    echo -e "${header_color}$header${NC}"
    for service in "${services[@]}"; do
        echo -e "  - $service"
    done
}

# Menu to manage services
while true; do
    refresh_services  # Refresh services status

    clear
    echo -e "${GREEN}Service Status Checker${NC}"
    echo "----------------------"
    echo
    print_service_list "$GREEN" "Running Services:" "${running_services[@]}"
    echo
    print_service_list "$RED" "Not Installed Services:" "${not_installed_services[@]}"
    echo
    echo "1. Add a Service"
    echo "2. Start a Service"
    echo "3. Stop a Service"
    echo "4. Restart a Service"
    echo "5. Exit"
    echo
    read -p "Select an option: " choice
    case $choice in
        1)
            read -p "Enter the name of the service to add: " new_service
            add_service "$new_service"
            ;;
        2)
            clear
            echo -e "${GREEN}Service Status Checker${NC}"
            echo "----------------------"
            echo
            print_service_list "$GREEN" "Running Services:" "${running_services[@]}"
            echo
            echo "Select a service to start:"
            select start_service_name in "${services[@]}"; do
                if [ -n "$start_service_name" ]; then
                    start_service "$start_service_name"
                    break
                else
                    echo "Invalid selection. Please try again."
                fi
            done
            ;;
        3)
            clear
            echo -e "${GREEN}Service Status Checker${NC}"
            echo "----------------------"
            echo
            print_service_list "$GREEN" "Running Services:" "${running_services[@]}"
            echo
            echo "Select a service to stop:"
            select stop_service_name in "${running_services[@]}"; do
                if [ -n "$stop_service_name" ]; then
                    stop_service "$stop_service_name"
                    break
                else
                    echo "Invalid selection. Please try again."
                fi
            done
            ;;
        4)
            clear
            echo -e "${GREEN}Service Status Checker${NC}"
            echo "----------------------"
            echo
            print_service_list "$GREEN" "Running Services:" "${running_services[@]}"
            echo
            echo "Select a service to restart:"
            select restart_service_name in "${running_services[@]}"; do
                if [ -n "$restart_service_name" ]; then
                    restart_service "$restart_service_name"
                    break
                else
                    echo "Invalid selection. Please try again."
                fi
            done
            ;;
        5)
            break
            ;;
        *)
            echo "Invalid option. Press Enter to continue."
            read
            ;;
    esac
done
