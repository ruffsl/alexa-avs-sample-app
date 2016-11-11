xhost +local:root

docker run \
  -it \
  --env="DISPLAY" \
  --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
  --device /dev/snd:/dev/snd \
  --publish 3000:3000 \
  avs bash -c "byobu new-session glances \; split-window -d -h 'cd samples/companionService && npm start' \; select-pane -t 1 \; split-window -d 'cd samples/javaclient && mvn exec:exec' \; select-pane -t 2"

xhost -local:root
