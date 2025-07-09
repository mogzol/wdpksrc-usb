#!/bin/bash
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
source "$SCRIPT_DIR/common.sh"

export DOCKER_RAMDISK=1

DOCKER=/sbin/docker
DOCKERD=/sbin/dockerd

function is_mountpoint {
    mnts=$(grep "$1" /proc/self/mounts | awk '{print $2}')

    for i in $mnts; do
        if [ "$i" == "$1" ]; then
            return 0
        fi
    done

    return 1
}

function docker_setup {
    echo "Setting up docker"

    # replace old symlink by actual dir
    if [ -L /var/lib/docker ]; then
        echo 'Found docker symlink'
    else
        echo 'No symlink found'
        ln -sf "$DOCKER_ROOT" /var/lib/docker
    fi

    # For iptables
    ln -s /usr/local/modules/usrlib/xtables /usr/lib/xtables
    #ln -s /usr/local/modules/usrlib/* /usr/lib/.
    #ln -s /usr/local/modules/usrbin/* /usr/bin/.

    if [ ! -L /usr/sbin/mkfs.ext4 ]; then
        ln -s /usr/bin/mke2fs /usr/sbin/mkfs.ext4
    fi

    if ! lsmod | grep -q ^ipv6; then
        echo "Loading ipv6"
        insmod /usr/local/modules/driver/ipv6.ko disable_ipv6=1
    fi

    echo "Loading drivers"

    drivers=(
        "/usr/local/modules/driver/nf_conntrack.ko"
        "/usr/local/modules/driver/nf_nat.ko"
        "/usr/local/modules/driver/nf_defrag_ipv4.ko"
        "/usr/local/modules/driver/nf_conntrack_ipv4.ko"
        "/usr/local/modules/driver/nf_nat_ipv4.ko"
        # "/usr/local/modules/driver/nf_defrag_ipv6.ko"
        # "/usr/local/modules/driver/nf_conntrack_ipv6.ko"
        "/usr/local/modules/driver/x_tables.ko"
        "/usr/local/modules/driver/xt_conntrack.ko"
        "/usr/local/modules/driver/xt_addrtype.ko"
        #"/usr/local/modules/driver/xt_mark.ko"
        #"/usr/local/modules/driver/xt_policy.ko"
        "/usr/local/modules/driver/xt_tcpudp.ko"
        "/usr/local/modules/driver/xt_nat.ko"
        "/usr/local/modules/driver/nf_nat_masquerade_ipv4.ko"
        "/usr/local/modules/driver/ipt_MASQUERADE.ko"
        #"/usr/local/modules/driver/ipt_REJECT.ko"
        #"/usr/local/modules/driver/ipt_ULOG.ko"
        #"/usr/local/modules/driver/ip6_tables.ko"
        #"/usr/local/modules/driver/ip6t_REJECT.ko"
        #"/usr/local/modules/driver/ip6t_ipv6header.ko"
        #"/usr/local/modules/driver/ip6table_filter.ko"
        #"/usr/local/modules/driver/ip6table_mangle.ko"
        "/usr/local/modules/driver/ip_tables.ko"
        "/usr/local/modules/driver/iptable_filter.ko"
        #"/usr/local/modules/driver/iptable_mangle.ko"
        "/usr/local/modules/driver/iptable_nat.ko"
        "/usr/local/modules/driver/llc.ko"
        "/usr/local/modules/driver/stp.ko"
        "/usr/local/modules/driver/bridge.ko"
        "/usr/local/modules/driver/br_netfilter.ko"
    )

    for m in "${drivers[@]}"; do
        mod_name=$(basename "$m" .ko)
        mod_name=${mod_name//-/_}

        if lsmod | grep -q "^$mod_name "; then
            echo "$mod_name already loaded"
        else
            echo "Loading $mod_name"
            if ! insmod "$m"; then
                echo "Failed to load $mod_name"
            fi
        fi
    done

    echo "Setting up cgroup"
    umount /sys/fs/cgroup 2>/dev/null
    cgroupfs-mount
    set_docker_cgroup
}

function docker_stop {
    # Stop all containers
    containers="$($DOCKER ps -q)"
    if [ -n "$containers" ]; then
        echo "Stopping containers $containers"
        $DOCKER stop "$containers"
    fi

    # Stop docker
    docker_pid="$(cat /var/run/docker.pid)"
    if [ -n "$docker_pid" ]; then
        echo "Stopping Docker pid=$docker_pid"
        kill "$docker_pid"
    fi
}

function dm_cleanup {
    shm_mounts=$(grep "shm.*docker" /proc/self/mounts | awk '{print $2}')

    for mnt in $shm_mounts; do
        echo "shm_cleanup: ${mnt}"
        umount "$mnt"
    done

    if grep -q docker /proc/self/mounts; then
        umount /var/lib/docker/plugins
        umount /var/lib/docker
    fi

    dmsetup remove_all
}

function docker_cleanup {
    echo "Cleaning up Docker"

    # remove cgroup stuff
    /usr/sbin/cgroupfs-umount

    dm_cleanup
}

function set_docker_cgroup {
    ONE_G_KB=1048576

    mem_quota=0
    mem_total_kb=$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}')

    if [[ ! "$mem_total_kb" =~ ^[0-9]+$ ]]; then
        echo "Failed to get total memory!"
        return 1
    fi

    if [ "$mem_total_kb" -gt $ONE_G_KB ]; then
        mem_quota=$((mem_total_kb / 2))
    else
        mem_quota=$((mem_total_kb / 3))
    fi

    echo "Total RAM: $mem_total_kb KB"

    if is_mountpoint /sys/fs/cgroup/memory; then
        echo "Creating /sys/fs/cgroup/memory/docker"
        mkdir -p /sys/fs/cgroup/memory/docker
    else
        echo "/sys/fs/cgroup/memory is not a cgroup mount"
        return 1
    fi

    echo "Docker quota: $mem_quota KB"
    if echo "${mem_quota}K" >/sys/fs/cgroup/memory/docker/memory.limit_in_bytes; then
        # Docker and all containers use the same memory limit
        echo 1 >/sys/fs/cgroup/memory/docker/memory.use_hierarchy
        echo -n "Set memory quota for docker: "
        cat /sys/fs/cgroup/memory/docker/memory.limit_in_bytes
    fi
}

case $1 in
start)
    docker_pid=$(pidof dockerd)
    if [ -n "$docker_pid" ]; then
        echo "Docker is already running"
        exit 0
    fi

    echo "Starting Docker"
    dm_cleanup
    docker_setup
    $DOCKERD --ip-masq=true >>/var/lib/docker/docker.log 2>&1 &
    docker_pid=$!
    # Attach docker pid to memory cgroup
    if [[ "$docker_pid" =~ ^[0-9]+$ ]]; then
        echo $docker_pid >/sys/fs/cgroup/memory/docker/tasks
    fi
    echo "Docker pid $docker_pid"
    ;;
stop)
    docker_stop
    ;;
status)
    docker_pid=$(pidof dockerd)
    docker_mounts=$(grep docker /proc/self/mounts)
    if [ -z "${docker_pid}" ]; then
        echo "Docker is not running!"
        if [ "${docker_mounts}" ]; then
            echo "Found mounts: ${docker_mounts}"
        fi
        exit 1
    fi
    ;;
shutdown)
    docker_stop
    docker_cleanup
    ;;
*)
    echo "Invalid command!"
    exit 1
    ;;
esac
