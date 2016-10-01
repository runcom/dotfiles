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
	AUTO_GOPATH=1 BUILDFLAGS="-race" DOCKER_BUILDTAGS="seccomp experimental selinux journald exclude_graphdriver_btrfs exclude_graphdriver_zfs exclude_graphdriver_aufs exclude_graphdriver_devicemapper" ./hack/make.sh dynbinary
	if [ -e "bundles/latest/dynbinary/docker" ]; then
		sudo cp bundles/latest/dynbinary/docker /usr/bin/docker
	else
		sudo cp bundles/latest/dynbinary-client/docker /usr/bin/docker
		sudo cp bundles/latest/dynbinary-daemon/dockerd /usr/bin/dockerd
		if [ -e "bundles/latest/dynbinary-daemon/docker-proxy" ]; then
			sudo cp bundles/latest/dynbinary-daemon/docker-proxy /usr/bin/docker-proxy
		fi
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
	dockerfile_path="${GOPATH}/src/github.com/docker/docker/Dockerfile"
	RUNC_COMMIT=$(grep RUNC_COMMIT $dockerfile_path | head -n 1 | cut -d" " -f 3)
	echo $RUNC_COMMIT
	current_runc_commit=$(command -v docker-runc >/dev/null 2>&1 && docker-runc --version | grep commit | cut -d" " -f 2)
	echo $current_runc_commit

	CONTAINERD_COMMIT=$(grep CONTAINERD_COMMIT $dockerfile_path | head -n 1 | cut -d" " -f 3)
	echo $CONTAINERD_COMMIT
	current_containerd_commit=$(command -v docker-containerd >/dev/null 2>&1 && docker-containerd --version | cut -d" " -f 5)
	echo $current_containerd_commit

	if [ -n "${RUNC_COMMIT}" ]; then
		if [ "${current_runc_commit}" != "${RUNC_COMMIT}" ]; then
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
		if [ "${current_containerd_commit}" != "${CONTAINERD_COMMIT}" ]; then
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
