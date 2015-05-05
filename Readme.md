# passwrapper

Have you always wanted to use multiple password stores for different proposes?
For example one password store for your passwords at work and another one for
you private passwords?

While this is basically possible with native [pass][pass] it is quite a hassle
to do use it.

This script massively simplifies such a use case by allowing simple switching,
creating and removing of such password stores.


## Installation

Simply copy the passwrapper.sh file to your favorite location or use the package
manager of your distribution to install it.

After installation add the following to your rc-file of your shell to activate
the passwrapper functionality.

```bash
source /path/to/passwrapper.sh
```

By default passwrapper saves the password stores in `$HOME/.pass`.However, if
this is not the directory where you want to save your password stores, you can
change this by putting the following command before sourcing the wrapper
script.

```bash
export PASS_HOME=$HOME/mypasswords
```

## Usage

After sourcing the script multiple commands managing your password stores are available

### lspass

Lists all password stores which are managed by the script.

### mkpass

Create a new password store.

### rmpass

Remove a password store. This will remove all passwords saved in this password store.

### passon

Activate one of the managed password stores. After using this command you can now simply use
the pass program [pass][pass] to manage your passwords.

### passoff

Deactivate the previously activated password store again.

## Short walk-through

0. Make sure the script is properly sourced.

1. Create a new password store with `mkpass private`.

2. Activate the newly created password store with `passon private`.

3. Initialize pass with `pass init YOURPGPID`

4. Add passwords to the store with `pass insert foo/bar`.

5. Deactivate the password store again with `passoff`.

## Show current password store in your prompt

It is of course possible to show in your shell prompt which password store you
are currently using. Below there are some examples how to achieve this for
different shells.

### Zsh

With the help of the [grml config][grml_config] adding the following to your
zshrc will make a pretty password store prompt.

```zsh
# Passwrapper support
function passwrapper_prompt() {
    REPLY=${PASS_DIR+(${PASS_DIR:t}) }
}

grml_theme_add_token passwrapper -f passwrapper_prompt '%F{blue}' '%f'

# Add to left prompt
zstyle ':prompt:grml:left:setup' items ... passwrapper ...
```

### Bash

Changing your bash prompt as simple as the Zsh one. Just put the following in
your bashrc.

```bash
# Passwrapper support
passwrapper_prompt() {
    if [ -z "$PASS_DIR" ]; then
        PASSWRAPPER_PROMPT=""
    else
        PASSWRAPPER_PROMPT="\[\e[1;34m\](`basename \"$PASS_DIR\"`) \[\e[0m\]"
    fi
}

build_prompt() {
    #...
    passwrapper_prompt
    #...
    
    PS1="... ${PASSWRAPPER_PROMPT} ..."
}

PROMPT_COMMAND=build_prompt
```


[pass]: http://www.passwordstore.org/
[grml_config]: https://grml.org/zsh/
