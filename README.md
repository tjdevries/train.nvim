# train.vim

Train yourself with vim motions and make your own train tracks :)


# Installation

You'll need two of my plugins to run this, since I spend too much time modularizing plugins :)

```vim
Plug 'tjdevries/std.vim'
Plug 'tjdevries/conf.vim'
Plug 'tjdevries/train.vim'

" Optional, to get really cool menus :)
Plug 'skywind3000/quickmenu.vim'
```

## Still Under Construction :smile:

TODO:
- Allow to "cycle through" the options that we've done, in the case of long reaaching movements
- Add more "styles" of movement, and then map them to something like:
  - `<Plug>(train_up_down)`
  - `<Plug>(train_left_right)`
  - `<Plug>(train_word)`
  - etc...
- Add a menu/denite/unite source for "options" of learning movement
- Add visual mode type support? Something similar to MatchParen style
- Add some movements from popular plugins?
- Write a good readme :star2:
