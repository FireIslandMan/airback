#!/bin/zsh
# After the GitHub username changes from deJesusbiz to deJesusbiz: repoint every local remote and rewrite references.
set -u
OLD=deJesusbiz; NEW=${1:-deJesusbiz}
P=/Users/gamalier/Desktop/PROJECTS
for d in RESRA/RESRA-iOS RESRA/RESRA-MAIN AIRBACK-SITE airplay-receiver-eval CLEANZIP/cleanzip-site FRIED/yourefried-landing PAIDCAL/ASAPP/LAL-ASAPP-REPO PAIDCAL/ASAPP/SHIP-FAST PAIDCAL/ASAPP/ASAPP-iOS; do
  r=$(git -C "$P/$d" remote get-url origin 2>/dev/null) || continue
  n=${r//$OLD/$NEW}
  [ "$r" != "$n" ] && git -C "$P/$d" remote set-url origin "$n" && echo "$d -> $n"
done
# text references (not the .git folders, not build output)
for f in $(grep -rIl "$OLD" --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=build --exclude-dir=.gradle --exclude-dir=.kotlin "$P/airplay-receiver-eval" "$P/AIRBACK-SITE" 2>/dev/null); do
  sed -i '' "s#github.com/$OLD/#github.com/$NEW/#g; s#$(echo $OLD | tr 'A-Z' 'a-z').github.io#$(echo $NEW | tr 'A-Z' 'a-z').github.io#g; s#$OLD#$NEW#g" "$f" && echo "rewrote $f"
done
