rex.bind("ctrl+a>c", "new_indexed_tab")
rex.bind("ctrl+a>,", "client.tab.rename")
rex.bind("ctrl+a>n", "client.tab.next")
rex.bind("ctrl+a>p", "client.tab.previous")
rex.bind("ctrl+a>x", "client.tab.close")
rex.bind("ctrl+a>w", "client.window.new")

-- Select tabs 1 through 9
for i = 1, 9 do
	rex.bind("ctrl+a>" .. i, "client.tab.goto", { index = i })
end

-- Workspaces
rex.bind("ctrl+a>f", "open_project_picker")
rex.bind("ctrl+a>shift+d", "session.close")
rex.bind("ctrl+a>shift+n", "session.new")
rex.bind("ctrl+a>space", "session.switch")
rex.bind("ctrl+a>shift+l", "session.previous")
rex.bind("ctrl+a>shift+4", "session.rename") -- $ on a US keyboard layout

-- Vim-style pane navigation
rex.bind("ctrl+a>h", "pane.focus.left")
rex.bind("ctrl+a>j", "pane.focus.down")
rex.bind("ctrl+a>k", "pane.focus.up")
rex.bind("ctrl+a>l", "pane.focus.right")

-- % and " on a US keyboard layout
rex.bind("ctrl+a>v", "pane.split", { direction = "right" })
rex.bind("ctrl+a>-", "pane.split", { direction = "down" })
rex.bind("ctrl+a>m", "pane.zoom")

-- Press the prefix twice to send Ctrl+A to the terminal
rex.bind("ctrl+a>ctrl+a", "pane.send_key", { key = "ctrl+a" })
