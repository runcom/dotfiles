p() { cd $PROJECTS/$1; }
_p() { _files -W $PROJECTS -/; }
compdef _p p

vmip() {
	dirname $(sudo virsh domifaddr $1 --full | tail -n +3 | awk '{ print $4  }')
}

custom-golang() {
	export GOROOT=/usr/local/go
	export PATH=$GOROOT/bin:$PATH
	# use system golang to build golang itself
	export GOROOT_BOOTSTRAP=/usr/lib/golang
}

docker-test() {
	if [ -z "$1" ]; then
		echo "No test specified"
		return
	fi
	if [[ ! -z "$2" ]] && [[ "$2" == "-race" ]]; then
		local race="-race"
	fi
	(
	DOCKER_EXECDRIVER=$DOCKER_EXECDRIVER DOCKER_EXPERIMENTAL=$DOCKER_EXPERIMENTAL TESTFLAGS="$race -check.f $1" make test-integration-cli
	)
}

irssi() {
	ssh rhshell -Xt screen -aAdr -RR irssi irssi
}

irssi_clean() {
	ssh rhshell echo "" > ~/.irssi/fnotify
}

backup_irssi() {
	scp -r rhshell:~/.irssi/ irssi && tar cvzf irssi.tar irssi && rm -rf irssi
}

docker-compile() {
	sudo systemctl stop docker
	docker-compile-deps
	# disable experimental
	#AUTO_GOPATH=1 BUILDFLAGS="-race" DOCKER_BUILDTAGS="seccomp experimental selinux journald exclude_graphdriver_btrfs exclude_graphdriver_zfs exclude_graphdriver_aufs" ./hack/make.sh dynbinary
	AUTO_GOPATH=1 BUILDFLAGS="-race" DOCKER_BUILDTAGS="seccomp selinux journald exclude_graphdriver_btrfs exclude_graphdriver_zfs exclude_graphdriver_aufs" ./hack/make.sh dynbinary
	if [ -e "bundles/latest/dynbinary/docker" ]; then
		sudo cp bundles/latest/dynbinary/docker /usr/bin/docker-current
	else
		sudo cp bundles/latest/dynbinary-client/docker /usr/bin/docker-current
		sudo cp bundles/latest/dynbinary-daemon/dockerd /usr/bin/dockerd-current
	fi
	echo "now call sudo systemctl restart docker"
}

rkt-compile() {
	./configure --with-stage1-flavors=host --with-stage1-default-location=/usr/libexec/rkt/stage1-host.aci && make all
}

docker-compile-deps() {
	#set -e
	set -x

	old_gopath="${GOPATH}"

	RUNC_COMMIT=""
	CONTAINERD_COMMIT=""

	dockerfile_path="${GOPATH}/src/github.com/docker/docker/hack/dockerfile/binaries-commits"
	if [ -e "$dockerfile_path" ]; then
		RUNC_COMMIT=$(grep RUNC_COMMIT $dockerfile_path | head -n 1 | cut -d"=" -f 2)
		CONTAINERD_COMMIT=$(grep CONTAINERD_COMMIT $dockerfile_path | head -n 1 | cut -d"=" -f 2)
		TINI_COMMIT=$(grep TINI_COMMIT $dockerfile_path | head -n 1 | cut -d"=" -f 2)
		LIBNETWORK_COMMIT=$(grep LIBNETWORK_COMMIT $dockerfile_path | head -n 1 | cut -d"=" -f 2)
	else
		dockerfile_path="${GOPATH}/src/github.com/docker/docker/Dockerfile"
		RUNC_COMMIT=$(grep RUNC_COMMIT $dockerfile_path | head -n 1 | cut -d" " -f 3)
		CONTAINERD_COMMIT=$(grep CONTAINERD_COMMIT $dockerfile_path | head -n 1 | cut -d" " -f 3)
	fi

	current_runc_commit=$(command -v docker-runc >/dev/null 2>&1 && docker-runc --version | grep commit | cut -d" " -f 2)
	current_containerd_commit=$(command -v docker-containerd >/dev/null 2>&1 && docker-containerd --version | cut -d" " -f 5)
	current_tini_commit=$(command -v docker-init >/dev/null 2>&1 && docker-init --version | cut -d"-" -f 2 | cut -d"." -f 2)

	if [ -n "${LIBNETWORK_COMMIT}" ]; then
		echo "Building docker-proxy"
		export GOPATH="$(mktemp -d)"
		git clone git://github.com/docker/libnetwork.git "$GOPATH/src/github.com/docker/libnetwork"
		pushd "$GOPATH/src/github.com/docker/libnetwork"
		git checkout -q "$LIBNETWORK_COMMIT"
		go build -ldflags="-linkmode=external" -o docker-proxy github.com/docker/libnetwork/cmd/proxy
		sudo cp docker-proxy /usr/bin/docker-proxy
		popd
		rm -rf ${GOPATH}
	fi

	if [ -n "${TINI_COMMIT}" ]; then
		if [ "${current_tini_commit}" != "${TINI_COMMIT:0:7}" ]; then
			echo "Building tini"
			export GOPATH="$(mktemp -d)"
			git clone git://github.com/krallin/tini.git "$GOPATH/src/github.com/krallin/tini"
			pushd "$GOPATH/src/github.com/krallin/tini"
			git checkout -q "$TINI_COMMIT"
			cmake -DMINIMAL=ON .
			make tini-static
			sudo cp tini-static /usr/local/bin/docker-init
			popd
			rm -rf ${GOPATH}
		else
				echo "skipping tini compile, same commit"
		fi
	fi

	if [ -n "${RUNC_COMMIT}" ]; then
		if [ "${current_runc_commit:0:7}" != "${RUNC_COMMIT:0:7}" ]; then
			echo "Building runc"
			export GOPATH="$(mktemp -d)"
			git clone git://github.com/opencontainers/runc.git "$GOPATH/src/github.com/opencontainers/runc"
			pushd "$GOPATH/src/github.com/opencontainers/runc"
			git checkout -q "$RUNC_COMMIT"
			make BUILDTAGS="seccomp selinux"
			sudo cp runc /usr/local/bin/docker-runc
			popd
			rm -rf ${GOPATH}
		else
			echo "skipping runc compile, same commit"
		fi
	fi

	if [ -n "${CONTAINERD_COMMIT}" ]; then
		if [ "${current_containerd_commit:0:7}" != "${CONTAINERD_COMMIT:0:7}" ]; then
			echo "Building containerd"
			export GOPATH="$(mktemp -d)"
			git clone git://github.com/docker/containerd.git "$GOPATH/src/github.com/docker/containerd"
			pushd "$GOPATH/src/github.com/docker/containerd"
			git checkout -q "$CONTAINERD_COMMIT"
			make
			sudo cp bin/containerd /usr/local/bin/docker-containerd
			sudo cp bin/containerd-shim /usr/local/bin/docker-containerd-shim
			sudo cp bin/ctr /usr/local/bin/docker-containerd-ctr
			popd
			rm -rf ${GOPATH}
		else
			echo "skipping containerd compile, same commit"
		fi
	fi

	export GOPATH=${old_gopath}
}
