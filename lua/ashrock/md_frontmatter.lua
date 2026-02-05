local config = require('ashrock.config')

local cache = {}

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
          local item_list = line:gsub(field_name .. ':', ''):gsub('%s+', ''):gsub(',', '\n')
          for item in item_list:gmatch('[^\n]+') do
            items[item] = true
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
      if vim.startswith(topic:lower(), line:match("[^,%s]*$"):lower()) then
        table.insert(items, {
          label = topic,
          kind = vim.lsp.protocol.CompletionItemKind.Text
        })
      end
    end
  elseif is_objects then
    local objects = get_all_objects()
    for _, object in ipairs(objects) do
      if vim.startswith(object:lower(), line:match("[^,%s]*$"):lower()) then
        table.insert(items, {
          label = object,
          kind = vim.lsp.protocol.CompletionItemKind.Text
        })
      end
    end
  end
  
  callback({ items = items })
end

return {
  get_all = get_all,
  get_all_topics = get_all_topics,
  get_all_objects = get_all_objects,
  completion_source = source,
}
