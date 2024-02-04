 ```
 repository_url="https://github.com/inerba/blade-icons.git" && destination_directory="./" && temp_directory=$(mktemp -d) && git clone --depth 1 "$repository_url" "$temp_directory" && cp -r "$temp_directory"/* "$destination_directory" && rm -rf "$temp_directory"
 ```