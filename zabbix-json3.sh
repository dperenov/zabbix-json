#!/bin/bash
### Получить groupid ###

#curl -s -X POST -H 'Content-Type: application/json' -d`
#`'{"jsonrpc": "2.0","method": "hostgroup.get",
#"params": {"output": "extend", "filter": { "name": [ "PROD SAP SYSTEMS" ] } },
#"auth": "e902593e18f6e786031c944c057773f9","id": 1 }' http://172.22.140.240/zabbix/api_jsonrpc.php | jq -r '.result[]'
### / Получить groupid ###

## Массив для отчета НАК ##
nakarray=("sapbackup1.kazatomprom.kz" "saprouter.kazatomprom.kz" "sapbwnodedb1.kazatomprom.kz" "sapbwnodeas1.kazatomprom.kz" "sapprderpdb.kazatomprom.kz" "sapprderpdia3.kazatomprom.kz" "sapprderpas.kazatomprom.kz" "sapprderpdia2.kazatomprom.kz" "sapprderpdia1.kazatomprom.kz" "sapprdgrcdb.kazatomprom.kz" "sapprdgrcas.kazatomprom.kz" "saphcmnodedb1.kazatomprom.kz" "saphcmnodeas1.kazatomprom.kz" "sapprdadsdb.kazatomprom.kz" "sapprdadsas.kazatomprom.kz" "sapppmnodedb1.kazatomprom.kz" "sapppmnodeas1.kazatomprom.kz" "sapprdsmas.kazatomprom.kz" "sapprdsmdb.kazatomprom.kz" "sapbackup2.kazatomprom.kz")
## / Массив для отчета НАК ##

hostids=()
for nakid in ${nakarray[@]}; do
nakarrayids=($(curl -s -X POST -H 'Content-Type: application/json' -d`
`'{"jsonrpc": "2.0","method": "host.get",
"params": {"filter": { "host": ["'"$nakid"'"] },"sortfield": "name" },
"auth": "e902593e18f6e786031c944c057773f9","id": 1 }' http://172.22.140.240/zabbix/api_jsonrpc.php | jq -r '.result[].hostid'))
hostids+=( $nakarrayids )
done
echo ${hostids[@]}


for nakname in ${nakarray[@]}; do
nakarrayname=($(curl -s -X POST -H 'Content-Type: application/json' -d`
`'{"jsonrpc": "2.0","method": "host.get",
"params": {"filter": { "host": ["'"$nakname"'"] },"sortfield": "name" },
"auth": "e902593e18f6e786031c944c057773f9","id": 1 }' http://172.22.140.240/zabbix/api_jsonrpc.php | jq -r '.result[].host'))
echo $nakarrayname
done



### Получить hostid по groupid ###
#hostids=($(curl -s -X POST -H 'Content-Type: application/json' -d`
#`'{"jsonrpc": "2.0","method": "host.get",
#"params": {"output": ["hostid"], "groupids":"15", "sortfield": "hostid"},
#"auth": "e902593e18f6e786031c944c057773f9","id": 1 }' http://172.22.140.240/zabbix/api_jsonrpc.php | jq -r '.result[].hostid'))
#echo ${hostids[@]}
### /Получить hostid по groupid ###

### Для теста визуализация ###
#curl -s -X POST -H 'Content-Type: application/json' -d`
#`'{"jsonrpc": "2.0","method": "host.get",
#"params": {"output": ["hostid","host"], "groupids":"15"},
#"auth": "e902593e18f6e786031c944c057773f9","id": 1 }' http://172.22.140.240/zabbix/api_jsonrpc.php | jq -r '.result[].host'
### /Для теста визуализация ###

### Получить itemid для каждого хоста(available memory) ###
newitemID=()
for itemid in ${hostids[@]}; do
	itemids=$(curl -s -H 'Content-Type: application/json' -d`
	`'{"jsonrpc": "2.0","method": "item.get",
	"params": {"output": "extend", "hostids":"'"$itemid"'","search": {"key_": "vm.memory.size[available]"},"sortfield": "name"},
	"auth": "e902593e18f6e786031c944c057773f9","id": 1 }' http://172.22.140.240/zabbix/api_jsonrpc.php | jq -r '.result[].itemid')
        newitemID+=( $itemids ) 
done
echo ${newitemID[@]}
### / Получить itemid для каждого хоста(available memory) ###

### Получить itemid для каждого хоста(total memory) ###
totalmemorys=()
for totalmemory in ${hostids[@]}; do
	totalmemoryvalue=$(curl -s -X POST -H 'Content-Type: application/json' -d`
	`'{"jsonrpc": "2.0", "method": "item.get",
	"params": {"output":"extend", "hostids":"'"$totalmemory"'", "search": {"key_": "vm.memory.size[total]"}, "sortfield": "name"},
	"auth": "e902593e18f6e786031c944c057773f9","id": 1 }' http://172.22.140.240/zabbix/api_jsonrpc.php | jq -r '.result[].lastvalue|tonumber')
	totalmemoryvalue=$(echo "scale=2;$totalmemoryvalue / 1024 / 1024 / 1024" | bc)
        totalmemorys+=( $totalmemoryvalue )
done
echo ${totalmemorys[@]}

### / Получить itemid для каждого хоста(total memory) ###


### Хуйня может пригодиться ###
#newhistoryval=()
#for historyID in ${newitemID[@]}; do
#	historyids=$(curl -s -X POST -H 'Content-Type: application/json' -d`
#	`'{"jsonrpc": "2.0","method": "history.get",
#	"params": {"output":"extend", "itemids":"'"$historyID"'","time_from":"1581930000","time_till":"1582045200"},
#	"auth": "e902593e18f6e786031c944c057773f9","id":1 }' http://172.22.140.240/zabbix/api_jsonrpc.php | jq -sr '.|.[].result|
#	map(to_entries)|add|group_by(.key)|map({key: .[0].key, value: map(.value)})|.[3]|.value|map(. | tonumber) | add') 
#	newhistoryval+=( $historyids )
#        echo ${newhistoryval[@]}
#done
#echo ${#newhistoryval[@]}
### /Хуйня может пригодиться ###

### Получить historyid по itemid для каждого хоста ###
newhistoryval=()
for historyID in ${newitemID[@]}; do
	historyids=$(curl -s -X POST -H 'Content-Type: application/json' -d`
	`'{"jsonrpc": "2.0","method": "trend.get",
	"params": {"output":"extend", "itemids":"'"$historyID"'","time_from":"1580515260","time_till":"1581984060"},
	"auth": "e902593e18f6e786031c944c057773f9","id":1 }' http://172.22.140.240/zabbix/api_jsonrpc.php | jq -sr '.|.[].result |
	map(to_entries)|add|group_by(.key)|map({key: .[0].key, value: map(.value)})|.[3]|.value as $values1 | ($values1|map(.|tonumber)|add)/($values1 | length)')
	historyids=$(echo "scale=2;$historyids / 1024 / 1024 / 1024" | bc)
#	echo $historyids 
	newhistoryval+=( $historyids )
done
echo ${newhistoryval[@]}
#map(to_entries)|add|group_by(.key)|map({key: .[0].key, value: map(.value)})|.[3]|.value|map(. | tonumber) | add'

### / Получить historyid по itemid для каждого хоста ###


### Использованный memory в % ###
k=0
while [ $k -lt ${#totalmemorys[@]} ]
do
f=(${newhistoryval["$k"]})
g=(${totalmemorys["$k"]})
h=$(echo "scale=2;$g - $f" | bc)
i=$(echo "scale=2;($h * 100) / $g" | bc)
echo $i
k=$[ $k + 1 ]
done
### / Использованный memory в % ###

cpunewitemID=()
for cpuitemid in ${hostids[@]}; do
        cpuitemids=$(curl -s -H 'Content-Type: application/json' -d`
        `'{"jsonrpc": "2.0","method": "item.get",
        "params": {"output": "extend", "hostids":"'"$cpuitemid"'","search": {"key_": "system.cpu.util[,idle]"},"sortfield": "name" },
        "auth": "e902593e18f6e786031c944c057773f9","id": 1 }' http://172.22.140.240/zabbix/api_jsonrpc.php | jq -r '.result[].itemid')
##        cpunewitemID+=( $cpuitemids )
##	cpuhistoryval=()
	for cpuhistoryID in $cpuitemids; do
        	cpuhistoryids=$(curl -s -X POST -H 'Content-Type: application/json' -d`
        	`'{"jsonrpc": "2.0","method": "trend.get",
        	"params": {"output":"extend", "itemids": "'"$cpuhistoryID"'","time_from":"1580515260","time_till":"1581984060"},
        	"auth": "e902593e18f6e786031c944c057773f9","id":0 }' http://172.22.140.240/zabbix/api_jsonrpc.php | jq -sr '.|.[].result|
        	map(to_entries)|add|group_by(.key)|map({key: .[0].key, value: map(.value)})|.[3]|.value as $values2 | ($values2|map(.|tonumber)|add)/($values2 | length)')
		cpuhistoryids=$(echo "scale=2; 100-($cpuhistoryids)"| bc)
		echo $cpuhistoryids
	done

done
echo ${cpunewitemID[@]}


for diskid in ${hostids[@]}; do
	diskitemids=$(curl -s -H 'Content-Type: application/json' -d`
        `'{"jsonrpc": "2.0","method": "item.get",
        "params": {"history": 0, "output": "extend", "hostids": "'"$diskid"'","search": {"key_": "last-space"},"sortfield": "name"},
        "auth": "e902593e18f6e786031c944c057773f9","id": 1 }' http://172.22.140.240/zabbix/api_jsonrpc.php | jq -r '.result[].lastvalue')
	echo $diskitemids
done


#curl -s -H 'Content-Type: application/json' -d`
#`'{"jsonrpc": "2.0","method": "item.get",
#"params": {"history": 0, "output": "extend", "hostids": "10277","search": {"key_": "last-space"},"sortfield": "name"},
#"auth": "e902593e18f6e786031c944c057773f9","id": 1 }' http://172.22.140.240/zabbix/api_jsonrpc.php | jq -r '.result[]'


#cpuhistoryval=()
#for cpuhistoryID in ${cpunewitemID[@]}; do
#	cpuhistoryids=$(curl -s -X POST -H 'Content-Type: application/json' -d`
#	`'{"jsonrpc": "2.0","method": "history.get",
#	"params": {"history":0, "output":"extend", "itemids": "'"$cpuhistoryID"'","time_from":"1580515260","time_till":"1581984060"},
#	"auth": "e902593e18f6e786031c944c057773f9","id":0 }' http://172.22.140.240/zabbix/api_jsonrpc.php | jq -sr '.|.[].result|
#	map(to_entries)|add|group_by(.key)|map({key: .[0].key, value: map(.value)})|.[3]|.value as $values2 | ($values2|map(.|tonumber)|add)/($values2 | length)')
#	cpuhistoryids1=$(echo "scale=2; 100-($cpuhistoryids)" | bc)
#	cpuhistoryval+=( $cpuhistoryids )
#	echo $cpuhistoryids1	
#done
#printf '%s\n' "${cpuhistoryval[@]}"


#curl -s -X POST -H 'Content-Type: application/json' -d`
#	`'{"jsonrpc": "2.0","method": "history.get",
#	"params": {"history":0, "output":"extend", "itemids": "31081","time_from":"1580515260","time_till":"1581984060"},
#	"auth": "e902593e18f6e786031c944c057773f9","id":0 }' http://172.22.140.240/zabbix/api_jsonrpc.php | jq -sr '.|.[].result|
#	map(to_entries)|add|group_by(.key)|map({key: .[0].key, value: map(.value)})|.[3]|.value as $values2 | ($values2|map(.|tonumber)|add)/($values2 | length)'
