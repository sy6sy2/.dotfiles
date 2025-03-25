# My dotfiles

## Needed external dependencies

* zsh: `brew install zsh`
* Starship: `brew install starship`
* zoxide: `brew install zoxide`
* fzf: `brew install fzf`
* bat: `brew install bat`
* eza: `brew install eza`


## Hot to use it

```bash
# Assuming zsh is already your default shell
cd $HOME
git clone --recurse-submodules https://github.com/sy6sy2/.dotfiles.git
cd .dotfiles
stow zsh
```

## Sources

### GNU Stow

* https://www.jakewiesler.com/blog/managing-dotfiles

### ZSH

* https://mac.install.guide/terminal/zshrc-zprofile
* https://www.freecodecamp.org/news/how-do-zsh-configuration-files-work/
* https://thevaluable.dev
* https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/key-bindings.zsh

### fzf

* https://pragmaticpineapple.com/four-useful-fzf-tricks-for-your-terminal/