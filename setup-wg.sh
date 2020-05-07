sudo apt update
sudo apt -y upgrade
sudo apt-add-repository -y ppa:wireguard/wireguard
sudo apt update
sudo apt -y install wireguard git

git clone ${REPO_URL} setup-scripts

cd setup-scripts
cp wg-manage.sh 
