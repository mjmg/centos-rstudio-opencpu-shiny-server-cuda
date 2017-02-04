FROM mjmg/centos-rstudio-opencpu-shiny-server

LABEL com.nvidia.volumes.needed="nvidia_driver"

RUN NVIDIA_GPGKEY_SUM=d1be581509378368edeec8c1eb2958702feedf3bc3d17011adbf24efacce4ab5 && \
    curl -fsSL  http://developer.download.nvidia.com/compute/cuda/repos/fedora23/x86_64/7fa2af80.pub  | sed '/^Version/d' > /etc/pki/rpm-gpg/RPM-GPG-KEY-NVIDIA && \
    echo "$NVIDIA_GPGKEY_SUM  /etc/pki/rpm-gpg/RPM-GPG-KEY-NVIDIA" | sha256sum -c --strict -

COPY cuda.repo /etc/yum.repos.d/cuda.repo

ENV CUDA_VERSION 8.0
LABEL com.nvidia.cuda.version="8.0"

ENV CUDA_PKG_VERSION 8-0-8.0.44-1
RUN yum install -y \
        cuda-nvrtc-$CUDA_PKG_VERSION \
        cuda-nvgraph-$CUDA_PKG_VERSION \
        cuda-cusolver-$CUDA_PKG_VERSION \
        cuda-cublas-$CUDA_PKG_VERSION \
        cuda-cufft-$CUDA_PKG_VERSION \
        cuda-curand-$CUDA_PKG_VERSION \
        cuda-cusparse-$CUDA_PKG_VERSION \
        cuda-npp-$CUDA_PKG_VERSION \
        cuda-cudart-$CUDA_PKG_VERSION && \
    ln -s cuda-$CUDA_VERSION /usr/local/cuda && \
    rm -rf /var/cache/yum/*

RUN echo "/usr/local/cuda/lib" >> /etc/ld.so.conf.d/cuda.conf && \
    echo "/usr/local/cuda/lib64" >> /etc/ld.so.conf.d/cuda.conf && \
    echo "/usr/local/cuda/lib64/stubs" >> /etc/ld.so.conf.d/cuda.conf && \
    echo "/usr/local/cuda/targets/x86_64-linux/lib/" >> /etc/ld.so.conf.d/cuda.conf && \
    ldconfig

RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf && \
    ldconfig

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH} && \
    ldconfig

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


ENV CUDNN_VERSION 5
LABEL com.nvidia.cudnn.version="5"

RUN CUDNN_DOWNLOAD_SUM=c10719b36f2dd6e9ddc63e3189affaa1a94d7d027e63b71c3f64d449ab0645ce && \
    curl -fsSL http://developer.download.nvidia.com/compute/redist/cudnn/v5.1/cudnn-8.0-linux-x64-v5.1.tgz -O && \
    echo "$CUDNN_DOWNLOAD_SUM  cudnn-8.0-linux-x64-v5.1.tgz" | sha256sum -c --strict - && \
    tar -xzf cudnn-8.0-linux-x64-v5.1.tgz -C /usr/local --wildcards 'cuda/lib64/libcudnn.so.*' && \
    rm cudnn-8.0-linux-x64-v5.1.tgz && \
    ldconfig

RUN \
    ln -s /usr/local/cuda/lib64/libOpenCL.so /usr/lib64/libOpenCL.so

ENV LIBRARY_PATH /usr/local/cuda/lib64/:/usr/local/cuda/lib64/stubs:${LIBRARY_PATH} && \
    ldconfig
ENV CUDA_HOME /usr/local/cuda/
ENV OPENCL_LIB /usr/local/cuda/lib64/

#install additional tools and library prerequisites for additional packages
RUN \
  yum install -y opencl-headers mesa-libGL-devel mysql-devel

# install additional packages
ADD \
  gputools_1.1.tar.gz /tmp/gputools_1.1.tar.gz


ADD \
  installRcudapackages.sh /usr/local/bin/installRcudapackages.sh
RUN \
  chmod +x /usr/local/bin/installRcudapackages.sh && \
  /usr/local/bin/installRcudapackages.sh

USER shiny

RUN \
  rm -Rv /srv/shiny-server/apps && \
  rm -Rv /srv/shiny-server/rmd && \
  #mkdir /home/shiny/shiny-server/ && \
  ln  /home/shiny/shiny-server/apps /srv/shiny-server/apps -s && \
  ln  /home/shiny/shiny-server/rmd /srv/shiny-server/rmd -s

USER root

# Define default command.
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]
