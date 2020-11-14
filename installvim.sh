#cd /
#git clone https://github.com/avriltank/neovimplugin

sudo yum -y install yum-utils
sudo yum-config-manager --add-repo=https://copr.fedorainfracloud.org/coprs/carlwgeorge/ripgrep/repo/epel-7/carlwgeorge-ripgrep-epel-7.repo
sudo yum install ripgrep

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
source ~/.bashrc

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/pathogen.vim --create-dirs \
       https://tpo.pe/pathogen.vim'

yum --enablerepo=epel -y install fuse-sshfs # install from EPEL
user="$(whoami)"
usermod -a -G fuse "$user" 

chmod 777 /neovimplugin/nvim
echo 'export PATH=$PATH:/neovimplugin' >> /etc/profile
source /etc/profile

mkdir -p ~/.config/nvim
cp /neovimplugin/init.vim  ~/.config/nvim/init.vim
