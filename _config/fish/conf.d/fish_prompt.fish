# Set the prompt command

function matt_prompt_pwd
    set pwd_segments (string split "/" (prompt_pwd))
    echo -n -s (set_color "086") $pwd_segments[1..-3]/
    echo -n -s (set_color "0a3") $pwd_segments[-2]/
    echo -n -s (set_color "6d9") $pwd_segments[-1]
end

function fish_prompt --description "Write out the prompt"
    echo -e -s \
    (set_color "0ce") "$USER" \
    (set_color "0af") "@" \
    (set_color "07f") (prompt_hostname) \
    (set_color "normal") " " \
    (matt_prompt_pwd)
    echo -n -s \
    (set_color "03f") "> "
end
