echo "Start creating starcenter clusters!"
ansible-playbook cluster_build_starcenter.yml -v
echo "Start creating vegafoodies clusters!"
ansible-playbook cluster_build_vegafoodies.yml -v
echo "Start creating AIM clusters!"
ansible-playbook cluster_build_AIM.yml -v
echo "BUILDING CLUSTERS DONE!"
