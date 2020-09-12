" Test this by running:
" nvim --cmd "set rtp+=./nvim-example-lua-plugin"

lua mynotes = require("mynotes")

nmap <Leader>r :lua mynotes.findHeaders()<CR>
