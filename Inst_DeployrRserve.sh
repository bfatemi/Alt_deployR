########################################################################
# Install DeployrRserve
########################################################################

deployrRserve="https://github.com/deployr/deployr-rserve/releases/download/v7.4.2/deployrRserve_7.4.2.tar.gz"
wget $deployrRserve
R CMD INSTALL deployrRserve_7.4.2.tar.gz

