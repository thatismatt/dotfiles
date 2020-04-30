function e
    set -q emacs_server; or set -l emacs_server 'server'
    set -l emacs_frame_count (emacsclient --socket-name $emacs_server -e "(length (frame-list))")
    set -l emacsclient_args
    if test -n "$DISPLAY" # X11
        set emacsclient_args "--no-wait"
    end
    if test "$emacs_frame_count" = 1 -o -z "$emacs_frame_count"
        # emacs daemon isn't running or there's no visible frame, NOTE: there is always the invisible "initial_frame"
        set emacsclient_args $emacsclient_args "--create-frame"
    end
    emacsclient -a= -s $emacs_server $emacsclient_args $argv
end
