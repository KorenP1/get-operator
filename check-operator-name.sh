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


[ ! -f /usr/bin/podman ] && yum install -y podman
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

sleep 5


grpcurl -plaintext localhost:50051 api.Registry/ListPackages > packages.out
cat packages.out
operator_name=`grep $operator_tmp_name packages.out | awk '{print $2}' | sed 's/\"//g'`
rm -f packages.out
echo -e "${GREEN}OPERATOR FOUND -> $operator_name${NC}\n"


podman rm -f index-registry
