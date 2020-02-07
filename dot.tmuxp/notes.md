 # Layout Notes
 run to display active tmux session layout:
 ``` $> tmux list-windows -F "#{window_active} #{window_layout}" | grep "^1" | cut -d " " -f 2 ```
 
 
