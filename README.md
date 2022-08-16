# get-operator
Get OpenShift Operators on unrestriced network machine

# Make sure you're on a rhel machine
# Make sure you have enough space on the machine (about 50GB) (if you're using partitions, you need at least 5GB at /var and 45GB at /)
# Make sure to run the scripts as root

podman login to the registries with the next commands:
	podman login registry.redhat.io
	podman login quay.io
	podman login registry.connect.redhat.com

There are 3 environment variables:
	1. operator_type ( redhat-operator-index / certified-operator-index / community-operator-index )
	2. ocp_ver (Major OpenShift version)
	3. operator_name (The name of the wanted operator)

Variables 1 and 2 can be changed through the script first lines with vim or vi
Variable 3 will be asked through the script

! If you don't know the exact name of the operator it's ok, we use grep finding inside the code
! Another option for finding the operator name is using the "check_operator_name" script

FOR SUMMARY JUST CHANGE 2 VARIABLES INSIDE THE SCRIPT AND RUN IT AS ROOT

GOOD LUCK
THANK YOU :)
