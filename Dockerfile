FROM debian:buster AS solvers

ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Setup system
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
      wget unzip curl \
      git \
      gcc g++ \
      make cmake autoconf gperf patch file \
      default-jre \
      python2.7-dev python-sympy \
      libgmp-dev libffi6 \
      libboost-program-options-dev libboost-iostreams-dev \
      libboost-test-dev libboost-thread-dev libboost-system-dev \
      libreadline-dev flex bison automake libtool \
      libedit-dev libreadline-dev

WORKDIR /downloads

# Install Z3 4.8.8
RUN wget --quiet https://github.com/Z3Prover/z3/releases/download/z3-4.8.8/z3-4.8.8-x64-ubuntu-16.04.zip
RUN unzip z3*.zip
RUN cp z3-*/bin/z3      /usr/local/bin/
RUN cp z3-*/bin/libz3.* /usr/local/lib/
RUN cp z3-*/include/*   /usr/local/include/

# Install Yices 2.6.2
RUN wget --quiet https://yices.csl.sri.com/releases/2.6.2/yices-2.6.2-x86_64-pc-linux-gnu-static-gmp.tar.gz
RUN tar xvf yices*.tar.gz
RUN cd yices* && ./install-yices /usr/local

# Install CVC4 1.8
RUN wget --quiet https://github.com/CVC4/CVC4/releases/download/1.8/cvc4-1.8-x86_64-linux-opt
RUN chmod +x cvc4* && cp cvc4* /usr/local/bin && ln -s /usr/local/bin/cvc4-* /usr/local/bin/cvc4

# Build abc from GitHub. (Latest version.)
RUN git clone https://github.com/berkeley-abc/abc.git
RUN cd abc && make -j
RUN cp abc/abc /usr/local/bin

# Build Boolector release 3.2.1 from source
RUN wget --quiet https://github.com/Boolector/boolector/archive/3.2.1.tar.gz -O boolector-3.2.1
RUN tar xvf boolector*
RUN cd boolector* && ./contrib/setup-lingeling.sh && ./contrib/setup-btor2tools.sh && ./configure.sh && cd build && make -j
RUN cp boolector*/build/bin/boolector /usr/local/bin

# Build opensmt from GitHub (Latest version)
RUN git clone -b master https://github.com/usi-verification-and-security/opensmt.git
RUN cd opensmt && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DPRODUCE_PROOF=ON .. && \
    make && \
    make install


# Build cudd 3.0.0.0
RUN wget --quiet https://davidkebo.com/source/cudd_versions/cudd-3.0.0.tar.gz
RUN tar xvf cudd*
RUN cd cudd* && ./configure --enable-shared && make -j && make install

# Build libpoly 0.1.8
RUN wget --quiet https://github.com/SRI-CSL/libpoly/archive/v0.1.8.tar.gz -O libpoly-0.1.8.tar.gz
RUN tar xvf libpoly*
RUN cd libpoly*/build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j && \
    make install

# Build Sally (current version?)
RUN wget --quiet https://github.com/SRI-CSL/sally/tarball/master -O sally-master.tar.gz
RUN tar xvf sally-*
RUN cd SRI-CSL-sally*/build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j && \
    make install

RUN useradd -m solvers && chown -R solvers:solvers /home/solvers
USER solvers
WORKDIR /home/solvers
