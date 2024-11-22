local wezterm = require("wezterm")
local act = wezterm.action

-- Some empty tables for later use
local config = {}
local launch_menu = {}

-- Windows-specific configuration
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	local success, stdout, stderr = wezterm.run_child_process({ "cmd.exe", "ver" })
	if success then
		local major, minor, build, rev = stdout:match("Version ([0-9]+)%.([0-9]+)%.([0-9]+)%.([0-9]+)")
		local is_windows_11 = tonumber(build) >= 22000
	end
end

config.default_prog = { "powershell.exe", "-NoLogo" }

-- Default configuration settings
config.font = wezterm.font("Fira Code")
config.font_size = 13
config.launch_menu = launch_menu
config.default_cursor_style = "BlinkingBar"
config.disable_default_key_bindings = true

-- Mouse bindings
config.mouse_bindings = {
	{
		event = { Down = { streak = 3, button = "Left" } },
		action = wezterm.action.SelectTextAtMouseCursor("SemanticZone"),
		mods = "NONE",
	},
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = wezterm.action_callback(function(window, pane)
			local has_selection = window:get_selection_text_for_pane(pane) ~= ""
			if has_selection then
				window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
				window:perform_action(act.ClearSelection, pane)
			else
				window:perform_action(act({ PasteFrom = "Clipboard" }), pane)
			end
		end),
	},
}

-- Key bindings
config.keys = {
	{
		key = "1",
		mods = "ALT|CTRL",
		action = act.SpawnCommandInNewTab({
			cwd = "D:\\Personal\\waffle_engine", -- The target directory
			args = { "powershell.exe", "-NoLogo" }, -- Adjust to your shell preference
		}),
	},
	-- Prompt for a tab name before creating a new tab with Ctrl + N
	{
		key = "n",
		mods = "CTRL",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Enter name for new tab" },
			}),
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:perform_action(act.SpawnTab("DefaultDomain"), pane)
					local tab = window:mux_window():active_tab()
					if tab then
						tab:set_title(line)
					end
				end
			end),
		}),
	},
	-- Close the current tab with Ctrl + Q
	{
		key = "q",
		mods = "ALT",
		action = act.CloseCurrentTab({ confirm = true }),
	},
	-- Move to the next tab with Ctrl + L
	{
		key = "l",
		mods = "ALT",
		action = act.ActivateTabRelative(1),
	},
	-- Move to the previous tab with Ctrl + H
	{
		key = "h",
		mods = "ALT",
		action = act.ActivateTabRelative(-1),
	},
	-- List all tabs with Alt + L
	{
		key = "L",
		mods = "ALT",
		action = act.ShowTabNavigator,
	},
}

return config
