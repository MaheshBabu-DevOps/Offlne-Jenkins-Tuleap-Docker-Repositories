
echo "EPEL 9 Sync Start"

rsync -avz --progress --delete rsync://ftp.kaist.ac.kr/fedora-epel/9/Everything/x86_64/ /home/cair/Downloads/epel/

echo "EPEL 9 Sync Done"


