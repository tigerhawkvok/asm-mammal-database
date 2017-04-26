Building PDFS
================

The PDF renderer here is https://github.com/wkhtmltopdf/wkhtmltopdf

This directory uses static, precompiled builds from [the wkHTMLToPDF page](https://wkhtmltopdf.org/downloads.html).

They also can be built from source, via [the README instructions](https://github.com/wkhtmltopdf/wkhtmltopdf/blob/master/INSTALL.md#linux).

At the time of this writing:

>Clone this repository by running the following command:
>
>    git clone --recursive https://github.com/wkhtmltopdf/wkhtmltopdf.git
>
>Please ensure that the cloned repository is in the user's home directory
>e.g. `~/wkhtmltopdf`. If you clone it in a different directory, it may
>fail with `E: Failed to change to directory /your/dir: No such file or directory`.
>Please note that [encrypted home directories](https://bugs.launchpad.net/ubuntu/+source/schroot/+bug/791908)
>and [non standard home directories](https://github.com/wkhtmltopdf/wkhtmltopdf/issues/1804)
>(i.e. not located in `/home`) are not supported -- you are advised to
>use a VM instead to build wkhtmltopdf.
>
>Building is supported only on latest stable Debian/Ubuntu 64-bit, and
>the binaries are produced in a self-contained chroot environment for the
>target distribution -- you will need to first setup the build environment
>and then only you can perform the build for a 32-bit or 64-bit binary.
>The following targets are currently supported:
>
>
>Target         | Setup of Build Environment                    | Building 32-bit binaries                 |  Building 64-bit binaries
>------         | --------------------------                    | ------------------------                 |  ------------------------
>Generic        | `sudo scripts/build.py setup-schroot-generic` | `scripts/build.py linux-generic-i386`    | `scripts/build.py linux-generic-amd64`
>
>
>Each target will require approximately 1.5GiB of disk space to hold both
>the `i386` and `amd64` chroot environments for that target. By default,
>the chroot environments are created under `/var/chroot` -- in case you
>want to create them under another location (e.g. due to insufficient disk
>space), please run the command `export WKHTMLTOX_CHROOT=/some/other/dir`
>**before** the command for setup of the build environment.
>
>While setting up the build environments, please ensure that you are logged
>in as a regular user who has `sudo` access. It is possible to run the script
>without `sudo` but you will need to have root privileges (e.g. via `su`). In
>that scenario, you may get the error `Unable to determine the login for which schroot access is to be given`
>-- you will have to set `export SUDO_USER=<username>` and try to run it again.
>Other than the setup of build environment, **do not run any other command
>with `root` privileges!** The compilation process can be run as a normal
>user and running it as `root` may lead to errors or complete loss of data.
>
>After the build environment is setup, you can run the command mentioned above
>to build either the 32-bit or 64-bit binaries, which should generate a
>native package (either DEB or RPM, depending on the distribution) in the
>`static-build/` folder.
>
