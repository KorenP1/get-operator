echo "redhat-operator-index / certified-operator-index / community-operator-index"
read operator_type
echo "operator_type: $operator_type"

echo "Enter openshift major version for example v4.9"
read ocp_ver
echo "ocp_ver: $ocp_ver"

echo "Enter name of operator"
read operator_tmp_name
echo "operator_tmp_name: $operator_tmp_name"

[ ! -f /usr/bin/podman ] && yum install -y podman
if [ ! -f /usr/bin/opm ]
then
	wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/opm-linux.tar.gz
	tar -zxvf opm-linux.tar.gz
	rm -f opm-linux.tar.gz
	mv opm /usr/bin/opm
fi
if [ ! -f /usr/bin/grpcurl ]
then
        wget https://github.com/fullstorydev/grpcurl/releases/download/v1.8.6/grpcurl_1.8.6_linux_x86_64.tar.gz
        tar -zxvf grpcurl_1.8.6_linux_x86_64.tar.gz
        rm -f grpcurl_1.8.6_linux_x86_64.tar.gz
        mv grpcurl /usr/bin/grpcurl
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
echo "OPERATOR FOUND: $operator_name"


podman rm -f index-registry

rm -f packages.out
