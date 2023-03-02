local concat, insert, remove, sort
do
  local _obj_0 = table
  concat, insert, remove, sort = _obj_0.concat, _obj_0.insert, _obj_0.remove, _obj_0.sort
end
local randomseed, random
do
  local _obj_0 = math
  randomseed, random = _obj_0.randomseed, _obj_0.random
end
local open
open = io.open
local time
time = os.time
randomseed(time())
local lists = { }
local shuffle
shuffle = function(self)
  for i = 1, #self - 1 do
    local r = random(i, #self)
    self[i], self[r] = self[r], self[i]
  end
  return self
end
local begin_buffenv
begin_buffenv = function()
  local list_content = { }
  lists[#lists + 1] = list_content
  local nest_level = 0
  return luatexbase.add_to_callback('process_input_buffer', function(self)
    insert(list_content, self)
    if self:find([[\begin{randenum}]]) then
      nest_level = nest_level + 1
    end
    if self:find([[\end{randenum}]]) then
      nest_level = nest_level - 1
    end
    if nest_level >= 0 then
      return ''
    end
  end, 'readline')
end
local end_buffenv
end_buffenv = function()
  luatexbase.remove_from_callback('process_input_buffer', 'readline')
  local list_content = remove(lists)
  remove(list_content)
  local items = { }
  local fnames = { }
  local within_env = 0
  local item, f, fname
  for _index_0 = 1, #list_content do
    local l = list_content[_index_0]
    if within_env == 0 and l:match([[\item]]) then
      items[#items + 1] = item
      item = { }
    end
    if l:match([[\begin]]) then
      within_env = within_env + 1
      if within_env == 1 then
        fname = os.tmpname()
        f = open(fname, "w")
      end
    end
    if within_env == 0 then
      item[#item + 1] = l
    else
      f:write(tostring(l) .. "\n")
    end
    if l:match([[\end]]) then
      within_env = within_env - 1
      if within_env == 0 then
        f:close()
        item[#item + 1] = "\\input{" .. tostring(fname) .. "}"
      end
    end
  end
  items[#items + 1] = item
  local s
  do
    local _accum_0 = { }
    local _len_0 = 1
    local _list_0 = shuffle(items)
    for _index_0 = 1, #_list_0 do
      local item = _list_0[_index_0]
      _accum_0[_len_0] = concat(item, "\n")
      _len_0 = _len_0 + 1
    end
    s = _accum_0
  end
  tex.print("\\begin{enumerate}")
  local _list_0 = shuffle(items)
  for _index_0 = 1, #_list_0 do
    local l = _list_0[_index_0]
    tex.tprint(l)
  end
  return tex.print("\\end{enumerate}")
end
return {
  begin_buffenv = begin_buffenv,
  end_buffenv = end_buffenv
}
