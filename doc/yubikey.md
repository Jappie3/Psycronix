## FIDO SSH Keys

- See https://developers.yubico.com/SSH/Securing_SSH_with_FIDO2.html

- Use `PubkeyAuthOptions verify-required` in sshd_config to enable user verification (see https://man.openbsd.org/sshd_config#PubkeyAuthOptions)

- Discoverable keys:
    - Can be taken to any compatible workstation and used to authenticate by touch and FIDO2 PIN
    - Ideal for ease of access where the PIN is known
    - Needs OpenSSH 8.3 or higher (`ssh -V`)

- Non-discoverable keys:
    - Cannot be used by another person without the credential id file, even if the PIN is known.
    - Ideal for systems where privacy is important if the YubiKey is lost or stolen
    - Needs OpenSSH 8.2p1 or higher (`ssh -V`)
    - Generation:
        - `ssh-keygen -t ed25519-sk`
            - `ssh-keygen -t ed25519-sk -a [rounds, 16 default] -f [output-file]`
        - Generates `id_ecdsa_sk` & `id_ecdsa_sk` by default
