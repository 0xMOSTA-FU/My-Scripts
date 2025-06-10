from scapy.all import *
import socket
import sys

# Network Scan Configuration
interface = "eth0"  # Replace with your network interface if different
target_ip = "192.168.42.139"

# ARP Scan (Optional)
def perform_arp_scan(target_ip, interface):
    """
    Performs an ARP scan to discover active devices on the network.

    Args:
        target_ip (str): The target IP address to scan.
        interface (str): The network interface to use.

    Returns:
        list: A list of tuples containing the source MAC and IP addresses of discovered devices.
    """

    broadcastMac = "ff:ff:ff:ff:ff:ff"
    packet = Ether(dst=broadcastMac)/ARP(pdst=f"{target_ip}/24")
    ans, unans = srp(packet, timeout=2, iface=interface, inter=0.1)
    discovered_devices = []
    for send, receive in ans:
        discovered_devices.append((receive.sprintf("%Ether.src%"), receive.sprintf("%ARP.psrc%")))
    return discovered_devices

# TCP Port Scanner
def probe_port(ip, port):
    """
    Checks if a specific port is open on the target IP address.

    Args:
        ip (str): The target IP address.
        port (int): The port number to check.

    Returns:
        bool: True if the port is open, False otherwise.
    """

    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(0.5)  # Adjust timeout as needed
        result = sock.connect_ex((ip, port))
        sock.close()
        return result == 0
    except Exception as e:
        return False

def scan_ports(target_ip, ports):
    """
    Scans a range of ports on the target IP address.

    Args:
        target_ip (str): The target IP address.
        ports (list): A list of port numbers to scan.

    Returns:
        list: A list of open ports found on the target IP address.
    """

    open_ports = []
    for port in ports:
        if probe_port(target_ip, port):
            open_ports.append(port)
    return open_ports

# Main Execution
if __name__ == "__main__":
    # Optional ARP Scan (uncomment to display discovered devices)
    # discovered_devices = perform_arp_scan(target_ip, interface)
    # if discovered_devices:
    #     print("Discovered Devices:")
    #     for mac, ip in discovered_devices:
    #         print(f"  MAC: {mac}, IP: {ip}")

    # Port Scan Configuration
    ports_to_scan = range(1, 65535)  # Scan all ports (adjust as needed)

    # Scan Ports
    open_ports = scan_ports(target_ip, ports_to_scan)

    # Print Results
    if open_ports:
        print(f"Open Ports on {target_ip}:")
        for port in open_ports:
            print(f"  - {port}")
    else:
        print(f"No open ports found on {target_ip}.")

    print("Scan completed.")
