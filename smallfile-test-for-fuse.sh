#!/bin/bash

LogFile="/var/log/PerfTestClient.log"
logger -s "The value of Varaible CLIENT is $CLIENT " 2>> $LogFile

if [ $# -ne 1  ]
then
    echo; echo "Usage: $0 <Server node from where to collect the data>"
    echo; echo "eg:"
    echo; echo "    # $0 server1.example.com output.txt output.txt"
    exit
fi

ServerNode=$1

logger -s "`date` Созадаем лог-файл на root@$ServerNode" 2>> $LogFile

ssh root@$ServerNode "echo Smallfile TestStarts > /var/log/PerfTest.log  2>&1"
ssh root@$ServerNode "date >> /var/log/PerfTest.log  2>&1"
scp /root/collect-info.sh root@$ServerNode:/tmp/
ssh root@$ServerNode "/tmp/collect-info.sh >> /var/log/PerfTest.log  2>&1"
ssh root@$ServerNode "gluster volume info >> /var/log/PerfTest.log 2>&1"

cd /root/

# Operations=( "create" "ls-l" "chmod" "stat" "read" "append" "rename" "delete-renamed" "mkdir" "rmdir" "cleanup" )
Operations=( "create" "ls-l" )

#for((i=0; i<=4; i++))
#do
    # logger -s "Small file test Iteration $i started" 2>> $LogFile
    logger -s "'date' Итерация $i small test file начата" 2>> $LogFile

    for ((j=0; j<${#Operations[@]} ; j++))
    do

        #logger -s "`date` operation $j started" 2>> $LogFile
        logger -s "`date` Операция ${Operations[j]} начата" 2>> $LogFile

        ansible-playbook -i hosts sync-and-drop-cache.yml > /dev/null
#        python /small-files/smallfile/smallfile_cli.py --operation ${Operations[$j]} --threads 8 --file-size 64 --files 5000 --top /gluster-mount  --host-set "$(echo $CLIENT | tr -d "[] \'")"
	#python /small-files/smallfile/smallfile_cli.py --operation ${Operations[$j]} --threads 2 --file-size 64 --files 100 --top /gluster-mount  --host-set "$(echo $CLIENT | tr -d "[] \'" | cut -c2- )"

	python /small-files/smallfile/smallfile_cli.py --operation ${Operations[$j]} --threads 2 --file-size 64 --files 100 --top /gluster-mount  --host-set "$(echo ${CLIENT//u\'/} | tr -d "[] \'" )"

        ssh root@$ServerNode "gluster volume profile testvol info incremental  >> /root/${Operations[$j]}-profile-fuse.txt"
    done
#done

mkdir -p /root/fuse-smallfile-profile
cd /root/

logger -s "`date` Собираем логи" 2>> $LogFile
# Collect the Server logs
ssh root@$ServerNode "gluster volume info  > /root/volume-info.txt"
scp root@$ServerNode:/root/*.txt /root/fuse-smallfile-profile/
tar cf fuse-smallfile-profile.tar fuse-smallfile-profile
ssh root@$ServerNode "echo Testover  >> /var/log/PerfTest.log  2>&1"
ssh root@$ServerNode "date >> /var/log/PerfTest.log  2>&1"
scp root@$ServerNode:/var/log/PerfTest.log /root/

# Log the client config
echo "Client Data сбор collect-info закоментировал : " >> /root/PerfTest.log
#/root/collect-info.sh >> /root/PerfTest.log
