FROM mjmg/centos-rstudio-opencpu-shiny-server

# Setup NVIDIA CUDA runtime
# From https://gitlab.com/nvidia/cuda/blob/centos7/8.0/runtime/Dockerfile
# LABEL maintainer "NVIDIA CORPORATION <cudatools@nvidia.com>"

RUN NVIDIA_GPGKEY_SUM=d1be581509378368edeec8c1eb2958702feedf3bc3d17011adbf24efacce4ab5 && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/7fa2af80.pub | sed '/^Version/d' > /etc/pki/rpm-gpg/RPM-GPG-KEY-NVIDIA && \
    echo "$NVIDIA_GPGKEY_SUM  /etc/pki/rpm-gpg/RPM-GPG-KEY-NVIDIA" | sha256sum -c --strict -

COPY cuda.repo /etc/yum.repos.d/cuda.repo

ENV CUDA_VERSION 8.0.61

ENV CUDA_PKG_VERSION 8-0-$CUDA_VERSION-1

RUN yum install -y \
        cuda-nvrtc-$CUDA_PKG_VERSION \
        cuda-nvgraph-$CUDA_PKG_VERSION \
        cuda-cusolver-$CUDA_PKG_VERSION \
        cuda-cublas-8-0-8.0.61.2-1 \
        cuda-cufft-$CUDA_PKG_VERSION \
        cuda-curand-$CUDA_PKG_VERSION \
        cuda-cusparse-$CUDA_PKG_VERSION \
        cuda-npp-$CUDA_PKG_VERSION \
        cuda-cudart-$CUDA_PKG_VERSION && \
    ln -s cuda-8.0 /usr/local/cuda && \
    rm -rf /var/cache/yum/*

# nvidia-docker 1.0
LABEL com.nvidia.volumes.needed="nvidia_driver"
LABEL com.nvidia.cuda.version="${CUDA_VERSION}"

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}

# Library Path at RUN time
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES all
#compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=8.0"

# Setup NVIDIA CUDA devel
# From https://gitlab.com/nvidia/cuda/blob/centos7/8.0/devel/Dockerfile
RUN yum install -y \
        cuda-core-$CUDA_PKG_VERSION \
        cuda-misc-headers-$CUDA_PKG_VERSION \
        cuda-command-line-tools-$CUDA_PKG_VERSION \
        cuda-license-$CUDA_PKG_VERSION \
        cuda-nvrtc-dev-$CUDA_PKG_VERSION \
        cuda-nvml-dev-$CUDA_PKG_VERSION \
        cuda-nvgraph-dev-$CUDA_PKG_VERSION \
        cuda-cusolver-dev-$CUDA_PKG_VERSION \
        cuda-cublas-dev-$CUDA_PKG_VERSION \
        cuda-cufft-dev-$CUDA_PKG_VERSION \
        cuda-curand-dev-$CUDA_PKG_VERSION \
        cuda-cusparse-dev-$CUDA_PKG_VERSION \
        cuda-npp-dev-$CUDA_PKG_VERSION \
        cuda-cudart-dev-$CUDA_PKG_VERSION \
        cuda-driver-dev-$CUDA_PKG_VERSION && \
    rm -rf /var/cache/yum/*

# Configure NVIDIA/CUDA OpenCL settings
RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

RUN \
    ln -s /usr/local/cuda/lib64/libOpenCL.so /usr/lib64/libOpenCL.so 

# Library Path at BUILD time
ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs:${LIBRARY_PATH}

#RUN \
#  ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/libcuda.so.1 && \
#  ldconfig

ENV CUDA_HOME /usr/local/cuda
ENV OPENCL_LIB /usr/local/cuda/lib64/

#install additional tools and library prerequisites for additional packages
RUN \
  yum install -y opencl-headers mesa-libGL-devel mysql-devel

# install additional packages
WORKDIR /tmp

ADD \
  installRcudapackages.sh /tmp/installRcudapackages.sh
RUN \
  chmod +x /tmp/installRcudapackages.sh && \
  sync && \
  /tmp/installRcudapackages.sh


USER shiny

RUN \
  rm -Rv /srv/shiny-server/apps && \
  rm -Rv /srv/shiny-server/rmd && \
  ln  /home/shiny/R/shiny-server/apps /srv/shiny-server/ -s && \
  ln  /home/shiny/R/shiny-server/rmd /srv/shiny-server/ -s

USER root

# Define default command.
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]

