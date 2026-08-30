for base in \
  https://mirrors.cernet.edu.cn/nix-channels/store \
  https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store \
  https://mirror.sjtu.edu.cn/nix-channels/store \
  https://mirrors.ustc.edu.cn/nix-channels/store \
  https://mirror.nju.edu.cn/nix-channels/store
do
  printf '%-68s ' "$base"
  curl -L -o /dev/null -sS \
    --connect-timeout 5 \
    --max-time 15 \
    -w 'connect=%{time_connect}s first-byte=%{time_starttransfer}s total=%{time_total}s\n' \
    "$base/nix-cache-info"
done
