# How To Use

1.  Install `git` on the server:

```bash
$ sudo apt update
$ sudo apt install -y git
```

2. Clone this repo:

```bash
$ git clone https://github.com/saeidscorp/wg-setup.git
```

2. Run the damn script!

```bash
$ cd wg-setup
$ ./setup-wg.sh
```

3. Use `wg-manage` to create peers:

```bash
$ wg-manage add_peer john phone linux
```

This will create a config file named `john-phone.conf` in the current directory.

4. Transfer the config to the device to use. You can also use QR codes [optional]:

```bash
$ sudo apt install -y qrencode
```

