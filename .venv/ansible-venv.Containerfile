FROM registry.fedoraproject.org/fedora-toolbox
# Sets up the repo and gpg keys needed to install VSCodium
# RUN rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
# RUN printf "[gitlab.com_paulcarroty_vscodium_repo]\nname=download.vscodium.com\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg\nmetadata_expire=1h\n" | tee -a /etc/yum.repos.d/vscodium.repo


# Update all packages
RUN dnf --assumeyes update
# Install all the necessary tools and packages
RUN dnf --assumeyes install ansible \
    ansible-lint \
    git
    # codium
# Install VSCodium's Ansible Extension for development
# RUN useradd -m devuser
# USER devuser
# RUN codium --install-extension redhat.ansible