GREEN='\033[1;32m'
NC='\033[0m'


echo -e "\nredhat-operator-index / certified-operator-index / community-operator-index"
read operator_type
echo -e "${GREEN}operator_type -> $operator_type${NC}\n"

echo "Enter openshift major version for example v4.9"
read ocp_ver
echo -e "${GREEN}ocp_ver -> $ocp_ver${NC}\n"

echo "Enter operator name"
read operator_tmp_name
echo -e "${GREEN}operator_tmp_name -> $operator_tmp_name${NC}\n"


mkdir data
[ ! -f /usr/bin/podman ] && yum install -y podman
if [ ! -f /usr/bin/opm ]
then
	wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/opm-linux.tar.gz
	tar -zxvf opm-linux.tar.gz -C /usr/bin
	rm -f opm-linux.tar.gz
fi
if [ ! -f /usr/bin/oc ]
then
        wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/openshift-client-linux.tar.gz
        tar -zxvf openshift-client-linux.tar.gz -C /usr/bin
        rm -f openshift-client-linux.tar.gz /usr/bin/README.md
fi
if [ ! -f /usr/bin/grpcurl ]
then
        wget https://github.com/fullstorydev/grpcurl/releases/download/v1.8.6/grpcurl_1.8.6_linux_x86_64.tar.gz
        tar -zxvf grpcurl_1.8.6_linux_x86_64.tar.gz -C /usr/bin
        rm -f grpcurl_1.8.6_linux_x86_64.tar.gz /usr/bin/LICENSE
fi


podman image trust set -t accept registry.redhat.io/redhat/$operator_type:$ocp_ver

podman run -itd \
	--name index-registry \
	-p 50051:50051 \
	registry.redhat.io/redhat/$operator_type:$ocp_ver

podman run -d \
	--name local-registry \
	-p 5000:5000 \
	-v ./data:/var/lib/registry:z \
	docker.io/library/registry:2

sleep 5


grpcurl -plaintext localhost:50051 api.Registry/ListPackages > packages.out
cat packages.out
operator_name=`grep $operator_tmp_name packages.out | awk '{print $2}' | sed 's/\"//g'`
rm -f packages.out
echo -e "${GREEN}OPERATOR FOUND -> $operator_name${NC}\n"


opm index prune -f registry.redhat.io/redhat/$operator_type:$ocp_ver -p $operator_name -t localhost:5000/index-image/$operator_name:$ocp_ver

podman push localhost:5000/index-image/$operator_name:$ocp_ver --tls-verify=false

oc adm catalog mirror localhost:5000/index-image/$operator_name:$ocp_ver localhost:5000/olm --insecure


podman rm -f index-registry
podman rm -f local-registry

mv manifest* data
mv data $operator_name
