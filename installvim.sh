#cd /
#git clone https://github.com/avriltank/neovimplugin

sudo yum-config-manager --add-repo=https://copr.fedorainfracloud.org/coprs/carlwgeorge/ripgrep/repo/epel-7/carlwgeorge-ripgrep-epel-7.repo
sudo yum install ripgrep


sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/pathogen.vim --create-dirs \
       https://tpo.pe/pathogen.vim'
chmod 777 /neovim/nvim
mkdir -p ~/.config/nvim
cp /neovimplugin/init.vim  ~/.config/nvim/init.vim
