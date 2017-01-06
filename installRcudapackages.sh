#!/bin/sh

# This installs R packages from github
#echo "Installing eddelbuettel/bh from github"
#Rscript -e "library(devtools); install_github('eddelbuettel/bh')"
#echo "Installing cdeterman/gpuR from github"
#Rscript -e "library(devtools); install_github('cdeterman/gpuR')"


echo "Installing Biobase from Bioconductor"
Rscript -e "source('https://bioconductor.org/biocLite.R'); biocLite('Biobase')"

# This installs R packages in CRAN
#echo "Installing gcbd from CRAN"
#Rscript -e "install.packages('gcbd')"
#echo "Installing gpuR from CRAN"
#Rscript -e "install.packages('gpuR')"
echo "Installing BH from CRAN"
Rscript -e "install.packages('BH')"
echo "Installing cudaBayesreg from CRAN"
Rscript -e "install.packages('cudaBayesreg')"
echo "Installing permGPU from CRAN"
Rscript -e "install.packages('permGPU')"
echo "Installing snowfall from CRAN"
Rscript -e "install.packages('snowfall')"
echo "Installing data.table from CRAN"
Rscript -e "install.packages('data.table')"
echo "Installing bit64 from CRAN"
Rscript -e "install.packages('bit64')"
echo "Installing gpuR from CRAN"
Rscript -e "install.packages('gpuR', configure.args ='--with-cuda-home=$CUDA_HOME', INSTALL_opts='--no-test-load')"

echo "Installing gmatrix from CRAN"
Rscript -e "install.packages('gmatrix', configure.args ='--with-cuda-home=$CUDA_HOME', INSTALL_opts='--no-test-load')"


#echo "Installing gpuR from source"
#Rscript -e "library(devtools); install_local('/tmp/gpuR_1.1.2.tar.gz', 'gpuR')"
echo "Installing gputools from source"
Rscript -e "library(devtools); install_local('/tmp/gputools_1.1.tar.gz', 'gputools')"
echo "Installing bigWig from github"
Rscript -e "library(devtools); install_github('mjmg/bigWig')"
echo "Installing dREG from source"
Rscript -e "library(devtools); install_github('mjmg/dREG')"
echo "Installing Rgtsvm from source"
Rscript -e "library(devtools); install_github('mjmg/Rgtsvm', args='--configure-args=--with-boost-home=/usr/lib64/R/library/BH')"
#Rscript -e "library(devtools); install_local('/tmp/Rgtsvm.tar.gz', '--configure-args=--with-boost-home=/usr/lib64/R/library/BH', 'Rgtsvm')"
#Rscript -e "library(devtools); install_local('/tmp/Rgtsvm.tar.gz', 'Rgtsvm')"
