import json
import os
import sys
from typing import Dict


def read_env_file(file_path: str) -> Dict[str, str]:
    """
    Load environment variables from a '.env' file.

    Each line in the file should be in the KEY=VALUE format.
    Lines starting with '#' or empty lines are ignored.

    Args:
        path (str): Path to the '.env' file.

    Returns:
        Dict[str, str]: A dictionary mapping environment variable names
        to values.

    Raises:
        FileNotFoundError: If the file does not exist.
    """

    env_variables = {}

    with open(file_path) as source_file:
        for line in source_file:
            # Ignore spaces, comments and empty lines.
            line = line.strip()
            if not line or line.startswith("#"):
                continue

            key, value = line.split("=", 1)
            env_variables[key.strip()] = value.strip()

    return env_variables


def str_to_bool(value: str) -> bool:
    """
    Convert a string to a boolean.

    Accepts "true", "1", "yes", "on" (case-insensitive) as True.
    Anything else is False.

    Args:
        value (str): String to convert.

    Returns:
        bool: Boolean value of the string.
    """
    return str(value).lower() in ("true", "1", "yes", "on")


def main() -> None:
    """
    Main function to generate '.vscode/sftp.json' from a '.env' file.

    Requires a command-line argument specifying the '.env' file.
    Reads SFTP_HOST, SFTP_USER, SFTP_PASS, SFTP_REMOTE_PATH,
    SFTP_UPLOAD_ON_SAVE from the environment file. `useTempFile` is
    always True.

    Usage:
        python generate_sftp.py <env_file>

    Exits:
        '1' if there is an error (missing argument, file not found,
        etc.).
    """
    try:
        env_file: str = sys.argv[1]  # Required argument
        sftp_details: Dict[str, str] = read_env_file(env_file)

        config: Dict[str, object] = {
            "name": "My Portfolio Server",
            "host": sftp_details.get("SFTP_HOST"),
            "username": "".join(
                [
                    sftp_details.get("SFTP_USER"),
                    "@",
                    sftp_details.get("SFTP_FOLDER"),
                    ".com",
                ]
            ),
            "password": sftp_details.get("SFTP_PASS"),
            "remotePath": "/" + sftp_details.get("SFTP_FOLDER"),
            "uploadOnSave": str_to_bool(
                sftp_details.get("SFTP_UPLOAD_ON_SAVE")
            ),
            "protocol": "sftp",
            "port": 22,
            "useTempFile": True,
        }

    except IndexError:
        print("Error: Missing '.env' file argument.")
        print("Usage: python create_sftp_config.py <env_file>")
        sys.exit(1)

    except FileNotFoundError:
        print(f"Error: File '{env_file}' not found.")
        sys.exit(1)

    except Exception as err:
        print(f"Unexpected error: {err}")
        sys.exit(1)

    # Ensure ".vscode" directory exists.
    os.makedirs(".vscode", exist_ok=True)

    # Write JSON file.
    with open(".vscode/sftp.json", "w") as target_file:
        json.dump(config, target_file, indent=2)
    print(f"'sftp.json' generated from {env_file}")


if __name__ == "__main__":
    main()
