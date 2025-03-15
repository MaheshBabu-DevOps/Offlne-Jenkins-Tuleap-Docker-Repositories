echo "Remi sync start"

rsync -avz --progress --delete rsync://repo.extreme-ix.org/remi/enterprise/9/remi/x86_64/ /home/cair/Downloads/remi/

echo "Remi sync done"
