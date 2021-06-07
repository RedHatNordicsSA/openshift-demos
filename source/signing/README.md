# Simplistic demo of signing

1. Login to a worker node in your cluster
```
oc debug node/the-name-of-a-worker-node
chroot /host
```

2. Put pubkey.gpg locate in this repository in /root/pubkey.gpg and replace /etc/container/policy.json with policy.json stored in this repository. Do it manually or paste the below commands into the node debug shell.
```
cp /etc/containers/policy.json /etc/containers/policy.json.bak

cat << 'EOF' >/etc/containers/policy.json
{
    "default": [
        {
            "type": "insecureAcceptAnything"
        }
    ],
    "transports": {
        "docker": {
            "docker.io":
            [{
                    "type": "signedBy",
                    "keyType": "GPGKeys",
                    "keyPath": "/root/pubkey.gpg"
            }]
        },             
        "docker-daemon": {
            "": [{"type":"insecureAcceptAnything"}]
        }
    }
}
EOF

cat << 'EOF' >/root/pubkey.gpg
pub   rsa4096/55A34A82 2019-08-30
uid                   Red Hat, Inc. (ISV Container Signing Key) <secalert@redhat.com>

-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBF1poLQBEACSTZqYWn0MRf1bZUYr3sTYZaOD/7jvsnY/ZJ0onG9ZAikE1bSn
0xHrdnQgTJ4BhRA/dTQvLz4IZ+D52IyFqpc42LKB7CaOdjvLoyEkazLfAaEAalNV
VVgKwdNmZ8ZnrurT+ndWeYIlSq5i4udbUrKqIBXt2PAuykR+k9nE4RyiHd2E0QrE
BL+oGpnTAy8w5bVvfyrvBo1YG7Hqr6+KhO2S+/f6EUZ6xv0+QkBYVrHZ/qZinVdd
cRB1vNXrsNmoJoJAYxWZIUo13weLHV9f88aqfef2GViWIHQOWYzJjGzyY+PCUXIy
2uEGBZdNI2bfqva+dG0OPqLxjmjx3893PLNkAsKbDxBti/IqkOa09rvoeMVZmZf1
Iws+dB8TgJHiqrpE+EGk9cEN79q11eYyrNm12E0jrelT7vNXtPuS9sHDfIuL0+UI
kvViJ6Q3SVcDZhiyz5IYQLwJKmpcYfDdr7U9WsganLGKwz7db/k+o7XkgiC7Uzu+
rZ62ghlE3HZwPJJ2tp4oz4Uvxtq/mXP4JmYkuJGPTe4eialMri6isSJhY2ofVhFG
DAPqh3+a3ncXCFqdXsGndBTXacuoapddvRz7ZdRwxiAun1BRMbuGqhhqEQnqZ8vY
V+RkxtyvPTH2QG0aBlF0Vz5113v21Aqxgc5jgiCyuGlw6hHCo2TaXNsLOQARAQAB
tD9SZWQgSGF0LCBJbmMuIChJU1YgQ29udGFpbmVyIFNpZ25pbmcgS2V5KSA8c2Vj
YWxlcnRAcmVkaGF0LmNvbT6JAjcEEwECACEFAl1poLQCGwMGCwkIBwMCBhUIAgkK
CwMWAgECHgECF4AACgkQGsSXE1WjSoKbvw//WXJoSXUpILwEpqXoSjf66mXlE0bJ
xJJHGau1RJhH3xD+CgatT/YyYVxd2KbSjvynzJMO6vgIFbUSZ1bUcWbW4Ow2NJsh
1xe8k66WgcuwgTc5EM9EDGliw8h60qwcqMBsyqnXJBV7mSb0t3g1DgfLyC1jxQrY
e5OknVaGBx9R5akIY34A1RJMz2+CYL/TuF4jZo5QYHrCHATXlgeWn5UrVZOoH2MW
ZP4lqtnzDRHUcEiGeH3EO23i3zd8+PX9suJAlX8X+138BBB/j+M3a101JRiH5FGa
48iVk4Ye6wSTlrjbynrSFPspJx88qaaHTdORbH4ZpkZXcKrM5tqf2zEl6oxpX0ov
6xwpOXaJoKoC7MngOlJer8YocH9Q2HS5rZ/vwG2JzqpguJVmGul33olEiGgNS4n/
Pj3scYoV6s5v1hsJjqWnhyVL8SG+P+yyGwowfk0KHd+ndwz+XbWy++dND2rmWQdf
c9UPBUFr4grNua15rxKzIy6JcofqLU8yDi/WpOiCUDDdtfb1lSqZfJ/vTM0DEeJd
LYFHoKMrRg4gSGo3bjGpFJZh4Zd38F/ndS/DWlq1AB9mX50Whx4bSQ7F9MF8XdLA
ejEKPqH0E3wnOcU0oApjCOFkmq8FeoOs3rfHA9GFKnJDjN+cjrWPTTphVkeHLaIH
UCvsF5NAPH9MxGo=
=pNfE
-----END PGP PUBLIC KEY BLOCK-----
EOF
```

5. Demonstrate how you can pull an image which is signed with correct key. The key is Red Hat's official container signing key, so anything in Red Hat's registry will work.
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
6. Potentially, restore the policy, as you will not be able to deploy custom build images with this policy. Replace /etc/container/policy.json with content in policy-org.json in this repository. If you ran the example implementation you can do this by copying back the restored.

