-- TODO: this is fucking ridiculous
-- Stack Table
-- Uses a table as stack, use <table>:push(value) and <table>:pop()
-- Lua 5.1 compatible

-- GLOBAL
Stack = {}

-- Create a Table with stack functions
function Stack:Create()
  -- stack table
  local t = {}
  -- entry table
  t._et = {}

  -- push a value on to the stack
  function t:push(...)
    if ... then
      local targs = {...}
      -- add values
      for _,v in ipairs(targs) do
        table.insert(self._et, v)
      end
    end
  end

  -- pop a value from the stack
  function t:pop(num)
    -- get num values from stack
    local num = num or 1
    -- return table
    local entries = {}
    -- get values into entries
    for i = 1, num do
      -- get last entry
      if #self._et ~= 0 then
        table.insert(entries, self._et[#self._et])
        -- remove last value
        table.remove(self._et)
      else
        break
      end
    end
    -- return unpacked entries
    return unpack(entries)
  end

  -- get entries
  function t:getn()
    return #self._et
  end

  -- peek
  function t:peek()
      if #self._et == 0 then
          return nil
      else
          return self._et[#self._et]
      end
  end

  -- list values
  function t:list()
    for i,v in pairs(self._et) do
      print(i, v)
    end
  end

  return t
end

local function findHeaders()
    -- Get current buffer for window 0, the currently open window
    buf = vim.api.nvim_win_get_buf(0)
    lineCount = vim.api.nvim_buf_line_count(buf)
    lines = vim.api.nvim_buf_get_lines(buf, 0, lineCount, true)
    -- Iterate over lines and collect folds in each level
    folds = {}
    maxLevel = 0
    lastLineNumber = 0
    levelStack = Stack:Create()
    for lineNumber, line in ipairs(lines) do
        pounds, title = string.match(line, '^(#+)%s+(.+)')
        if pounds ~= nil then
            level = string.len(pounds)
            if folds[level] == nil then
                folds[level] = {}
            end
            -- print(lineNumber, 'level ', level)
            while (levelStack:getn() > 0) and (level <= levelStack:peek()) do
                -- finish current fold
                prevLevel, foldBegin = levelStack:pop(2) -- pop in inverse order
                -- print(lineNumber, 'pop ', foldBegin, prevLevel)
                folds[prevLevel][foldBegin] = lineNumber-1
            end
            levelStack:push(lineNumber, level)
            -- print(lineNumber, 'push ', lineNumber, level)
            if level > maxLevel then
                maxLevel = level
            end
        -- elseif string.match(line, '%s*$') then
            -- empy line indicates end of current fold?
        end
        lastLineNumber = lineNumber
    end
    -- finish last remaining fold
    while levelStack:getn() > 0 do
        level, foldBegin = levelStack:pop(2) -- pop in inverse order
        folds[level][foldBegin] = lastLineNumber
    end
    -- create the folds
    if maxLevel == 0 then
        return
    end
    vim.api.nvim_command('set foldmethod=manual')
    vim.api.nvim_command('normal zE') -- delete all folds
    for i = 1, maxLevel do
        for first, last in pairs(folds[i]) do
            -- print(first, last)
            vim.api.nvim_command(string.format('%d,%dfold', first, last))
        end
    end
    vim.api.nvim_command('normal zM') -- fold everything
end

return {
    findHeaders = findHeaders,
}
