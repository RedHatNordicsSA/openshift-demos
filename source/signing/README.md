# Simplistic demo of signing

1. Login to a worker node in your cluster
```
oc debug node/the-name-of-a-worker-node
chroot /host
```

2. Put pubkey.gpg locate in this repository in /root/pubkey.gpg
3. Replace /etc/container/policy.json with policy.json stored in this repository.
4. Demonstrate how you can pull an image which is signed with correct key
```
sh-4.4# podman pull registry.access.redhat.com/rhel7
Trying to pull registry.access.redhat.com/rhel7:latest...
Getting image source signatures
Copying blob 6e121ccea590 skipped: already exists  
Copying blob 13f131153d86 [--------------------------------------] 0.0b / 0.0b
Copying config 5a286023e7 done  
Writing manifest to image destination
Storing signatures
5a286023e73cb2cb0d2824b89cc6b8a8f6c2cb6044f37159d9b9f3f4eddda9cb
```
5. Demonstrate how you cannot pull an image which is not signed correctly to the node
```
sh-4.4# podman pull docker.io/library/hello-world
Trying to pull docker.io/library/hello-world:latest...
  A signature was required, but no signature exists
Error: Source image rejected: A signature was required, but no signature exists
sh-4.4# 
```

