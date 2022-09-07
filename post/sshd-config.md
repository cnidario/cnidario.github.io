---
title: SSH
date: 2021-04-10
description: "SSH things"
---

# Configure the pubkey based login
You login **from** a computer with the **private** key **to** another computer with the **public** key.

## Generate the key pair
``` {.bash}
$ ssh-keygen -t ed25519
```

## Install the key into the remote computer
Needs accessible SSH into the remote computer.

``` {.bash}
$ ssh-copy-id -i ~/.ssh/id_ed25519.pub remote-user@remote-server
```

Manual (ssh-copy-id alternative)

``` {.bash}
# @ remote computer
$ mkdir ~/.ssh
$ cat id_ed25519.pub >> ~/.ssh/authorized_keys
$ chmod 600 ~/.ssh/authorized_keys
```

## Secure the server
 
Edit as root `/etc/sshd_config`, and change these lines (default values are commented).
 
``` {.ini}
PubkeyAuthentication yes
AllowUsers <yourusername>
PasswordAuthentication no
```
## Test sshd config & reload
 
``` {.bash}
(as root) $ sshd -t && kill -SIGHUP $(pgrep -f 'sshd -D')
```

# Manage SSH Keys in KeePassXC
[KeePassXC] is a secure password manager with strong cryptography. All your passwords will be keep secret under a master password (make it very secure). And the database is a plain file so you can share it between devices through cloud storage, a pendrive...

It's a clone of KeePass, KeePassX... I prefer it over the others because it's cross-platform (works in GNU/Linux), doesn't use Mono and even works great with Android Phones (with the Keepass2Android app).

It has integration with `ssh-agent` so I keep my ssh keys in it aswell. You have to make an entry with your pair's passphrase and then under the **SSH Agent** tab add the private key file as an **Attachment**. Then you can **right click the entry** and select **'Add key to SSH Agent'**. After that you can just `ssh <host-name>`.

If KeePassXC doesn't run under a shell session which first ran the `ssh-agent` (i.e. under `/.xsession`), go to **Tools > SSH Agent** and copy the value of `SSH_AUTH_SOCK`.

[KeePassXC]: https://keepassxc.org/

# Run X applications in the remote server
## 1. Display the application in your local computer (from where you are running ssh)

Change `/etc/sshd_config` to `X11Forwarding yes` and log to the server with `ssh -Y` or `ssh -X`.
Now when you run an X app it will be displayed onto your local computer (but running in the remote)

## 2. Display the application in the remote computer

You need an existing X session in the remote server. Run `DISPLAY=:0 nohup xterm` in the ssh session.

# Mantain an opened tmux session
 1. Start a tmux session and configure some tabs
 2. Detach from the tmux session with Control+B d
 3. Reattach to the tmux session at anytime with `tmux attach-session -t 0`

# Exit from a hanged SSH connection
Key sequence: `<Enter>~.`
