local config = require('ashrock.config')

local cache = {}

local function create_md_template()
  local file_path = vim.fn.expand('%:p')
  if string.match(file_path, config.texts_path) then
    local current_time = os.date("%Y-%m-%d %H:%M")
    local template = {
      "",
      "",
      "---",
      "created: " .. current_time,
      "---",
    }
    vim.api.nvim_buf_set_lines(0, 0, 0, false, template)
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
  end
end

local function get_all(field_name)
  if not cache[field_name] then
    cache[field_name] = {
      data = {},
      last_update = 0
    }
  end

  local current_time = os.time()
  if current_time - cache[field_name].last_update > config.cache_timeout then
    local items = {}
    local files = vim.fn.glob('**/*.md', false, true)

    for _, file in ipairs(files) do
      local content = vim.fn.readfile(file)
      local in_frontmatter = false

      for _, line in ipairs(content) do
        if line == '---' then
          in_frontmatter = not in_frontmatter
        elseif in_frontmatter and line:match('^' .. field_name .. ':') then
          local raw = line:gsub(field_name .. ':', '')
          raw = raw:gsub('[%[%]"]', '')  -- YAML 배열 문법 제거
          raw = raw:gsub('%s+', ''):gsub(',', '\n')
          for item in raw:gmatch('[^\n]+') do
            if item ~= '' then
              items[item] = true
            end
          end
        end
      end
    end

    cache[field_name].data = vim.tbl_keys(items)
    cache[field_name].last_update = current_time
  end

  return cache[field_name].data
end

local function get_all_topics()
  return get_all('topics')
end

local function get_all_objects()
  return get_all('objects')
end

-- 자동완성 소스 설정
local source = {}

source.new = function()
  return setmetatable({}, { __index = source })
end

source.get_trigger_characters = function()
  return { ',', ' ' }
end

source.complete = function(self, params, callback)
  local line = params.context.cursor_before_line
  local items = {}
  
  local is_topics = line:match('topics:')
  local is_objects = line:match('objects:')
  
  if is_topics then
    local topics = get_all_topics()
    for _, topic in ipairs(topics) do
      if vim.startswith(topic:lower(), line:match('[^,%s%[%]"]*$'):lower()) then
        table.insert(items, {
          label = topic,
          kind = vim.lsp.protocol.CompletionItemKind.Text
        })
      end
    end
  elseif is_objects then
    local objects = get_all_objects()
    for _, object in ipairs(objects) do
      if vim.startswith(object:lower(), line:match('[^,%s%[%]"]*$'):lower()) then
        table.insert(items, {
          label = object,
          kind = vim.lsp.protocol.CompletionItemKind.Text
        })
      end
    end
  end
  
  callback({ items = items })
end

-- 사용자 명령어 생성
vim.api.nvim_create_user_command('CreateMDTemplate', create_md_template, {})

-- 자동 명령어 설정
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.md",
  callback = create_md_template
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.md",
  callback = function()
    local file_path = vim.fn.expand('%:p')
    if string.match(file_path, config.texts_path) then
      local current_time = os.date("%Y-%m-%d %H:%M")
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      -- created 라인의 인덱스를 찾습니다
      local created_index = -1
      for i, line in ipairs(lines) do
        if line:match("^created:") then
          created_index = i
          break
        end
      end

      if created_index ~= -1 then
        -- created 다음 라인에 updated를 추가/업데이트합니다
        local next_line = lines[created_index + 1] or ""
        if next_line:match("^updated:") then
          -- 이미 updated가 있다면 업데이트
          lines[created_index + 1] = "updated: " .. current_time
        else
          -- updated가 없다면 새로 추가
          table.insert(lines, created_index + 1, "updated: " .. current_time)
        end

        -- 변경된 내용을 버퍼에 적용
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
      end
    end
  end
})

return {
  get_all = get_all,
  get_all_topics = get_all_topics,
  get_all_objects = get_all_objects,
  completion_source = source,
}
