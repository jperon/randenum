import concat, insert, remove, sort from table
import randomseed, random from math
import open from io
import time from os

randomseed time!

lists = {}

shuffle = =>
  for i = 1, #@ - 1 do
    r = random i, #@
    @[i], @[r] = @[r], @[i]
  return @

begin_buffenv = ->
  list_content = {}
  lists[#lists+1] = list_content
  nest_level = 0
  luatexbase.add_to_callback 'process_input_buffer',
    =>
      insert list_content, @
      if @find [[\begin{randenum}]]
        nest_level += 1
      if @find [[\end{randenum}]]
        nest_level -= 1
      return '' if nest_level >= 0,
    'readline'

end_buffenv = ->
  luatexbase.remove_from_callback 'process_input_buffer', 'readline'
  list_content = remove lists
  remove list_content
  items = {}
  fnames = {}
  within_env = 0
  local item, f, fname
  for l in *list_content
    if within_env == 0 and l\match [[\item]]
      items[#items+1] = item
      item = {}
    if l\match [[\begin]]
      within_env += 1
      if within_env == 1
        fname = os.tmpname!
        f = open fname, "w"
    if within_env == 0
      item[#item+1] = l
    else
      f\write "#{l}\n"
    if l\match [[\end]]
      within_env -= 1
      if within_env == 0
        f\close!
        item[#item+1] = "\\input{#{fname}}"
  items[#items+1] = item
  s = [ concat item, "\n" for item in *shuffle items ]
  tex.print "\\begin{enumerate}"
  tex.tprint l for l in *shuffle items
  tex.print "\\end{enumerate}"

:begin_buffenv, :end_buffenv
