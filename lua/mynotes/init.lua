local function findHeaders()
    -- Get current buffer for window 0, the currently open window
    buf = vim.api.nvim_win_get_buf(0)
    lineCount = vim.api.nvim_buf_line_count(buf)
    lines = vim.api.nvim_buf_get_lines(buf, 0, lineCount, true)
    -- Iterate over lines and print the ones that start with `#`
    for _, line in ipairs(lines) do
        if string.match(line, '^#') then
            print(line)
        end
    end
end

return {
    findHeaders = findHeaders,
}
