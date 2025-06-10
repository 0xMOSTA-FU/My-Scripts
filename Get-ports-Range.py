import re

def find_min_max_port_numbers(filename):
    """
    Scans the provided file for occurrences of the phrase "Source Port:", extracts the following port numbers,
    and prints the minimum and maximum port numbers found.

    Args:
        filename (str): The path to the file containing the port number information.
    """

    min_port = None
    max_port = None

    try:
        # Open the file in read mode
        with open(filename, 'r') as f:
            for line in f:
                # Find lines containing the phrase "Source Port:" (case-insensitive)
                if re.search(r"(Source|source) Port\s*:\s*(\d+)", line, re.IGNORECASE):
                    # Extract the port number following "Source Port:"
                    port_str = re.findall(r"(Source|source) Port\s*:\s*(\d+)", line, re.IGNORECASE)[0][1]

                    # Convert port string to integer (with error handling)
                    try:
                        port = int(port_str)
                    except ValueError:
                        print(f"Invalid port format found in line: {line}")
                        continue  # Skip to the next line if conversion fails

                    # Update minimum and maximum ports
                    if min_port is None or port < min_port:
                        min_port = port
                    if max_port is None or port > max_port:
                        max_port = port

    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
        return

    # Print the minimum and maximum port numbers
    if min_port is not None and max_port is not None:
        print(f"Minimum source port number: {min_port}")
        print(f"Maximum source port number: {max_port}")
    else:
        print("No source port numbers found in the file.")


if __name__ == '__main__':
    filename = 'BTLO_port.txt'  # Use your actual file name
    find_min_max_port_numbers(filename)
