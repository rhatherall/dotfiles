;; extends

; Adds to nvim-treesitter-textobjects' Ruby queries. Its @block.outer is only
; the `do ... end` or `{ ... }`, and its @parameter.outer is the whole list, so
; these are what the block and argument keys in plugins/treesitter.lua use.

; A call with its block, e.g. a whole `it "..." do ... end`
(call
  block: [(do_block) (block)]) @call_with_block.outer

; An argument or parameter with the comma after it (the first) or before it
; (the rest)
(argument_list . (_) @argument.outer . ","? @argument.outer)
(method_parameters . (_) @argument.outer . ","? @argument.outer)
(block_parameters . (_) @argument.outer . ","? @argument.outer)
(lambda_parameters . (_) @argument.outer . ","? @argument.outer)

(argument_list "," @argument.outer . (_) @argument.outer)
(method_parameters "," @argument.outer . (_) @argument.outer)
(block_parameters "," @argument.outer . (_) @argument.outer)
(lambda_parameters "," @argument.outer . (_) @argument.outer)
