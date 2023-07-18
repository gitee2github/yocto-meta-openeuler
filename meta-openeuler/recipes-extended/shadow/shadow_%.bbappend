# main bbfile: yocto-poky/meta/recipes-extended/shadow/shadow_4.11.bb

OPENEULER_SRC_URI_REMOVE = "https git http"

PV = "4.13"

# get extra config files from openeuler(pam.d directory)
FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# outdated patch
SRC_URI:remove = " \
           file://shadow-4.1.3-dots-in-usernames.patch \
           file://shadow-relaxed-usernames.patch \
           "

# delete native patches from poky, patch failed, as it's for 4.11
SRC_URI:remove:class-native = "file://0001-Drop-nsswitch.conf-message-when-not-in-place-eg.-musl.patch"

# use openeuler patches
SRC_URI:prepend = "file://${BP}.tar.xz \
           file://usermod-unlock.patch \
           file://backport-useradd-check-if-subid-range-exists-for-user.patch \
           file://shadow-add-sm3-crypt-support.patch \
           file://backport-Fix-off-by-one-mistakes.patch \
           file://backport-Fix-typos-in-length-calculations.patch \
           file://backport-Correctly-handle-illegal-system-file-in-tz.patch \
           file://backport-Explicitly-override-only-newlines.patch \
           file://backport-Prevent-out-of-boundary-access.patch \
           "

# add extra pam files for openeuler
# poky shadow.inc have added: chfn chpasswd chsh login newusers passwd su
PAM_SRC_URI += " \
        file://pam.d/groupmems \
        file://login.defs \
"

SRC_URI[sha256sum] = "813057047499c7fe81108adcf0cffa3ad4ec75e19a80151f9cbaa458ff2e86cd"

# no ${mandir} installed in openeuler
ALTERNATIVE:${PN}-doc = ""

do_install:append () {
    # use login.defs from openeuler, we have applied these functions as poky:
    # * Enable CREATE_HOME by default: "CREATE_HOME     yes"
    # * Make the users mailbox in ~/ not /var/spool/mail by default on an embedded system: "MAIL_FILE  .mail"  and "#MAIL_DIR    /var/spool/mail"
    # * Disable checking emails: "#MAIL_CHECK_ENAB        yes"
    # * Comment out SU_NAME to work correctly with busybox (See Bug#5359 and Bug#7173): "#SU_NAME        su"
    # * Use proper encryption for passwords: "ENCRYPT_METHOD SHA512"
    # * other list of function that compare with poky's shadow (yocto-poky/meta/recipes-extended/shadow/files/login_defs_pam.sed) :
    #   Function                login_defs_pam.sed          openeuler
    #   FAILLOG_ENAB            comment                     comment
    #   LASTLOG_ENAB            comment                     "LASTLOG_ENAB yes"
    #   MAIL_CHECK_ENAB         comment                     comment
    #   OBSCURE_CHECKS_ENAB     comment                     comment
    #   PORTTIME_CHECKS_ENAB    comment                     comment
    #   QUOTAS_ENAB             comment                     comment
    #   MOTD_FILE               comment                     comment
    #   FTMP_FILE               comment                     comment
    #   NOLOGINS_FILE           comment                     comment
    #   ENV_HZ                  comment                     comment
    #   ENV_TZ                  comment                     comment
    #   PASS_MIN_LEN            comment                     comment
    #   SU_WHEEL_ONLY           comment                     comment
    #   CRACKLIB_DICTPATH       comment                     comment
    #   PASS_CHANGE_TRIES       comment                     comment
    #   PASS_ALWAYS_WARN        comment                     comment
    #   PASS_MAX_LEN            comment                     comment
    #   PASS_MIN_LEN            comment                     comment
    #   CHFN_AUTH               comment                     comment
    #   CHSH_AUTH               comment                     noexist
    #   ISSUE_FILE              comment                     comment
    #   LOGIN_STRING            comment                     comment
    #   ULIMIT                  comment                     comment
    #   ENVIRON_FILE            comment                     comment
    # * for other difference between poky's shadow login.defs, see diff_login_defs.txt

    install -m 0644 ${WORKDIR}/login.defs ${D}${sysconfdir}/login.defs

    # use /bin/bash as default SHELL
    sed -i 's:/bin/sh:/bin/bash:g' ${D}${sysconfdir}/default/useradd
}

# keep as 4.13 recipe
PAM_PLUGINS:remove = "pam-plugin-lastlog"
