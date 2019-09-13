x=0
y=1
id=2
macbook=(2880 1800 eDP1)
ext=(2560 1440 DP1)

mx=$()
fb="$(( macbook[x] + ext[x]*2 ))x$(( macbook[y] + ext[y]*2 ))"
macbook_mode="${macbook[$x]}x${macbook[$y]}"
panning="$(( ext[x]*2 ))x$(( ext[y]*2 ))+${macbook[$x]}+0"

echo xrandr --dpi 200 --fb "$fb" \
    --output ${macbook[$id]} --mode $macbook_mode \
    --output ${ext[$id]} --scale 2x2 --pos "${macbook[$x]}x0" --panning "$panning"
